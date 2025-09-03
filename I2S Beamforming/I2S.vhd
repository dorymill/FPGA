------------------------------------------------
-- The purpose of this project is to produce
-- a beamformed CW output from a linear array
-- of four speakers, with the capability of
-- switching from an in-phase mode to I2S
-- mode.

-- Quadspi: S25FL032
-- Author: dmmill

------------------------------------------------
-- Libraries
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------
entity I2S is
------------------------------------------------

    generic ( -- Constants 

        mClkFreq  : integer := 30720000;  -- Master Clock Frequency
        lrClkFreq : integer := 96000;     -- Frame Sync Clock Frequency (f_s = 96 kHz Audio)
        bitWidth  : integer := 16;        -- Audio Data Size
        nChan     : integer := 2         -- Number of Channels

    );

    port ( -- Physical IO defined in XDC file

        ENABLE   : in std_logic; -- Reset
        MCLK     : in std_logic; -- Master Clock
        VALID    : in std_logic; -- Data Valid Signal

        PHONE1   : out std_logic; -- Phone 1 bit output
        PHONE2   : out std_logic; -- Phone 2 bit output
        PHONE3   : out std_logic; -- Phone 3 bit output
        PHONE4   : out std_logic; -- Phone 4 bit output
        
        LRCLK    : out std_logic; -- Frame Sync Clock
        BCLK     : out std_logic; -- Bit Sync Clock
        READY    : out std_logic -- Data Ready Signal

    );

end entity I2S;

------------------------------------------------
architecture RTL of I2S is
------------------------------------------------

    -- Constants
    constant lrClkCntMax  : integer := (mClkFreq / lrClkFreq) - 1;                  -- Clock cycles per frame sync cycle (mClk/f_s)
    constant bitClkCntMax : integer := (mclkFreq / (lrClkFreq*nChan*bitWidth)) - 1; -- Frame Sync cycles per N Channels of words (f_s*channels*data width)
    constant bitCntMax    : integer := bitWidth - 1;                                -- Data width
    
    -- Signals
    -- Counters
    signal lrClkCntr  : integer range 0 to lrClkCntMax;  -- Frame Sync Clock Cycle Counter
    signal bitClkCntr : integer range 0 to bitClkCntMax; -- Bit Sync CLock Cycle Counter
    signal bitCntr    : integer range 0 to bitWidth - 1; -- Clocked bits counter

    -- Inputs
    signal ph1inSig : std_logic_vector(bitWidth - 1 downto 0); -- Phone 1 Data Input
    signal ph2inSig : std_logic_vector(bitWidth - 1 downto 0); -- Phone 2 Data Input
    signal ph3inSig : std_logic_vector(bitWidth - 1 downto 0); -- Phone 3 Data Input
    signal ph4inSig : std_logic_vector(bitWidth - 1 downto 0); -- Phone 4 Data Input

    signal validSig : std_logic; -- Data Valid Signal

    -- Outputs
    signal lrClock   : std_logic := '0'; -- Frame Sync Clock output
    signal bitClock  : std_logic := '0'; -- Bit Sync Clock output

    signal readySig     : std_logic := '0'; -- Data Ready Signal

    -- State Maintenance
    signal firstBit  : boolean := TRUE;  -- First bit flag
    signal firstWord : boolean := TRUE;  -- First word flag

    begin -- Concurrent Statements & Component Instantiation

        -- Physical Connections to variables
        -- Clocks
        LRCLK  <= lrClock;   -- Connect Frame Sync
        BCLK   <= bitClock;  -- Connect Bit Sync

        -- Data Validation
        READY    <= readySig;  -- Connect Data Ready
        validSig <= VALID;     -- Connect Data Valid

        ------------------------------------------------
        LRCLK_PROC: process(MCLK)  -- Frame Sync Clock
        ------------------------------------------------
        begin
            if(ENABLE = '1') then
                -- Transition at clock rise
                if(rising_edge(MCLK)) then
                    if (lrClkCntr = lrClkCntMax) then
                        lrClock <= not lrClock;
                        lrClkCntr <= 0;
                    else
                        lrClkCntr <= lrClkCntr + 1;
                    end if;
                end if;
            else
                lrClock <= '0';
            end if;
        end process LRCLK_PROC;

        ------------------------------------------------
        BITSYNC_PROC: process(MCLK)  -- Bit Sync Clock
        ------------------------------------------------
        begin
            if(ENABLE = '1') then
                -- Transition LRCLK Rise
                if(rising_edge(MCLK)) then
                    if (bitClkCntr = bitClkCntMax) then
                        bitClock <= not bitClock;
                        bitClkCntr <= 0;
                    else
                        bitClkCntr <= bitClkCntr + 1;
                    end if;
                end if;
            else
                bitClock <= '0';
            end if;
        end process BITSYNC_PROC;

        ------------------------------------------------
        DATA_PROC: process(MCLK)  -- Data Processing
        ------------------------------------------------
        -- Note that when syncing bits in the I2S standard,
        -- there is a 1 bit sync cycle delay after frame sync
        -- has toggled to the respective channel.
        begin
        
            if (rising_edge(MCLK)) then
                if (ENABLE = '1') then
                    -- Start clocking data when data is valid and drive the ready flag low
                    if(valid = '1') then
                        -- Drive ready low while clocking out data
                        readySig <= '0';
                        -- If we're on the falling edge of the bit clock, change the data
                        if (bitClkCntr = 0 and bitClock = '1') then

                            -- Check bit counter
                            if (bitCntr = bitCntMax) then
                                bitCntr <= 0;
                            else
                                bitCntr <= bitCntr + 1;
                            end if;

                            -- Check to see if this is the first bit
                            if (firstBit = TRUE) then
                                PHONE1 <= '0';
                                PHONE2 <= '0';
                                PHONE3 <= '0';
                                PHONE4 <= '0';
                            
                                firstBit <= FALSE;
                            end if;

                            -- If not the first bit, proceed with data output
                            if (firstBit = FALSE) then

                                -- Alternate through the two channels
                                if(firstWord = TRUE) then
                                    PHONE1 <= ph1inSig(bitCntr);
                                    PHONE2 <= ph2inSig(bitCntr);
                                    PHONE3 <= ph3inSig(bitCntr);
                                    PHONE4 <= ph4inSig(bitCntr);

                                    firstWord <= FALSE;
                                else
                                    PHONE1 <= ph1inSig(bitCntr);
                                    PHONE2 <= ph2inSig(bitCntr);
                                    PHONE3 <= ph3inSig(bitCntr);
                                    PHONE4 <= ph4inSig(bitCntr);

                                    firstWord <= TRUE;
                                end if;
                            end if;
                        end if;

                        -- Drive ready high after we've clocked out the last bit.
                        if (bitCntr = bitCntMax and bitClkCntr = 0 and bitClock = '1') then
                            ready <= '1';
                        end if;

                    else
                        PHONE1 <= '0';
                        PHONE2 <= '0';
                        PHONE3 <= '0';
                        PHONE4 <= '0';
                    end if;
                end if;
            end if;

        end process DATA_PROC;

    end architecture RTL;

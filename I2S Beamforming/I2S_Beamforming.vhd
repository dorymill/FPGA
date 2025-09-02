------------------------------------------------
-- The purpose of this project is to produce
-- a beamformed CW output from a linear array
-- of four speakers, with the capability of
-- switching from an in-phase mode to endfire
-- mode.

-- Quadspi: S25FL032
-- Author: dmmill

------------------------------------------------
-- Libraries
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------
entity ENDFIRE is
------------------------------------------------

    generic ( -- Constants 

        mClkFreq  : integer := 30720000;  -- Master Clock Frequency
        lrClkFreq : integer := 96000;     -- Frame Sync Clock Frequency (f_s = 96 kHz Audio)
        bitWidth  : integer := 16;        -- Audio Data Size
        nChan     : integer := 2;         -- Number of Channels
        tableSize : integer := 4096       -- Sine Table Depth

    );

    port ( -- Physical IO defined in XDC file

        MODE   : in std_logic; -- Endfire switch
        ENABLE : in std_logic; -- Reset
        MCLK   : in std_logic; -- Master Clock
        
        LRCLK   : out std_logic; -- Frame Sync Clock
        BCLK    : out std_logic; -- Bit Sync Clock
        PHONE1  : out std_logic; -- Phone 1 bit
        PHONE2  : out std_logic; -- Phone 2 bit
        PHONE3  : out std_logic; -- Phone 3 bit
        PHONE4  : out std_logic  -- Phone 4 bit

    );

end entity ENDFIRE;

------------------------------------------------
architecture RTL of ENDFIRE is
------------------------------------------------

    -- Components

        -- PLL Component
    component clk_wiz_0
        port
        (
            clk_in1  : in  std_logic; -- Clock in ports
            clk_out1 : out std_logic; -- Clock out ports 
            reset    : in  std_logic; -- Status and control signals
            locked   : out std_logic  -- PLL lock status
        );

    end component;

    -- Constants
    constant lrClkCntMax  : integer := (mClkFreq / lrClkFreq) - 1;                  -- Clock cycles per frame sync cycle (mClk/f_s)
    constant bitClkCntMax : integer := (mclkFreq / (lrClkFreq*nChan*bitWidth)) - 1; -- Frame Sync cycles per N Channels of words (f_s*channels*data width)
    constant bitCntMax    : integer := bitWidth - 1;                                -- Data width
    constant endfireDelay : integer := 0;                                           -- Phone 2 & 4 Endfire delay (TBD)
    
    -- Signals

        -- Counters
    signal lrClkCntr  : integer range 0 to lrClkCntMax;  -- Frame Sync Clock Cycle Counter
    signal bitClkCntr : integer range 0 to bitClkCntMax; -- Bit Sync CLock Cycle Counter
    signal bitCntr    : integer range 0 to bitWidth - 1; -- Clocked bits counter

        -- Outputs
    signal lrClock   : std_logic := '0'; -- Frame Sync Clock output
    signal bitClock  : std_logic := '0'; -- Bit Sync Clock output
    signal p13bit    : std_logic := '0'; -- Phone 1 I2S output bit
    signal p24bit    : std_logic := '0'; -- Phone 2 I2S output bit
    signal I2SCLK    : std_logic := '0'; -- I2S Component output
    signal locked    : std_logic := '0'; -- PLL lock status
    signal resetn    : std_logic := '0'; -- PLL reset (active high)

        -- State Maintenance
    signal firstBit  : boolean := TRUE;  -- First bit flag
    signal firstWord : boolean := TRUE;  -- First word flag

        -- Test Signals
    signal fakeData  : std_logic_vector(bitWidth - 1 downto 0) := "1000000100000000"; -- Fake data word

    begin -- Concurrent Statements & Component Instantiation

        -- Component Init
        PLL_inst : clk_wiz_0
            port map ( 
                clk_in1 => MCLK,
                clk_out1 => I2SCLK,
                reset => resetn                      
            );

        -- Physical Connections to variables
            -- Internal
        LRCLK  <= lrClock;   -- Connect Frame Sync
        BCLK   <= bitClock;  -- Connect Bit Sync

            -- External
        PHONE1  <= p13bit; -- Connect Phone Outputs
        PHONE2  <= p24bit; -- Opposing phones will always
        PHONE3  <= p13bit; -- be in phase in the endfire
        PHONE4  <= p24bit; -- case, reducing overall internal signals.

        ------------------------------------------------
        LRCLK_PROC: process(I2SCLK)  -- Frame Sync Clock
        ------------------------------------------------
        begin
            if(ENABLE = '1') then
                -- Transition at clock rise
                if(rising_edge(I2SCLK)) then
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
        BITSYNC_PROC: process(I2SCLK)  -- Bit Sync Clock
        ------------------------------------------------
        begin
            if(ENABLE = '1') then
                -- Transition LRCLK Rise
                if(rising_edge(I2SCLK)) then
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
        DATA_PROC: process(bitClock)  -- Data Processing
        ------------------------------------------------
        begin
            if (ENABLE = '1') then
            -- Note that when syncing bits in the I2S standard,
            -- there is a 1 bit sync cycle delay after frame sync
            -- has toggled to the respective channel.
                if (falling_edge(bitClock)) then

                    -- Check bit counter
                    if (bitCntr = bitCntMax) then
                        bitCntr <= 0;
                    else
                        bitCntr <= bitCntr + 1;
                    end if;

                    -- In Phase Mode
                    if (MODE = '0') then

                        -- Check to see if this is the first bit
                        if (firstBit = TRUE) then
                            p13bit <= '0';
                            p24bit <= '0';
                            firstBit <= FALSE;
                        end if;

                        -- If not the first bit, proceed with data output
                        if (firstBit = FALSE) then

                            -- Alternate through the two channels
                            if(firstWord = TRUE) then
                                p13bit <= fakeData(bitWidth - 1 - bitCntr);
                                p24bit <= fakeData(bitWidth - 1 - bitCntr);
                                firstWord <= FALSE;
                            else
                                p13bit <= fakeData(bitWidth - 1 - bitCntr);
                                p24bit <= fakeData(bitWidth - 1 - bitCntr);
                                firstWord <= TRUE;
                            end if;
                        end if;

                    -- Endfire Mode
                    elsif (MODE = '1') then 

                    end if;
                    
                end if;

            else
                p13bit <= '0';
                p24bit <= '0';
            end if;

        end process DATA_PROC;

    end architecture RTL;

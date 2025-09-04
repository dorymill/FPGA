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
        fsClkFreq : integer := 96000;     -- Frame Sync Clock Frequency (f_s = 96 kHz Audio)
        bitWidth  : integer := 16;        -- Audio Data Size
        nChan     : integer := 2          -- Number of Channels

    );

    port ( -- Physical IO defined in XDC file

        ENABLE   : in std_logic; -- Reset
        MCLK     : in std_logic; -- Master Clock
        VALID    : in std_logic; -- Data Valid Signal

        DIN1     : in std_logic_vector(bitWidth - 1 downto 0); -- Phone 1 Data Input
        -- DIN2     : in std_logic_vector(bitWidth - 1 downto 0); -- Phone 2 Data Input
        -- DIN3     : in std_logic_vector(bitWidth - 1 downto 0); -- Phone 3 Data Input
        -- DIN4     : in std_logic_vector(bitWidth - 1 downto 0); -- Phone 4 Data Input

        PHONE1   : out std_logic; -- Phone 1 bit output
        -- PHONE2   : out std_logic; -- Phone 2 bit output
        -- PHONE3   : out std_logic; -- Phone 3 bit output
        -- PHONE4   : out std_logic; -- Phone 4 bit output
        
        LRCLK    : out std_logic; -- Frame Sync Clock
        BCLK     : out std_logic; -- Bit Sync Clock
        READY    : out std_logic -- Data Ready Signal

    );

end entity I2S;

------------------------------------------------
architecture RTL of I2S is
------------------------------------------------

    -- Constants
    constant fsClkCntMax  : integer := (mClkFreq / fsClkFreq) - 1;                  -- Clock cycles per frame sync cycle (mClk/f_s)
    constant bitClkCntMax : integer := (mclkFreq / (fsClkFreq*nChan*bitWidth)) - 1; -- Frame Sync cycles per N Channels of words (f_s*channels*data width)
    constant bitCntMax    : integer := bitWidth - 1;                                -- Data width
    
    -- Signals
    -- Counters
    signal fsClkCntr  : integer := 0;  -- Frame Sync Clock Cycle Counter
    signal bitClkCntr : integer := 0; -- Bit Sync CLock Cycle Counter
    signal bitCntr    : integer := 0; -- Clocked bits counter

    -- Inputs
    signal en      : std_logic; -- Enable
    signal d1InReg : std_logic_vector(bitWidth - 1 downto 0); -- Phone 1 Data Input
    -- signal ph2inSig : std_logic_vector(bitWidth - 1 downto 0); -- Phone 2 Data Input
    -- signal ph3inSig : std_logic_vector(bitWidth - 1 downto 0); -- Phone 3 Data Input
    -- signal ph4inSig : std_logic_vector(bitWidth - 1 downto 0); -- Phone 4 Data Input

    signal validSig : std_logic := '1'; -- Data Valid Signal

    -- Outputs
    signal fsClk     : std_logic := '0'; -- Frame Sync Clock output
    signal bitClk    : std_logic := '0'; -- Bit Sync Clock output
    signal readySig  : std_logic := '1'; -- Data Ready Signal
    signal d1Out     : std_logic := '0'; -- Phone 1 bit output

    -- Maintenance
    signal d1ShiftReg : std_logic_vector(2*bitWidth - 1 downto 0) := (others => '0'); -- Phone 1 Shift Register


    begin -- Concurrent Statements & Component Instantiation

        -- Physical Connections to variables
        -- Clocks
        LRCLK <= fsClk;   -- Connect Frame Sync
        BCLK   <= bitClk;  -- Connect Bit Sync

        -- Data Validation
        READY    <= readySig;  -- Connect Data Ready
        validSig <= VALID;     -- Connect Data Valid

        -- Data Inputs
        en      <= ENABLE;        -- Connect Enable
        d1InReg <= DIN1;  -- Connect Phone 1 Data Input
        -- ph2inSig <= DIN2;  -- Connect Phone 2 Data Input
        -- ph3inSig <= DIN3;  -- Connect Phone 3 Data Input
        -- ph4inSig <= DIN4;  -- Connect Phone 4 Data Input

        -- Data Outputs
        PHONE1 <= d1Out;  -- Connect Phone 1 bit output

        ------------------------------------------------
        FSCLK_PROC: process(MCLK)  -- Frame Sync Clock
        ------------------------------------------------
        begin
            if(rising_edge(MCLK)) then
                if(ENABLE = '1') then
                -- Transition at clock rise
                    if (fsClkCntr = fsClkCntMax) then
                        fsClk <= not fsClk;
                        fsClkCntr <= 0;
                    else
                        fsClkCntr <= fsClkCntr + 1;
                    end if;
                else
                    fsClk <= '0';
                end if;
            end if;
        end process FSCLK_PROC;

        ------------------------------------------------
        BITSYNC_PROC: process(MCLK)  -- Bit Sync Clock
        ------------------------------------------------
        begin
            if(rising_edge(MCLK)) then
                if(ENABLE = '1') then
                -- Transition fsClk Rise
                    if (bitClkCntr = bitClkCntMax) then
                        bitClk <= not bitClk;
                        bitClkCntr <= 0;
                    else
                        bitClkCntr <= bitClkCntr + 1;
                    end if;
                else
                    bitClk <= '0';
                end if;
            end if;
        end process BITSYNC_PROC;

        ------------------------------------------------
        DATA_PROC: process(MCLK)  -- Data Clocking
        ------------------------------------------------
        begin
            if(rising_edge(MCLK)) then
                if(ENABLE = '1') then
                    -- We change data on falling bit clock edges
                    if(bitClk = '1' and bitClkCntr = bitClkCntMax) then
                        -- Shift data out
                        d1Out <= d1ShiftReg(2*bitWidth - 1);
                        d1ShiftReg <= d1ShiftReg(2*bitWidth - 2 downto 0) & '0';

                        -- Increment bit counter
                        if(bitCntr = 2*bitWidth -1) then
                            bitCntr <= 0;
                        else
                            bitCntr <= bitCntr + 1;
                        end if;

                    end if;

                    -- Reload shift register after all bits are clocked out
                    if(readySig = '1' and validSig = '1') then
                        d1ShiftReg <= d1InReg & d1InReg;
                    end if;

                end if;

            end if;

        end process DATA_PROC;

        ------------------------------------------------
        READY_PROC: process(MCLK)  -- Ready Signal Proc
        ------------------------------------------------
        begin
            if(rising_edge(MCLK)) then
                if(ENABLE = '1') then
                    -- Drive ready on the falling edge after the last bit is clocked out
                    if(bitClk = '1' and bitClkCntr = bitClkCntMax and bitCntr = 0) then
                        readySig <= '1';
                    else
                        readySig <= '0';
                    end if;
                end if;
            end if;

        end process READY_PROC;

    end architecture RTL;

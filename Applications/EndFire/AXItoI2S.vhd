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
entity AXIToI2S is
------------------------------------------------

    generic ( -- Constants 

        mClkFreq  : integer := 24576000;  -- Master Clock Frequency
        fsClkFreq : integer := 96000;     -- Frame Sync Clock Frequency (f_s = 96 kHz Audio)
        bitWidth  : integer := 16;        -- Audio Data Size
        nChan     : integer := 2          -- Number of Channels

    );

    port ( -- Physical IO defined in XDC file


        ENABLE   : in std_logic; -- Reset
        MCLK     : in std_logic; -- Master Clock

        -- I2S Input Data Words
        DIN1     : in std_logic_vector(bitWidth - 1 downto 0); -- Phone 1 Data Input
        DIN2     : in std_logic_vector(bitWidth - 1 downto 0); -- Phone 2 Data Input

        PHONE1   : out std_logic; -- Phone 1 bit output
        PHONE2   : out std_logic; -- Phone 2 bit output
        
        LRCLK    : out std_logic; -- Frame Sync Clock
        BCLK     : out std_logic; -- Bit Sync Clock
        READY    : out std_logic  -- Rx Data Ready Signal

    );

end entity AXIToI2S;

------------------------------------------------
architecture RTL of AXIToI2S is
------------------------------------------------

    -- Constants
    constant fsClkCntMax  : integer := (mClkFreq / fsClkFreq) - 1;                  -- Clock cycles per frame sync cycle (mClk/f_s)
    constant bitClkCntMax : integer := (mclkFreq / (fsClkFreq*nChan*bitWidth)) - 1; -- Frame Sync cycles per N Channels of words (f_s*channels*data width)
    constant bitCntMax    : integer := bitWidth - 1;                                -- Data width
    
    type EDGE_TYPE is (RISING, FALLING);

    -- Signals
    -- Counters
    signal bitCntr    : integer := bitCntMax; -- Clocked bits counter
    signal fsClkCntr  : integer;              -- Frame Sync Clock Cycle Counter
    signal bitClkCntr : integer;              -- Bit Sync CLock Cycle Counter

    -- Inputs
    signal en      : std_logic; -- Enable
    signal d1InReg : std_logic_vector(bitWidth - 1 downto 0) := (others => '0'); -- Phone 1 Serial Output
    signal d2InReg : std_logic_vector(bitWidth - 1 downto 0) := (others => '0'); -- Phone 2 Serial Output

    signal bitTransition : std_logic; -- Bit Clock Shift Signal
    
    -- Outputs
    signal fsClk         : std_logic; -- Frame Sync Clock output
    signal bitClk        : std_logic; -- Bit Sync Clock output
    
    -- Maintenance
    signal readySig   : std_logic; -- Data Ready Signal
    signal bitClkLast : std_logic; -- BCLK edge detection signal
    

    begin -- Concurrent Statements & Component Instantiation

        -- Clocks
        LRCLK <= fsClk;   -- Connect Frame Sync
        BCLK  <= bitClk;  -- Connect Bit Clock
       
        -- Data Validation
        READY    <= readySig;  -- Connect Data Ready

        -- Data Inputs
        en      <= ENABLE;        -- Connect Enable

        -- Data Outputs
        PHONE1 <= d1InReg(bitCntr);
        PHONE2 <= d2InReg(bitCntr);

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
                    fsClkCntr <= 0;
                    fsClk     <= '0';
                end if;
            end if;
        end process FSCLK_PROC;

        ------------------------------------------------
        BITSYNC_PROC: process(MCLK)  -- Bit Sync Clock
        ------------------------------------------------
        begin
            if(rising_edge(MCLK)) then
                if(ENABLE = '1') then
                    -- Transition BCLK fsClk Rise
                    if (bitClkCntr = bitClkCntMax) then
                        bitClk <= not bitClk;
                        bitClkCntr <= 0;
                    else
                        bitClkCntr <= bitClkCntr + 1;
                    end if;

                    -- Request new data on the falling edge when we reset
                    if (bitCntr = 0 and bitClk = '0' and fsClk = '0' and bitClkLast = '1') then
                        readySig <= '1';
                    else 
                        readySig <= '0';
                    end if;

                else
                    bitClkCntr <=  0;
                    bitClk     <= '0';
                    readySig   <= '0';
                end if;
            end if;
        end process BITSYNC_PROC;

        ------------------------------------------------
        DIN_PROC: process(MCLK)  -- Data In Clocking
        ------------------------------------------------
        begin
            if(rising_edge(MCLK)) then
                if(ENABLE = '1') then
                    if readySig = '1' then
                        d1InReg <= DIN1;
                        d2InReg <= DIN2;
                    end if;
                else
                    d1InReg <= (others => '0');
                    d2InReg <= (others => '0');
                end if;
            end if;
        end process DIN_PROC;

        
        ------------------------------------------------
        -- These processes will drive the bit counting
        -- mechanism, which will drive the serial 
        -- data clocking mechanism.
        ------------------------------------------------
        BITCOUNT_PROCESS: process(MCLK)
        begin
            if rising_edge(MCLK) then
                if ENABLE = '1' then

                    bitClkLast <= bitClk;

                    if bitClkCntr = bitClkCntMax and bitClk = '1' and bitCntr /= 0 then
                        bitCntr <= bitCntr - 1;
                    elsif bitClkCntr = bitClkCntMax and bitClk = '1' and bitCntr = 0 then
                        bitCntr <= bitCntMax;
                    end if;
                else
                    -- This reset handles the justification. Setting bitCntr to bitCntMax
                    -- shifts us to the left one bit into Right Justification.
                    bitCntr    <= 0;
                    bitClkLast <= '0';
                end if;
            end if;
        end process;

    end architecture RTL;

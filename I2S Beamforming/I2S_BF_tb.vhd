------------------------------------------------
-- Test Bench Template from page 204 of 
-- Practical Digital Design by Bruce Reidenbach

-- Author: dmmill

------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity ENDFIRE_TB is
end entity ENDFIRE_TB;

------------------------------------------------
architecture SIM of ENDFIRE_TB is
------------------------------------------------

    -- UUT Component Declaration
    component ENDFIRE
    generic ( -- Constants 

        mClkFreq  : integer := 49152000;  -- Master Clock Frequency
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
    end component;

    -- UUT Constant and Signal Declaration
    constant mClkFreq  : integer := 49152000;  -- Master Clock Frequency
    constant lrClkFreq : integer := 96000;     -- Frame Sync Clock Frequency (f_s = 96 kHz Audio)
    constant bitWidth  : integer := 16;        -- Audio Data Size
    constant nChan     : integer := 2;         -- Number of Channels
    constant tableSize : integer := 4096;       -- Sine Table Depth

    constant lrClkCntMax  : integer := mClkFreq / lrClkFreq;                  -- Clock cycles per frame sync cycle (mClk/f_s)
    constant bitClkCntMax : integer := mclkFreq / (lrClkFreq*nChan*bitWidth); -- Frame Sync cycles per N Channels of words (f_s*channels*data width)
    constant bitCntMax    : integer := bitWidth;                              -- Data width
    constant endfireDelay : integer := 0;                                     -- Phone 2 & 4 Endfire delay (TBD)
    
    -- Signals

        -- Counters
    signal lrClkCntr  : integer range 0 to lrClkCntMax;  -- Frame Sync Clock Cycle Counter
    signal bitClkCntr : integer range 0 to bitClkCntMax; -- Bit Sync CLock Cycle Counter
    signal bitCntr    : integer range 0 to bitWidth - 1; -- Clocked bits counter
    signal bitDelay   : integer range 0 to 1;            -- I2S Standard bit delay

        -- Outputs
    signal lrClock   : std_logic := '0'; -- Frame Sync Clock output
    signal bitClock  : std_logic := '0'; -- Bit Sync Clock output
    signal p13bit    : std_logic := '0'; -- Phone 1 I2S output bit
    signal p24bit    : std_logic := '0'; -- Phone 2 I2S output bit

    signal MODE   : std_logic; -- Endfire switch
    signal ENABLE : std_logic; -- Reset
    signal MCLK   : std_logic; -- Master Clock
            
    signal LRCLK  : std_logic; -- Frame Sync Clock
    signal BCLK   : std_logic; -- Bit Sync Clock
    signal PHONE1 : std_logic; -- Phone 1 bit
    signal PHONE2 : std_logic; -- Phone 2 bit
    signal PHONE3 : std_logic; -- Phone 3 bit
    signal PHONE4 : std_logic; -- Phone 4 bit

    constant TCLK : time    := 20.345052 ns;
    signal   DONE : boolean := FALSE;

    begin

    ------------------------------------------------
    -- Unit Under Test
    ------------------------------------------------
    UUT : ENDFIRE
        generic map(

            -- Constants
            mClkFreq  => 49152000,  -- Master Clock Frequency
            lrClkFreq => 96000,     -- Frame Sync Clock Frequency (f_s = 96 kHz Audio)
            bitWidth  => 16,        -- Audio Data Size
            nChan     => 2,         -- Number of Channels
            tableSize => 4096       -- Sine Table Depth

        )

        port map(
            MODE,   -- Endfire switch
            ENABLE, -- Reset
            MCLK,   -- Master Clock
            
            LRCLK,  -- Frame Sync Clock
            BCLK,   -- Bit Sync Clock
            PHONE1, -- Phone 1 bit
            PHONE2, -- Phone 2 bit
            PHONE3, -- Phone 3 bit
            PHONE4  -- Phone 4 bit
        );


        ------------------------------------------------
        -- Clock & Reset Driver
        ------------------------------------------------
        process begin
            ENABLE <= '0', '1' after TCLK;
            MCLK   <= '0';
            wait for 2 * TCLK;
            while not DONE loop
                MCLK <= '1', '0' after TCLK / 2;
                wait for TCLK;
            end loop;
            report "Simulation complete." severity note;
            wait;
        end process;

        ------------------------------------------------
        -- Input Data Driver
        ------------------------------------------------
        process begin
            wait;
        end process;

        ------------------------------------------------
        -- Output Data Monitor
        ------------------------------------------------
        process begin

            -- Behavioral model

            -- Assertion statements
            wait;
        end process;
        
end architecture;
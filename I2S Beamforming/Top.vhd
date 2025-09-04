------------------------------------------------
-- Top Level Endfire Design
--
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
entity Top is
------------------------------------------------

    port ( -- Physical IO defined in XDC file

        -- Inputs
        ENABLE   : in std_logic; -- Reset
        MCLK     : in std_logic;  -- Master Clock
        VALID    : in std_logic; -- Data Valid Signal
        
        -- Outputs
        LED      : out std_logic_vector(15 downto 0);  -- Output LED's
        PHONE1   : out std_logic; -- Phone 1 bit output
        -- PHONE2   : out std_logic; -- Phone 2 bit output
        -- PHONE3   : out std_logic; -- Phone 3 bit output
        -- PHONE4   : out std_logic; -- Phone 4 bit output
        
        LRCLK    : out std_logic; -- Frame Sync Clock
        BCLK     : out std_logic; -- Bit Sync Clock
        READY    : out std_logic -- Data Ready Signal

    );



end entity Top;

------------------------------------------------
architecture RTL of Top is
------------------------------------------------

    -- PLL Component
    component clk_wiz_0
        port (
            CLK_IN1    : in  std_logic;
            CLK_OUT1   : out std_logic;
            RESET      : in  std_logic;
            LOCKED     : out std_logic
        );
    end component;

    -- I2S Component
    component I2S
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

    end component;

    -- LED Sweep Component
    component LED_SWEEP
        port (
            CLK    : in  std_logic;
            ENABLE : in  std_logic;
            LED    : out std_logic_vector(15 downto 0)
        );
    end component;

    -- Connecting Signals
    signal i2sclk   : std_logic := '0';
    signal dummyData : std_logic_vector(15 downto 0) := "1000000000000001";

    begin

        -- Instantiate the PLL
        PLL_inst : clk_wiz_0
            port map (
                CLK_IN1  => MCLK,
                CLK_OUT1 => i2sclk,
                RESET    => '0',
                LOCKED   => open
            );

        -- Instantiate the I2S Module
        I2S_inst : I2S
            generic map(
                mClkFreq  => 30720000,
                fsClkFreq => 96000,
                bitWidth  => 16,
                nChan     => 2
            )
            port map(
                ENABLE   => ENABLE,
                MCLK     => i2sclk,
                VALID    => '1',
                DIN1     => dummyData,
                -- DIN2     => (others => '0'),
                -- DIN3     => (others => '0'),
                -- DIN4     => (others => '0'),
                PHONE1   => PHONE1,
                -- PHONE2   => open,
                -- PHONE3   => open,
                -- PHONE4   => open,
                LRCLK    => LRCLK,
                BCLK     => BCLK,
                READY    => READY
            );

        -- Instantiate the LED Sweep Module
        LED_inst : LED_SWEEP
            port map(
                CLK    => MCLK,
                ENABLE => ENABLE,
                LED    => LED
            );

end architecture RTL;

------------------------------------------------
-- Test Bench Template from page 204 of 
-- Practical Digital Design by Bruce Reidenbach

-- Author: dmmill

------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity I2S_TB is
end entity I2S_TB;

------------------------------------------------
architecture SIM of I2S_TB is
------------------------------------------------

    -- UUT Component Declaration
    component I2S
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

            DIN1     : in std_logic_vector(bitWidth - 1 downto 0); -- Phone 1 Data Input
            DIN2     : in std_logic_vector(bitWidth - 1 downto 0); -- Phone 2 Data Input
            DIN3     : in std_logic_vector(bitWidth - 1 downto 0); -- Phone 3 Data Input
            DIN4     : in std_logic_vector(bitWidth - 1 downto 0); -- Phone 4 Data Input

            PHONE1   : out std_logic; -- Phone 1 bit output
            PHONE2   : out std_logic; -- Phone 2 bit output
            PHONE3   : out std_logic; -- Phone 3 bit output
            PHONE4   : out std_logic; -- Phone 4 bit output
            
            LRCLK    : out std_logic; -- Frame Sync Clock
            BCLK     : out std_logic; -- Bit Sync Clock
            READY    : out std_logic -- Data Ready Signal

        );

    end component;
    
    -- Signals
    -- Outputs to UUT
    signal enable : std_logic := '1'; -- Reset
    signal mclk   : std_logic := '0'; -- Master Clock
    signal valid  : std_logic := '1'; -- Data Valid Signal
            
    signal ph1din : std_logic_vector (bitWdith - 1 downto 0) := "1000010000000000"; -- Phone 1 data input
    signal ph2din : std_logic_vector (bitWdith - 1 downto 0) := "1000010000000000"; -- Phone 2 data input
    signal ph3din : std_logic_vector (bitWdith - 1 downto 0) := "1000010000000000"; -- Phone 3 data input
    signal ph4din : std_logic_vector (bitWdith - 1 downto 0) := "1000010000000000"; -- Phone 4 data input

    constant CFR   : real    := 30.72e6;     -- Crystal Frequency
    constant TCLK  : time    := 1 sec / CFR; --I2S CLK Frequency

    signal   DONE  : boolean := FALSE;

    begin

    -- Wire the test bench to the UUT
    ENABLE <= enable;
    MCLK   <= mclk;
    VALID  <= valid;

    DIN1  <= ph1din;
    DIN2  <= ph2din;
    DIN3  <= ph3din;
    DIN4  <= ph4din;

    ------------------------------------------------
    -- Unit Under Test
    ------------------------------------------------
    UUT : ENDFIRE
        generic map(

            -- Constants
            mClkFreq  => 30720000,  -- Master Clock Frequency
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
            enable <= '0', '1' after TCLK;
            mclk   <= '0';
            wait for 2 * TCLK;
            while not DONE loop
                mclk <= '1', '0' after TCLK / 2;
                wait for TCLK;
            end loop;
            report "Simulation complete." severity note;
            wait;
        end process;

        ------------------------------------------------
        -- Input Data Driver
        ------------------------------------------------

        -- Drive the valid and data signals
        process begin

            valid <= '1';

            wait;
        end process;

        ------------------------------------------------
        -- Output Data Monitor
        ------------------------------------------------
        process begin



            wait;
        end process;
        
end architecture;
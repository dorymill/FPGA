------------------------------------------------
-- Test Bench Template from page 204 of 
-- Practical Digital Design by Bruce Reidenbach

-- Author: dmmill

------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity TestBench is
end entity TestBench;

------------------------------------------------
architecture AXIS_RAM_SIM of TestBench is
------------------------------------------------
    -- UUT Component Declaration
------------------------------------------------
    component AXIS_RAM is
        generic ( -- Constants

            ramWidth : natural; -- Width in bits of the RAM DAta bus
            ramDepth : natural  -- Number of ramWidth size "slots" available 

        );

        port ( -- I/O

            CLK : in std_logic;  -- Master Clock
            RST : in std_logic;  -- Reset Line

            -- AXI Stream Input Lines
            RXREADY : out std_logic;
            RXVALID : in std_logic;
            RXDATA  : in std_logic_vector(ramWidth - 1 downto 0);

            -- AXI Stream Output Lines
            TXREADY : in std_logic;
            TXVALID : out std_logic;
            TXDATA  : out std_logic_vector(ramWidth - 1 downto 0)

        );
    end component;


    begin

    ------------------------------------------------
    -- Unit Under Test
    ------------------------------------------------
    UUT : 

        ------------------------------------------------
        -- Clock & Reset Driver
        ------------------------------------------------
        process begin
            ENABLE <= '0', '1' after TCLK;
            CLK   <= '0';
            wait for 2 * TCLK;
            while not DONE loop
                CLK <= '1', '0' after TCLK / 2;
                wait for TCLK;
            end loop;
            report "Simulation complete." severity note;
            wait;
        end process;

        ------------------------------------------------
        -- Input Data Driver
        ------------------------------------------------
        process begin

            -- Signal Initialization
            SW        <= "10000000";

            -- Vibe for a million cycles
            wait for 1000000 * TCLK;

            -- Test Signal generation logic
            DONE <= TRUE;
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
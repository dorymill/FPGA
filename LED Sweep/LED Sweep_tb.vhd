------------------------------------------------
-- Test Bench for LED Sweep from Template 

-- Author: dmmill

------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity TestBench is
end entity TestBench;

------------------------------------------------
architecture LED_SWEEP of TestBench is
------------------------------------------------

    -- UUT Component Declaration
    component LED_SWEEP
    generic(

        cycleTime : integer := 10;
        maxLEDS   : integer := 16

    );

    port (
        -- Outputs
        LED : out std_logic_vector(maxLEDS - 1 downto 0);

        -- Inputs
        ENABLE : in std_logic;
        CLK    : in std_logic

    );

    end component;
    -- UUT Constant and Signal Declaration
    -- Create signals to test with for the port model
    signal   LED    : std_logic_vector(16 - 1 downto 0) := "0000000000000001";
    signal   ENABLE : std_logic;
    signal   CLK    : std_logic;

    constant TCLK   : time      := 10 ns;
    signal   DONE   : boolean   := FALSE;

    begin

    ------------------------------------------------
    -- Unit Under Test
    ------------------------------------------------
    UUT : LED_SWEEP
        generic map(cycleTime => 50)
        port map(LED, ENABLE, CLK);


        ------------------------------------------------
        -- Clock & Reset Driver
        ------------------------------------------------
        process begin
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
            ENABLE <= '0';

            wait for 2 * TCLK;

            -- Test Signal generation logic
            -- Flip Enable a few times for a few clock cycles
            for I in 1 to 20 loop
                ENABLE <= '1';
                wait for 500 * TCLK;
                ENABLE <= '0';
                wait for 500 * TCLK;
            end loop;

            ENABLE <= '0';
            wait for 10 * TCLK;

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
        
end architecture LED_SWEEP;
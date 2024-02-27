-- Simulation model for LED Sweep
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity Test_LED_Sweep is 
end;

architecture Test of Test_LED_Sweep is

    -- Instantiate component of LED_SWEEP
    component LED_SWEEP
    generic (

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

    -- Create signals to test with for the port model
    signal LED    : std_logic_vector(16 - 1 downto 0) := "0000000000000001";
    signal ENABLE : std_logic := '1';
    signal CLK    : std_logic := '1';

    -- Create the stimuli routines
    begin
        test_routine: LED_SWEEP
            generic map(cycleTime => 50)
            port map(LED, ENABLE, CLK);

        -- Drive the enable line high
        enable_stim: process
        begin
            ENABLE <= '1';
            wait;
        end process enable_stim;

        -- This process flips the clock at 100 MHz
        clk_stim: process
        begin   
            wait for 10 ns;
            CLK <= not CLK;
        end process clk_stim;

    end Test;
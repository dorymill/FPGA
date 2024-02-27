-- Simulation model for LED Sweep
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity Test_LED_Sweep is 
end;

architecture Test of Test_LED_Sweep is

    -- Instantiate component of LED_SWEEP
    component LED_SWEEP
    port (
        -- Outputs
        LED : out std_logic_vector(15 downto 0);

        -- Inputs
        ENABLE : in std_logic := '0';
        CLK    : in std_logic := '1'

    );
    end component;

    -- Create signals to test with for the port model
    signal LED    : std_logic_vector(15 downto 0) := (others => '0');
    signal ENABLE : std_logic := '1';
    signal CLK    : std_logic := '1';

    -- Create the stimuli routines
    begin
        test_routine: LED_SWEEP
            port map(LED, ENABLE, CLK);

        -- This process flips the clock at 100 MHz
        clk_stim: process
        begin   
            wait for 10 ns;
            CLK <= not CLK;
        end process clk_stim;

    end Test;
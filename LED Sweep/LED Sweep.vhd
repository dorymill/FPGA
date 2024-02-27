-- Code to sweep through the LEDs cause we love lights!

-- Libraries
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

-- Entity declaration
entity LED_SWEEP is

    generic (

        cycleTime : integer := 5000000;
        maxLEDS   : integer := 16
    );
    
    -- Define the IO
    port (
        -- Outputs
        LED : out std_logic_vector(maxLEDS - 1 downto 0);

        -- Inputs
        ENABLE : in std_logic;
        CLK    : in std_logic

    );

end LED_SWEEP;

-- Architecture
architecture Behavior of LED_SWEEP is

    -- Signals for the routine
    signal clkCounter : integer range 0 to cycleTime := 0;
    signal ledArray   : std_logic_vector(maxLEDS - 1 downto 0) := "0000000000000001";
    signal enableSw   : std_logic;

    begin
        LED    <= ledArray;

        SWEEP: process(CLK)
        begin
            if(ENABLE /= '1') then
                clkCounter <= cycleTime;
                ledArray <= "0000000000000001";
            elsif (rising_edge(CLK)) then
                -- Check to see if we've hit
                -- our timer
                if (clkCounter = 0) then
                    clkCounter <= cycleTime;
                    -- Shift the LED light in a circular fashion
                    ledArray <= ledArray(maxLEDS - 2 downto 0) & ledArray(maxLEDS - 1);
                else
                    clkCounter <= clkCounter - 1;
                end if;
            end if;
        end process SWEEP;

    end Behavior;
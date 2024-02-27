-- Code to sweep through the LEDs cause we love lights!

-- Libraries
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

-- Entity declaration
entity LED_SWEEP is

    generic (

        cycleTime : integer := 5000000;
        maxLEDS   : integer := 15
    );
    
    -- Define the IO
    port (
        -- Outputs
        LED : out std_logic_vector(15 downto 0);

        -- Inputs
        ENABLE : in std_logic := '0';
        CLK    : in std_logic

    );

end LED_SWEEP;

-- Architecture
architecture Behavior of LED_SWEEP is

    -- Signals for the routine
    signal clkCounter : integer range 0 to cycleTime := 0;
    signal ledArray   : std_logic_vector(15 downto 0) := (others => '0');
    signal enableSw   : std_logic;
    signal ledNum     : integer range 0 to 15 := 0;

    begin

        LED    <= ledArray;

        SWEEP: process(CLK)
        begin
            if(ENABLE = '1') then
                -- See if half a second has passsed then turn off current
                -- LED, increment the LED number, and turn it on
                if(clkCounter = cycleTime) then
                    clkCounter <= 0;
                    -- Handle rolling over the LED Number
                    if(ledNum = maxLEDS) then
                        ledNum <= 0;
                        ledArray(maxLEDS) <= '0';
                        ledArray(0) <= '1';

                    -- Otherwise, turn off the current,
                    --increment
                    else
                        ledArray(ledNum) <= '0';
                        ledArray(ledNum + 1) <= '1';
                        end if;
                        
                    ledNum <= ledNum + 1;
                end if;

                if(rising_edge(CLK)) then
                    clkCounter <= clkCounter + 1;
                end if;
              else
                ledArray <= (others => '0');
            end if;
        end process SWEEP;

end Behavior;
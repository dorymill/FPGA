-- Code to sweep through the LEDs cause we love lights!

-- Libraries
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------
entity LED_SWEEP is
------------------------------------------------

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

end entity LED_SWEEP;

------------------------------------------------
architecture Behavior of LED_SWEEP is
------------------------------------------------

    -- Signals for the routine
    signal clkCounter : integer range 0 to cycleTime := 0;
    signal ledArray   : std_logic_vector(maxLEDS - 1 downto 0) := "0000000000000001";
    signal enableSw   : std_logic;

    begin

        LED    <= ledArray;  -- Initialize the physical LED array

        ------------------------------------------------
        SWEEP_PROCESS: process(CLK) is
        ------------------------------------------------

        begin

            -- Drive exterior control flow with direct action signals
            -- and interior with indirect action signals
            if(rising_edge(CLK)) then
                if(ENABLE = '1') then
                    -- Check to see if we've hit
                    -- our timer
                    if(clkCounter = 0) then                         -- Check to see if we need to shift
                        clkCounter <= cycleTime;                    -- Shift LED in a
                        ledArray <= ledArray(maxLEDS - 2 downto 0)  -- circular fashion
                                  & ledArray(maxLEDS - 1);
                    else
                        clkCounter <= clkCounter - 1;               -- Decrement counter
                    end if;
                else
                    -- We could initialize the
                    -- array back to the initial
                    -- position, but leaving the
                    -- LED where it lands is more
                    -- fun!
                    -- ledArray(0) <= '1';
                    -- ledArray(15 downto 1) <= (others=>'0');
                end if;
            end if;

        end process SWEEP_PROCESS;

    end architecture Behavior;

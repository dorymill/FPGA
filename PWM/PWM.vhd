------------------------------------------------
-- Code to output a PWM signal to the LED's!

-- Quadspi: S25FL032
-- Author: dmmill

------------------------------------------------
-- Libraries
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------
entity PWM_GEN is
------------------------------------------------

    generic ( -- Constants

        clockFreq   : integer   := 10000000;   -- Input clock frequency
        maxLEDS     : integer   := 15;         -- Number of LED's
        bitDepth    : integer   := 8;          -- Resolution for Duty Cycle
        pwmFreq     : integer   := 1000        -- PWM Frequency Output


    );

    port ( -- Physical I/O

        LED    : out std_logic_vector(maxLEDS - 1 downto 0);   -- Output LED's

        SW     : in std_logic_vector(bitDepth downto 1);       -- Duty Cycle Switches
        CLK    : in std_logic;                                 -- Input Clock (10 MHz)
        ENABLE : in std_logic                                  -- Enable Switch
    
    );

end entity PWM_GEN;

------------------------------------------------
architecture RTL of PWM_GEN is
------------------------------------------------

    -- Constants
    constant maxCounts : integer := clockFreq / pwmFreq;        -- Clock cycles per PWM period
    constant pwmStep   : integer := maxCounts / (2**bitDepth);  -- Clock cycles per duty step (SW step)

    -- Signals
    signal pwmSignal : std_logic                        := '0';       -- Output PWM Signal to LED's
    signal counter   : integer range 0 to maxCounts     := maxCounts; -- Cycle counter
    signal tLowTrig  : integer range 0 to maxCounts     := 0;         -- Sample number at which we drive low
    signal dutySw    : integer range 0 to (2**bitDepth) := 0;         -- Integer value of the duty switch

    begin

        -- Assign the state of the LED to the PWM signal, and dutySw to the switch value
        dutySw    <= to_integer(unsigned(SW));
        LED       <= (others => pwmSignal);

        ------------------------------------------------
        PWM_PROCESS: process(CLK) is
        ------------------------------------------------

        begin

            -- Check for rising edge
            if(rising_edge(CLK)) then
                -- Check Enable Line
                if (ENABLE = '1') then
                    -- PWM Logic
                    -- Condition to drive high and recalculate tLowTrig
                    if (counter = 0) then
                        tLowTrig  <= maxCounts - (dutySw * pwmStep); 
                        pwmSignal <= '1';
                        counter   <= maxCounts;

                    -- The condition to drive low
                    elsif (counter = tLowTrig) then     
                        pwmSignal <= '0';
                        counter   <= counter - 1;
                   
                    -- Otherwise decrement the counter
                    else                         
                        counter <= counter - 1;

                    end if;

                -- If not enabled, zero the signal and max the counter
                else
                    pwmSignal <= '0';
                    counter   <= maxCounts;
                    
                end if;
            end if;
            
        end process PWM_PROCESS;

    end architecture RTL;
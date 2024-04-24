------------------------------------------------
-- Code to output a PWM signal to the LED's!

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

        clockFreq : integer   := 10000000;
        maxLEDS   : integer   := 15;
        bitDepth  : integer   := 8;
        pwmFreq   : integer   := 100;
        absoluteMax : integer := 65535

    );

    port ( -- Physical I/O

        LED    : out std_logic_vector(maxLEDS - 1 downto 0);
        SW     : in std_logic_vector(bitDepth downto 1);

        CLK    : in std_logic;
        ENABLE : in std_logic
    
    );

end entity PWM_GEN;

------------------------------------------------
architecture RTL of PWM_GEN is
------------------------------------------------

    signal maxCounts : integer range 0 to absoluteMax;    -- Clock cycles per PWM Period
    signal pwmCount  : integer range 0 to absoluteMax;            -- Current PWM clock cycle
    signal dutySw    : std_logic_vector(bitDepth downto 1); -- Duty switch vector
    signal dutyCycle : integer range 0 to 2**bitDepth - 1;      -- Duty Cycle [0,255]
    signal tLowTrig  : integer range 0 to absoluteMax;            -- Off time clock cycle
    signal pwmSignal : std_logic;

    begin

        LED       <= (others => pwmSignal);

        ------------------------------------------------
        PWM_PROCESS: process(CLK, ENABLE) is
        ------------------------------------------------

        begin

            -- Handle duty cycle calculations in delta cycles
            maxCounts <= clockFreq / pwmFreq;
            dutyCycle <= To_integer(unsigned(dutySw));
            tLowTrig  <= (1 - dutyCycle/(2**bitDepth - 1))*maxCounts;

            if (ENABLE = '0') then
                -- Handle enable line
                pwmSignal <= '0';
                pwmCount <= 0;

            elsif (rising_edge(CLK)) then
                -- Handle PWM Signal
                if(pwmCount = tLowTrig) then
                    pwmSignal <= '0';
                elsif(pwmCount = maxCounts) then
                    pwmSignal <= '1';
                end if;

                -- Handle PWM Counter
                if(pwmCount = 0) then
                    pwmCount <= maxCounts;
                else
                    pwmCount <= pwmCount - 1;
                end if;
            end if;

        end process PWM_PROCESS;

    end architecture RTL;
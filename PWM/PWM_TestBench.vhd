------------------------------------------------
-- Test Bench for PWM.vhd

-- Author: dmmill

------------------------------------------------
-- Libraries
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------
entity PWM_GEN_TEST is
------------------------------------------------
end;

------------------------------------------------
architecture Test of PWM_GEN_TEST is
------------------------------------------------

    -- Instantiate component of PWM_GEN_TEST
    ------------------------------------------------
    component PWM_GEN
    ------------------------------------------------
    generic ( -- Constants

        clockFreq : integer := 1000000;
        maxLEDS   : integer := 15;
        bitDepth  : integer := 8;
        pwmFreq   : integer := 100

    );

    port ( -- Physical I/O

        LED    : out std_logic_vector(maxLEDS - 1 downto 0);
        SW     : in std_logic_vector(bitDepth - 1 downto 1);
        
        CLK    : in std_logic;
        ENABLE : in std_logic
    
    );
    end component;

    constant CLKFREQ : integer := 10000;
    constant LEDS    : integer := 15;
    constant BDEPTH  : integer := 8;
    constant PWMFRQ  : integer := 100;

    signal maxCounts : integer range 0 to CLKFREQ/PWMFRQ;    -- Clock cycles per PWM Period
    signal pwmCount  : integer range 0 to maxCounts;            -- Current PWM clock cycle
    signal dutySw    : std_logic_vector(BDEPTH - 1 downto 1); -- Duty switch vector
    signal dutyCycle : integer range 0 to 2**BDEPTH - 1;      -- Duty Cycle [0,255]
    signal tLowTrig  : integer range 0 to maxCounts;            -- Off time clock cycle
    signal pwmSignal : std_logic_vector;


    begin
        ------------------------------------------------
        test_routine: PWM_GEN
        ------------------------------------------------

            generic map(clockFreq => CLKFREQ, maxLEDS => LEDS, bitDepth => BDEPTH, pwmFreq => PWMFRQ)
            port map(LED, SW, CLK, ENABLE);

        ------------------------------------------------
        CLK_STIM: process -- This process flips the clock at 100 MHz
        ------------------------------------------------
        begin   
            wait for 10 ns;
            CLK <= not CLK;
        end process CLK_STIM;

        ------------------------------------------------
        ENABLE_STIM: process -- Drive the enable line high
        ------------------------------------------------
        begin
            ENABLE <= '1';
            wait for 20 us;
            ENABLE <= '0';
            wait for 10 us;
        end process ENABLE_STIM;

        ------------------------------------------------
        DUTY_STIM: process -- Drive the duty cycle switch to 25%
        ------------------------------------------------
        begin
            dutySw <= std_logic_vector(to_unsigned(63, dutySw'length));
            wait;
        end process DUTY_STIM;


    end Test;
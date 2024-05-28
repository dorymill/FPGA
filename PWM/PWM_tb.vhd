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
architecture PWM_GEN of TestBench is
------------------------------------------------

    -- UUT Component Declaration
    component PWM_GEN
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
    end component;

    -- UUT Constant and Signal Declaration
    -- Constants
    constant clockFreq   : integer   := 10000000;   -- Input clock frequency
    constant maxLEDS     : integer   := 15;         -- Number of LED's
    constant bitDepth    : integer   := 8;          -- Resolution for Duty Cycle
    constant pwmFreq     : integer   := 1000;       -- PWM Frequency Output

    constant maxCounts : integer := clockFreq / pwmFreq;        -- Clock cycles per PWM period
    constant pwmStep   : integer := maxCounts / (2**bitDepth);  -- Clock cycles per duty step (SW step)

    -- Signals
    signal LED    : std_logic_vector(maxLEDS - 1 downto 0);     -- Output LED's

    signal SW     : std_logic_vector(bitDepth downto 1);        -- Duty Cycle Switches
    signal CLK    : std_logic;                                  -- Input Clock (10 MHz)
    signal ENABLE : std_logic;                                  -- Enable Switch

    constant TCLK : time    := 10 ns;
    signal   DONE : boolean := FALSE;

    begin

    ------------------------------------------------
    -- Unit Under Test
    ------------------------------------------------
    UUT : PWM_GEN
        generic map(
            clockFreq   => 10000000,
            maxLEDS     => 15,
            bitDepth    => 8,
            pwmFreq     => 1000

        )

        port map(
            LED,
            SW,
            CLK,
            ENABLE
        );

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
            SW        <= "00001000";

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
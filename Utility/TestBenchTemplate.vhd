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
architecture {NAME} of TestBench is
------------------------------------------------

    -- UUT Component Declaration
    -- UUT Constant and Signal Declaration

    constant TCLK : time    := 10 ns;
    signal   DONE : boolean := FALSE;

    begin

    ------------------------------------------------
    -- Unit Under Test
    ------------------------------------------------
    UUT : {NAME}
        generic map(. . .)
        port map(. . .);


        ------------------------------------------------
        -- Clock & Reset Driver
        ------------------------------------------------
        process begin
            RESET <= '1', '0' after TCLK;
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

            wait for 2 * TCLK;

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

        end process;
        
end architecture;
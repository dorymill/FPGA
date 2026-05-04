library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity TestBench is
end entity TestBench;

architecture SIM of TestBench is

    ------------------------------------------------
    -- Entity Component Declarations
    ------------------------------------------------
    component YourEntity is
        generic ( -- Constants
        
            clkFreq : integer := 1000000000; -- Master Clock Frequency
        
        );

        port ( -- External IO
            
            MCLK   : in std_logic; -- Master Clock

        );
    end component;


    ------------------------------------------------
    -- Constants, Types, and Signals
    ------------------------------------------------

    constant mClkFreq   : integer := 100000000;
    constant TCLK       : time    := 10 ns;

    signal enableTb : std_logic := '1';
    signal mclkTb   : std_logic := '0';

    signal DONE     : boolean := FALSE;

    begin

        ------------------------------------------------
        -- Component Instantiations
        ------------------------------------------------
        UUT : YourEntity
            generic map (
                clkFreq => mClkFreq

            )

            port map (
                MCLK   => mclkTb

            );

        ------------------------------------------------
        -- Concurrent Statements
        ------------------------------------------------
        clkSig <= MCLK;


        ------------------------------------------------
        -- Processes
        ------------------------------------------------

        -- Master clock
        ------------------------------------------------
        MASTER_CLOCK_PROCESS : process
        ------------------------------------------------
        begin
            while not DONE loop
                mclkTb <= '0';
                wait for TCLK / 2;
                mclkTb <= '1';
                wait for TCLK / 2;
            end loop;
            wait;
        end process;



        -- Increment DIN1 on each READY pulse
        ------------------------------------------------
        DATA_DRIVE_PROCESS : process
        ------------------------------------------------
        begin

            DONE <= TRUE;
            wait;
        end process;

end architecture SIM;
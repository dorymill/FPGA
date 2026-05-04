------------------------------------------------
-- The purpose of this project is to <TEMPLATE>
-- 
-- Quadspi: S25FL032
-- Author: dmmill

------------------------------------------------
-- Libraries
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------
entity YourEntity is
------------------------------------------------

    generic ( -- Constants
    
        clkFreq : integer := 1000000000; -- Master Clock Frequency
    
    );

    port ( -- External IO
        
        MCLK   : in std_logic; -- Master Clock

    );

end entity YourEntity;

------------------------------------------------
architecture RTL of SevSeg is
------------------------------------------------

    ------------------------------------------------
    -- Constants, Types, and Signals
    ------------------------------------------------
    signal clkSig : std_logic := '0';

    
    ------------------------------------------------
    -- Procedures and Functions
    ------------------------------------------------
    
    begin
        ------------------------------------------------
        -- Concurrent Statements
        ------------------------------------------------
        clkSig <= MCLK;

        ------------------------------------------------
        -- Processes
        ------------------------------------------------

        -- Process description 
        ------------------------------------------------
        YOUR_PROC_1 : process (MCLK)
        ------------------------------------------------
        begin
            if rising_edge(MCLK) then
                -- Logic
            end if;
        end process;

end architecture RTL;
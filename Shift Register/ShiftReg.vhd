------------------------------------------------
-- Implementation of a 4 bit shift register

-- Author: dmmill

------------------------------------------------
-- Libraries
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;


------------------------------------------------
entity SHIFT_REG is     -- Entity declaration
------------------------------------------------
    -- These are physical and would need to match
    -- I/O ports in the xdc file for this board. 
    -- Since these are generic names.
    port (
        -- Outputs
        A : out std_logic; -- LED 0
        B : out std_logic; -- LED 1
        C : out std_logic; -- LED 2
        D : out std_logic; -- LED 3

        -- Inputs
        D_IN : in std_logic; -- SW0
        CLK  : in std_logic; -- CLK
        RST  : in std_logic -- SW1

    );

end SHIFT_REG;


------------------------------------------------
architecture Behavior of SHIFT_REG is   -- Arch.  
------------------------------------------------

    -- These are non-physical
    signal A_reg, B_reg : std_logic := '0';
    signal C_reg, D_reg : std_logic := '0';

    -- Begin the architecture
    begin

        -- Initialize the values to their registers
        -- Doing this provides aliases for our port I/O's
        -- to be used in processes. 
        A <= A_reg;
        B <= B_reg;
        C <= C_reg;
        D <= D_reg;

        
        ------------------------------------------------
        REG_PROCESS: process(CLK)  -- This does work!
        ------------------------------------------------
        begin

            if(rising_edge(CLK)) then
                if(RST = '1') then
                    -- Reset the registers
                    A_reg <= '0';
                    B_reg <= '0';
                    C_reg <= '0';
                    D_reg <= '0';
                else
                    -- Other wise shift
                    A_reg <= D_IN;
                    B_reg <= A_reg;
                    C_reg <= B_reg;
                    D_reg <= C_reg;
                end if;
            end if;
        end process REG_PROCESS;
end Behavior;

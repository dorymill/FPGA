-- Test Bench Script
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity Test_SHIFT_REG is

end;

architecture Test of Test_SHIFT_REG is

    -- We need a component that is what we're testing
    component SHIFT_REG
    port (
        -- Test Outputs
        A : out std_logic;
        B : out std_logic;
        C : out std_logic;
        D : out std_logic;

        -- Test Inputs
        D_IN : in std_logic;
        CLK  : in std_logic;
        RST : in std_logic
    );
    end component;

    signal D_IN : std_logic := '0';
    signal RST  : std_logic := '0';
    signal CLK  : std_logic := '0';
    signal A, B, C, D : std_logic;

    begin
        dev_to_test: SHIFT_REG
            port map(A, B, C, D, D_IN, CLK, RST); -- Instantiate our SHIFT_REG with a port map

        -- This process flips the clock at 100 MHz
        clk_stim: process
        begin   
            wait for 10 ns;
            CLK <= not CLK;
        end process clk_stim;

        -- This process oscillates the D_IN signal at 190 ns
        data_stim: process
        begin
            wait for 40 ns;
            D_IN <= not D_IN;
            wait for 150 ns;
        end process data_stim;
end Test;
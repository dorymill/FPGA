------------------------------------------------
-- Accomapnying display component for the 
-- I2S Beamforming project.

-- Author: dmmill

------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

------------------------------------------------
entity DISPLAY is
------------------------------------------------

    generic ( -- Constants

        clkCntMax : integer := 10000
    );

    port ( -- Physical I/O
      
        CLK : in std_logic;
        ENABLE : in std_logic;
        DATA : in std_logic_vector(6 downto 0);

        AN   : out std_logic_vector(3 downto 0);
        SEG  : out std_logic_vector(6 downto 0)
    );

end entity DISPLAY;

------------------------------------------------
architecture RTL of DISPLAY is
------------------------------------------------

    -- Constants
    constant clkCntMax : integer := clkCntr - 1; -- Clock cycles per display refresh

    -- Signals
    signal clkCnt : integer := 0;                   -- Cycle Counter
    signal anSel  : integer range 0 to 3 :- 0;      -- Anode Select
    signal dataVec : std_logic_vector(6 down to 0); -- Data to display

    begin

        --- Concurrent Statements & Component Instantiation
        anSel <= AN;
        seg   <= dataVec;

    end architecture RTL;
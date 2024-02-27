----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/21/2024 01:06:37 AM
-- Design Name: 
-- Module Name: Blinky - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Not really blinky, but some code to enable some LEDs based
--              on user button presses.
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

 
entity Blinky is
	
  port (
		-- inputs
		Enable: in std_logic;
		BTN:    in  std_logic_vector (4 downto 0);

    --- outputs
		LED:      out std_logic_vector (4 downto 0)
	);
end Blinky;


architecture Behavioral of Blinky is

begin 

  LED <= BTN when Enable = '1' else (others => '0');

end Behavioral;

------------------------------------------------
-- The purpose of this block is to implement
-- an AXI Stream FIFO ROM Cosine table.

-- Quadspi: S25FL032
-- Author: dmmill

------------------------------------------------
-- Libraries
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use ieee.math_real.all;

------------------------------------------------
entity COS_ROM is
------------------------------------------------


    generic ( -- Constants
    
        romWidth  : natural;         -- Width in bits of the ROM bus
        addrWidth : natural := 12;    -- Size of the address (2**N - 1 range)
        romDepth  : natural := 2**12  -- Number of romWidth "slots"
    
    );

    port ( -- I/O
    
        CLK : in std_logic; -- Master Clock

        ADDR1 : in std_logic_vector(addrWidth - 1 downto 0); -- Address 1 in ROM
        ADDR2 : in std_logic_vector(addrWidth - 1 downto 0); -- Address 2 in ROM
        DATA1 : out std_logic_vector(romWidth - 1 downto 0); -- Data out bus
        DATA2 : out std_logic_vector(romWidth - 1 downto 0)  -- Data out bus
    
    );

end entity COS_ROM;

------------------------------------------------
architecture RTL of COS_ROM is
------------------------------------------------

    ------------------------------------------------
    -- Constants, Types, and Signals
    ------------------------------------------------

    -- Declare the ROM type and address signals
    type rom_type is array (0 to romDepth -1)
        of std_logic_vector(romWidth - 1 downto 0);

    signal rom : rom_type;

    signal data1Out : std_logic_vector(romWidth -1 downto 0);
    signal data2Out : std_logic_vector(romWidth -1 downto 0);


    ------------------------------------------------
    -- Procedures and Functions
    ------------------------------------------------

    -- This functional shall initialize the ROM
    -- array at compile time to contain a full
    -- cosine wave, to be later used for wave
    -- generation. (See Test Bench).
    function init_rom return rom_type is
        
        variable data : rom_type;
        variable angle : real;
        variable cVal  : real;
        
        begin
            -- Iteratively fill the data array using
            -- the width and depth of the ROM as arguments.
            for idx in 0 to 2**addrWidth - 1 loop

                angle := 2.0*MATH_PI*real(idx) / (real(2**(addrWidth)));
                cVal  := cos(angle);

                -- Scale the sucker.
                data(idx) := std_logic_vector(to_signed(integer(cVal*real((2**(romWidth-1) - 1))), romWidth));
                

            end loop;
            
            return data;

        end function;

    -- Initialize the ROM at compile time using the function!
    constant cos_table : rom_type := init_rom;

    begin

        ------------------------------------------------
        -- Concurrent Statements
        ------------------------------------------------
        DATA1 <= data1Out;
        DATA2 <= data2Out;

        ------------------------------------------------
        -- Processes
        ------------------------------------------------

        -- Here we simply place the currently addressed value on
        -- the data bus.
        READ_PROCESS : process(CLK)
        begin
            if rising_edge(CLK) then

                data1Out <= std_logic_vector(cos_table(to_integer(unsigned(ADDR1))));
                data2Out <= std_logic_vector(cos_table(to_integer(unsigned(ADDR2))));

            end if;

        end process;

end architecture RTL;
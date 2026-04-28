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
architecture WAVE_SIM of TestBench is
------------------------------------------------

    ------------------------------------------------
        -- UUT Component Declaration
    ------------------------------------------------
    component COS_ROM is
        generic ( -- Constants
        
            romWidth  : natural;          -- Width in bits of the ROM bus
            addrWidth : natural := 12;    -- Size of the address (2**N - 1 range)
            romDepth  : natural := 2**12  -- Number of romWidth "slots"
        
        );

        port ( -- I/O
        
            CLK : in std_logic; -- Master Clock

            ADDR : in std_logic_vector(addrWidth - 1 downto 0); -- Address in ROM
            DATA : out std_logic_vector(romWidth - 1 downto 0) -- Data out bus
        
        );
    end component;
    
    
    ------------------------------------------------
    -- Signals to wire to the UUT
    ------------------------------------------------
       
    -- Sim
    constant     simWidth : natural := 16;
    constant simAddrWidth : natural := 12;
    constant     simDepth : natural := 2**simAddrWidth;

    -- Wave parameters
    constant sampleRate : integer := 96000;
    constant frequency  : integer := 100;
    -- This is the phase increment that determines how often we need to sample the cosine table
    -- to generate a wave at a desired frequency and sample rate.
    constant phaseIncr  : std_logic_vector(simAddrWidth - 1 downto 0) := std_logic_vector(to_unsigned(frequency*simDepth/sampleRate, simAddrWidth));

    constant tClk : time    := 10 ns;
    signal DONE   : boolean := FALSE;
    
    -- Inputs to the UUT
    signal clk     : std_logic := '0';

    -- Outputs from the UUT
    signal address : std_logic_vector(simAddrWidth - 1 downto 0);
    signal cosVal  : std_logic_vector(simWidth - 1 downto 0);


    begin

        ------------------------------------------------
        -- Unit Under Test
        ------------------------------------------------
        UUT : COS_ROM
            generic map (
                romWidth  => simWidth,
                addrWidth => simAddrWidth,
                romDepth  => simDepth
            )

            port map (

                CLK => clk,
                ADDR => address,
                DATA => cosVal
            );

        ------------------------------------------------
        -- Clock & Reset Driver
        ------------------------------------------------
        process begin
            clk   <= '0';
            wait for 2 * tClk;
            while not DONE loop
                clk <= '1', '0' after tClk / 2;
                wait for tClk;
            end loop;
            report "Simulation complete." severity note;
            wait;
        end process;

        ------------------------------------------------
        -- Input Data Driver
        ------------------------------------------------
        process 
            variable addr : unsigned(simAddrWidth - 1 downto 0) := (others => '0');  -- Accumulator for address
        begin

            wait for  100*tClk;

            -- Here, we utilize the phase accumulator
            -- calculated earlier to select which sample
            -- we use from our cosine table.
            for i in 0 to (simDepth - 1) loop
                address <= std_logic_vector(addr);
                addr := addr + unsigned(phaseIncr);
                wait for tClk;
            end loop;

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
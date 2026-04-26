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
architecture AXIS_RAM_SIM of TestBench is
------------------------------------------------

    ------------------------------------------------
        -- UUT Component Declaration
    ------------------------------------------------
    component AXIS_RAM is
        generic ( -- Constants

            ramWidth : natural;   -- Width in bits of the RAM DAta bus
            ramDepth : natural  -- Number of ramWidth size "slots" available 

        );

        port ( -- I/O

            CLK : in std_logic;  -- Master Clock
            RST : in std_logic;  -- Reset Line

            -- AXI Stream Input Lines
            RX_READY : out std_logic;
            RX_VALID : in std_logic;
            RX_DATA  : in std_logic_vector(ramWidth - 1 downto 0);

            -- AXI Stream Output Lines
            TX_READY : in std_logic;
            TX_VALID : out std_logic;
            TX_DATA  : out std_logic_vector(ramWidth - 1 downto 0)

        );
    end component;
    
    
    ------------------------------------------------
    -- Signals to wire to the UUT
    ------------------------------------------------
       
    -- Sim
    constant simWidth : natural := 16;
    constant simDepth : natural := 512;
    constant tClk : time    := 10 ns;
    signal DONE   : boolean := FALSE;
    
    -- Inputs to the UUT
    signal clk     : std_logic := '0';
    signal rst     : std_logic := '0';
    signal rxValid : std_logic := '0';
    signal txReady : std_logic := '0';
    signal dataVal : integer   :=  0;
    signal txData  : std_logic_vector(simWidth - 1 downto 0) := (others => '0');
    
    
    -- Outputs from the UUT
    signal txValid : std_logic := '0';
    signal rxReady : std_logic := '0';
    signal rxData  : std_logic_vector(simWidth - 1 downto 0) := (others => '0');



    begin

        txData <= std_logic_vector(to_unsigned(dataVal, simWidth));

        ------------------------------------------------
        -- Unit Under Test
        ------------------------------------------------
        UUT : AXIS_RAM
            generic map (
                ramWidth => simWidth,
                ramDepth => simDepth
            )

            port map (

                CLK => clk,
                RST => rst,

                RX_READY => rxReady,
                RX_VALID => rxValid,
                RX_DATA => txData,

                TX_READY => txReady,
                TX_VALID => txValid,
                TX_DATA => rxData

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
        process begin

            wait for  100*tClk;

            -- Write in a bunch of data
            for idx in 0 to 513 loop

                dataVal <= idx;

                wait for  2*tClk;

                if rxReady = '1' then
                    rxValid <= '1';
                end if;

                wait for  0.5*tClk;

                rxValid <= '0';

                wait for  1000.5*tClk;
            end loop;

            wait for 10000*tClk;

            -- Read it all out
            for idx in 0 to 512 loop

                wait for  2*tClk;

                if txValid = '1' then
                    txReady <= '1';
                end if;

                wait for  0.5*tClk;

                txReady <= '0';

                wait for  1000.5*tClk;
            end loop;

            wait for 10000*tClk;

            -- FizzBuz R/W
            for idx in 0 to 512 loop

                dataVal <= idx;

                wait for 0.5*tClk;

                if idx mod 3 = 0 and idx mod 5 = 0 then
                    txReady <= '1';
                    rxValid <= '1';
                elsif idx mod 3 = 0 then
                    rxValid <= '1';
                elsif idx mod 5 = 0 then
                    rxValid <= '1';
                else
                    txReady <= '0';
                    rxValid <= '0';
                end if;

                wait for  0.5*tClk;

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
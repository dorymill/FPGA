library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity TestBench is
end entity TestBench;

architecture SIM of TestBench is

    component SevSeg is
        generic ( -- Constants
        
            clkFreq : integer := 1000000000; -- Master Clock Frequency
            nSeg    : integer := 7;          -- Number of Segements
            nAnode  : integer := 4           -- Number of Displays
        
        );

        port ( -- External IO
            
            MCLK   : in std_logic; -- Master Clock
            ENABLE : in std_logic; -- Enable/Reset Switch
            MODE   : in std_logic; -- Mode Switch (Display Data Drive)

            AN     : out std_logic_vector(nAnode -1 downto 0); 
            SEG    : out std_logic_vector(nSeg - 1 downto 0)

        );
    end component;

    constant nAnode     : integer := 4;
    constant nSeg       : integer := 7;
    constant mClkFreq   : integer := 100000000;
    constant TCLK       : time    := 10 ns;

    signal enableTb : std_logic := '1';
    signal mclkTb   : std_logic := '0';
    signal modeTb   : std_logic := '0';
    signal anTb     : std_logic_vector(nAnode -1 downto 0) := (others => '0');
    signal segTb    : std_logic_vector(nSeg - 1 downto 0) := (others => '1');

    signal DONE     : boolean := FALSE;

begin

    UUT : SevSeg
        generic map (
            clkFreq => 100000000,
            nSeg    => 7,
            nAnode  => 4
        )

        port map (
            MCLK   => mclkTb,
            ENABLE => enableTb,
            MODE   => modeTb,
            AN     => anTb,
            SEG    => segTb
        );

    ------------------------------------------------
    -- Master clock
    ------------------------------------------------
    clk_proc : process
    begin
        while not DONE loop
            mclkTb <= '0';
            wait for TCLK / 2;
            mclkTb <= '1';
            wait for TCLK / 2;
        end loop;
        wait;
    end process clk_proc;


    ------------------------------------------------
    -- Increment DIN1 on each READY pulse
    ------------------------------------------------
    data_driver : process

    begin
        wait for 1 ms;

        -- Drive enable
        enableTb <= '1';

        for idx in 0 to 2 loop

            -- Toggle Mode
            modeTb <= '1';

            wait for 10 ms;

            modeTb <= '0';

            wait for 10 ms;

        end loop;

        DONE <= TRUE;
        wait;
    end process data_driver;

end architecture SIM;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity TestBench is
end entity TestBench;

architecture SIM of TestBench is

    component AXIToI2S is
        generic (
            mClkFreq  : integer := 30720000;
            fsClkFreq : integer := 96000;
            bitWidth  : integer := 16;
            nChan     : integer := 2
        );
        port (
            ENABLE : in std_logic;
            MCLK   : in std_logic;
            DIN1   : in std_logic_vector(bitWidth - 1 downto 0);
            PHONE1 : out std_logic;
            LRCLK  : out std_logic;
            BCLK   : out std_logic;
            READY  : out std_logic
        );
    end component;

    constant bitWidth   : integer := 16;
    constant mClkFreq   : real    := 30.72e6;
    constant TCLK       : time    := 1 sec / mClkFreq;

    signal enableTb : std_logic := '1';
    signal mclkTb   : std_logic := '0';
    signal lrclkTb  : std_logic := '0';
    signal bclkTb   : std_logic := '0';
    signal din1Tb   : std_logic_vector(bitWidth - 1 downto 0) := (others => '0');
    signal phone1Tb : std_logic;
    signal readyTb  : std_logic;
    signal DONE     : boolean := FALSE;

    signal dataWord : unsigned(bitWidth - 1 downto 0) := (others => '0');

begin

    UUT : AXIToI2S
        generic map (
            mClkFreq  => 30720000,
            fsClkFreq => 96000,
            bitWidth  => 16,
            nChan     => 2
        )
        port map (
            ENABLE => enableTb,
            MCLK   => mclkTb,
            DIN1   => din1Tb,
            PHONE1 => phone1Tb,
            LRCLK  => lrclkTb,
            BCLK   => bclkTb,
            READY  => readyTb
        );

    din1Tb <= std_logic_vector(dataWord);

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
        variable frame_count : integer := 0;
    begin
        wait until rising_edge(mclkTb);
        if enableTb = '1' then
            if readyTb = '1' then
                dataWord <= dataWord + 1;
                frame_count := frame_count + 1;
                if frame_count = 1024 then
                    DONE <= TRUE;
                    report "Test complete after 1024 data increments." severity note;
                end if;
            end if;
        end if;
        if DONE then
            wait;
        end if;
    end process data_driver;

end architecture SIM;
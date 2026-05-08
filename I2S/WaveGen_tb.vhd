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

architecture SIM of TestBench is

    ------------------------------------------------
    -- Component Declarations
    ------------------------------------------------
    component COS_ROM is
        generic (
            romWidth  : natural := 16;
            addrWidth : natural := 12;
            romDepth  : natural := 4096
        );
        port (
            CLK  : in std_logic;
            ADDR : in std_logic_vector(addrWidth - 1 downto 0);
            DATA : out std_logic_vector(romWidth - 1 downto 0)
        );
    end component;

    component AXIToI2S is
        generic (
            mClkFreq  : integer := 24576000;  -- 24.576 MHz for LRCLK/MCLK=256 at 96 kHz
            fsClkFreq : integer := 96000;
            bitWidth  : integer := 16;
            nChan     : integer := 2
        );
        port (
            ENABLE : in std_logic;
            MCLK   : in std_logic;
            DIN1   : in std_logic_vector(bitWidth - 1 downto 0);
            DIN2   : in std_logic_vector(bitWidth - 1 downto 0);
            PHONE1 : out std_logic;
            PHONE2 : out std_logic;
            LRCLK  : out std_logic;
            BCLK   : out std_logic;
            READY  : out std_logic
        );
    end component;

    ------------------------------------------------
    -- Constants
    ------------------------------------------------
    constant simWidth     : natural := 16;
    constant simAddrWidth : natural := 12;
    constant simDepth     : natural := 4096;
    constant sampleRate   : integer := 96000;
    constant frequency    : integer := 400;
    constant phaseIncr    : integer := (frequency * simDepth) / sampleRate;  -- ~17 for 400 Hz
    constant mClkFreq     : real    := 24.576e6;  -- MCLK frequency
    constant TCLK         : time    := 1 sec / mClkFreq;

    ------------------------------------------------
    -- Signals
    ------------------------------------------------
    signal clk_tb      : std_logic := '0';
    signal enable_tb   : std_logic := '1';
    signal addr_tb     : std_logic_vector(simAddrWidth - 1 downto 0) := (others => '0');
    signal cosVal_tb   : std_logic_vector(simWidth - 1 downto 0);
    signal din1_tb     : std_logic_vector(simWidth - 1 downto 0) := (others => '0');
    signal din2_tb     : std_logic_vector(simWidth - 1 downto 0) := (others => '0');
    signal phone1_tb   : std_logic;
    signal phone2_tb   : std_logic;
    signal lrclk_tb    : std_logic;
    signal bclk_tb     : std_logic;
    signal ready_tb    : std_logic;
    signal DONE        : boolean := FALSE;

    signal addr_accum  : unsigned(simAddrWidth - 1 downto 0) := (others => '0');  -- Phase accumulator

begin

    ------------------------------------------------
    -- Unit Under Test: COS_ROM
    ------------------------------------------------
    COS_ROM_UUT : COS_ROM
        generic map (
            romWidth  => simWidth,
            addrWidth => simAddrWidth,
            romDepth  => simDepth
        )
        port map (
            CLK  => clk_tb,
            ADDR => addr_tb,
            DATA => cosVal_tb
        );

    ------------------------------------------------
    -- Unit Under Test: AXIToI2S
    ------------------------------------------------
    AXIToI2S_UUT : AXIToI2S
        generic map (
            mClkFreq  => 24576000,
            fsClkFreq => 96000,
            bitWidth  => simWidth,
            nChan     => 2
        )
        port map (
            ENABLE => enable_tb,
            MCLK   => clk_tb,
            DIN1   => din1_tb,
            DIN2   => din2_tb,
            PHONE1 => phone1_tb,
            LRCLK  => lrclk_tb,
            BCLK   => bclk_tb,
            READY  => ready_tb
        );

    ------------------------------------------------
    -- Master Clock (MCLK)
    ------------------------------------------------
    clk_proc : process
    begin
        while not DONE loop
            clk_tb <= '0';
            wait for TCLK / 2;
            clk_tb <= '1';
            wait for TCLK / 2;
        end loop;
        wait;
    end process clk_proc;

    ------------------------------------------------
    -- Wave Generation: Accumulate address and feed data on READY
    ------------------------------------------------
    wave_gen_proc : process
        variable sample_count : integer := 0;
    begin
        wait until rising_edge(clk_tb);
        if enable_tb = '1' then
            if ready_tb = '1' then
                -- Update address by phase increment (with rollover)
                addr_accum <= addr_accum + to_unsigned(phaseIncr, simAddrWidth);
                addr_tb <= std_logic_vector(addr_accum);
                -- Feed cosine value to I2S input
                din1_tb <= cosVal_tb;
                din2_tb <= cosVal_tb;
                sample_count := sample_count + 1;
                if sample_count = 48000 then  -- ~500 ms at 96 kHz
                    DONE <= TRUE;
                    report "WaveGen test complete after 9600 samples." severity note;
                end if;
            end if;
        end if;
        if DONE then
            wait;
        end if;
    end process wave_gen_proc;

end architecture SIM;
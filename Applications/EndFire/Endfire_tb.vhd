------------------------------------------------
-- Testbench for Endfire_Top.vhd (without PLL IP)
--
-- This testbench simulates the EndfireTop functionality
-- by instantiating sub-components directly, bypassing the PLL.
-- i2sClk is driven directly from MCLK_tb.

-- Quadspi: S25FL032
-- Author: Generated based on I2S_Top.vhd style

------------------------------------------------
-- Libraries
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------
entity TestBench is
------------------------------------------------

end entity TestBench;

------------------------------------------------
architecture TB of TestBench is
------------------------------------------------

    -- Component Declarations (from Endfire_Top.vhd)
    component COS_ROM
        generic (
            romWidth  : natural;
            addrWidth : natural;
            romDepth  : natural
        );
        port (
            CLK   : in std_logic;
            ADDR1 : in std_logic_vector(addrWidth - 1 downto 0);
            ADDR2 : in std_logic_vector(addrWidth - 1 downto 0);
            DATA1 : out std_logic_vector(romWidth - 1 downto 0);
            DATA2 : out std_logic_vector(romWidth - 1 downto 0)
        );
    end component;

    component AXItoI2S
        generic (
            mClkFreq  : integer;
            fsClkFreq : integer;
            bitWidth  : integer;
            nChan     : integer
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

    -- Constants
    constant addrWidth  : integer := 12;
    constant romDepth   : integer := 2**addrWidth;
    constant bitWidth   : integer := 16;
    constant nChan      : integer := 2;
    constant updateRate : integer := 96000;
    constant mClkFreq   : integer := 24576000;
    constant fsClkFreq  : integer := 96000;

    -- Test Signals
    signal MCLK_tb   : std_logic := '0';
    signal ENABLE_tb : std_logic := '0';
    signal MODE_tb   : std_logic := '0';
    signal PHONE1_tb : std_logic;
    signal PHONE2_tb : std_logic;
    signal LRCLK_tb  : std_logic;
    signal BCLK_tb   : std_logic;
    signal LED_tb    : std_logic_vector(15 downto 0);
    signal SW_tb     : std_logic_vector(12 downto 0);

    -- Internal Signals (from Endfire_Top)
    signal i2sClk      : std_logic := '0';
    signal ready       : std_logic := '0';
    signal readyLast   : std_logic := '0';

    signal d1Out       : std_logic_vector(bitWidth - 1 downto 0);
    signal d2Out       : std_logic_vector(bitWidth - 1 downto 0);
    signal d1InReg     : std_logic_vector(bitWidth - 1 downto 0);
    signal d2InReg     : std_logic_vector(bitWidth - 1 downto 0);
    signal d1MultReg   : std_logic_vector(2*bitWidth -1 downto 0);
    signal d2MultReg   : std_logic_vector(2*bitWidth -1 downto 0);
    signal addr1       : std_logic_vector(addrWidth - 1 downto 0) := (others => '0');
    signal addr2       : std_logic_vector(addrWidth - 1 downto 0) := (others => '0');
    signal volume      : integer;

    -- Frequency Generation
    constant toneFreq   : integer := 800;
    constant sampleRate : integer := fsClkFreq;
    constant phaseIncr  : unsigned(addrWidth - 1 downto 0) :=
        to_unsigned((((toneFreq * 2**addrWidth) + sampleRate/2)) / sampleRate, addrWidth);
    constant endFireOffSet : unsigned(addrWidth - 1 downto 0) := to_unsigned(romDepth / 2, addrWidth);
    signal addr1Accumulator : unsigned(addrWidth - 1 downto 0) := (others => '0');
    signal addr2Accumulator : unsigned(addrWidth - 1 downto 0) := endFireOffSet;

    -- Clock Period
    constant CLK_PERIOD : time := 40.69 ns;  -- For 24.576 MHz MCLK
    signal DONE : boolean := FALSE;

begin

    -- Direct clock assignment (bypassing PLL)
    i2sClk <= MCLK_tb;

    -- Accumulator assignments
    addr1 <= std_logic_vector(addr1Accumulator);
    addr2 <= std_logic_vector(addr2Accumulator) when MODE_tb = '1' else std_logic_vector(addr1Accumulator);

    -- Instantiate COS ROM
    COS_ROM_inst : COS_ROM
        generic map (
            romWidth  => bitWidth,
            addrWidth => addrWidth,
            romDepth  => romDepth
        )
        port map (
            CLK   => i2sClk,
            ADDR1 => addr1,
            ADDR2 => addr2,
            DATA1 => d1InReg,
            DATA2 => d2InReg
        );

    -- Instantiate AXItoI2S
    I2S_inst : AXItoI2S
        generic map (
            mClkFreq  => mClkFreq,
            fsClkFreq => fsClkFreq,
            bitWidth  => bitWidth,
            nChan     => nChan
        )
        port map (
            ENABLE => ENABLE_tb,
            MCLK   => i2sClk,
            DIN1   => d1Out,
            DIN2   => d2Out,
            PHONE1 => PHONE1_tb,
            PHONE2 => PHONE2_tb,
            LRCLK  => LRCLK_tb,
            BCLK   => BCLK_tb,
            READY  => ready
        );

    -- Clock Generation Process
    CLK_GEN : process
    begin
        while not DONE loop
            MCLK_tb <= '0';
            wait for CLK_PERIOD / 2;
            MCLK_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process CLK_GEN;

    -- Wave Process
    WAVE_PROCESS : process(i2sClk)
    begin
        if rising_edge(i2sClk) then
            if ready = '1' then
                addr1Accumulator <= addr1Accumulator + phaseIncr;
                addr2Accumulator <= addr2Accumulator + phaseIncr;
            end if;
        end if;
    end process WAVE_PROCESS;

    -- Process to rescale the cosine samples by
    -- a decimal scalar value.
    ------------------------------------------------
    OUTPUT_SCALE_PROCESS : process(i2sclk)
    ------------------------------------------------

    begin
        if rising_edge(i2sclk) then

            -- Keep track of ready transitions
            readyLast <= ready;

            -- The falling edge of ready, we have new data
            if readyLast = '1' and ready = '0' then

                -- Performa 1.15 Multiplication, requiring an N+1 bit register
                -- to hold the value.
                d1MultReg <= std_logic_vector(signed(d1InReg) * volume);
                d2MultReg <= std_logic_vector(signed(d2InReg) * volume);

                -- Slice the output to execute the appropriate bitshift >:D
                d1Out <= std_logic_vector(d1MultReg(bitWidth*2 - 1 downto bitWidth));
                d2Out <= std_logic_vector(d2MultReg(bitWidth*2 - 1 downto bitWidth));

            end if;


        end if;
    end process OUTPUT_SCALE_PROCESS;

    -- LED Status Process
    LED_STATUS_PROCESS : process(i2sClk)
        variable ledCounter : natural := 0;
    begin
        if rising_edge(i2sClk) then
            if ledCounter = 10*updateRate then
                LED_tb <= d1InReg;
                ledCounter := 0;
            else
                ledCounter := ledCounter + 1;
            end if;
        end if;
    end process LED_STATUS_PROCESS;

        -- This process shall drive the volume of the 
        -- audio signal using the available switches.
        ------------------------------------------------
        SWITCH_PROCESS : process(i2sclk)
        ------------------------------------------------
        begin
             if rising_edge(i2sclk) then
                if ENABLE_tb = '1' then
            
                    volume <= 3*to_integer(unsigned(SW_tb));

                else
                    volume <= 0;
                    
                end if;

             end if;
        end process SWITCH_PROCESS;

    -- Stimulus Process
    STIMULUS : process
    begin
        -- Reset
        ENABLE_tb <= '0';
        MODE_tb <= '0';
        wait for 1000 ns;
        
        -- Enable and test normal mode
        SW_tb <= "1111111111111";
        ENABLE_tb <= '1';
        wait for 20 ms;

        -- Disable and test reset
        ENABLE_tb <= '0';
        wait for 1 ms;
        ENABLE_tb <= '1';
        
        -- Switch to Endfire mode
        SW_tb <= "0111111111111";
        MODE_tb <= '1';
        wait for 20 ms;

        -- Disable and test reset
        ENABLE_tb <= '0';
        wait for 1 ms;
        SW_tb <= "1111111111111";
        ENABLE_tb <= '1';

        -- Switch back out
        MODE_tb <= '0';
        wait for 20 ms;
        
        -- Test complete
        DONE <= TRUE;
        wait;
    end process STIMULUS;

end architecture TB;
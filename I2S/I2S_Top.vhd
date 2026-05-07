------------------------------------------------
-- Top Level I2S Transmitter Design
--
-- The purpose of this project is to produce
-- a sine wave output to a speaker.

-- Quadspi: S25FL032
-- Author: dmmill

------------------------------------------------
-- Libraries
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------
entity Top is
------------------------------------------------

    generic ( -- Constants 

        mClkFreq  : integer := 24576000;  -- Master Clock Frequency
        fsClkFreq : integer := 96000;     -- Frame Sync Clock Frequency (f_s = 96 kHz Audio)
        bitWidth  : integer := 16;        -- Audio Data Size
        nChan     : integer := 2;         -- Number of Channels
        addrWidth : integer := 12        -- ROM Address Width

    );

    port ( -- Physical IO defined in XDC file


        ENABLE   : in std_logic; -- Reset
        MCLK     : in std_logic; -- Master Clock

        PHONE1   : out std_logic; -- Phone 1 bit output
        -- PHONE2   : out std_logic; -- Phone 2 bit output
        -- PHONE3   : out std_logic; -- Phone 3 bit output
        -- PHONE4   : out std_logic; -- Phone 4 bit output
        
        LRCLK    : out std_logic; -- Frame Sync Clock
        BCLK     : out std_logic; -- Bit Sync Clock

        LED      : out std_logic_vector(bitWidth - 1 downto 0)

    );



end entity Top;

------------------------------------------------
architecture RTL of Top is
------------------------------------------------

    -- PLL Component
    component clk_wiz_0
        port (
            CLK_IN1    : in  std_logic;
            CLK_OUT1   : out std_logic
        );
    end component;

    -- Cosine Table
    component COS_ROM
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

    -- I2S Component
    component AXItoI2S
        generic ( -- Constants 

            mClkFreq  : integer := 24576000;  -- Master Clock Frequency
            fsClkFreq : integer := 96000;     -- Frame Sync Clock Frequency (f_s = 96 kHz Audio)
            bitWidth  : integer := 16;        -- Audio Data Size
            nChan     : integer := 2          -- Number of Channels

        );

        port ( -- Physical IO defined in XDC file
   
            ENABLE   : in std_logic; -- Reset
            MCLK     : in std_logic; -- Master Clock
            DIN1     : in std_logic_vector(bitWidth - 1 downto 0); -- Phone 1 Input

            PHONE1   : out std_logic; -- Phone 1 bit output
            -- PHONE2   : out std_logic; -- Phone 2 bit output
            -- PHONE3   : out std_logic; -- Phone 3 bit output
            -- PHONE4   : out std_logic; -- Phone 4 bit output
            
            LRCLK    : out std_logic; -- Frame Sync Clock
            BCLK     : out std_logic; -- Bit Sync Clock
            READY    : out std_logic  -- Data Ready Signal

        );

    end component;

    -- Connecting Signals
    signal i2sclk   : std_logic := '0';
    signal ready    : std_logic := '0';
    signal addr     : std_logic_vector(addrWidth - 1 downto 0) := (others => '1');
    signal data1    : std_logic_vector(bitWidth - 1 downto 0);
    
    constant updateRate : integer := 96000;
    signal ledOut   : std_logic_vector(bitWidth - 1 downto 0);


    -- tone generation constants
    constant toneFreq   : integer := 400;
    constant sampleRate : integer := fsClkFreq;  -- 96 kHz
    constant phaseIncr : unsigned(addrWidth - 1 downto 0) :=
        to_unsigned(((toneFreq * (2**addrWidth)) + sampleRate/2) / sampleRate, addrWidth);

    signal addr_accum : unsigned(addrWidth - 1 downto 0) := (others => '0');
    
    begin

        LED <= ledOut;
        -- drive ROM address from the phase accumulator
        addr <= std_logic_vector(addr_accum);

        -- Instantiate the PLL
        PLL_inst : clk_wiz_0
            port map (
                CLK_IN1  => MCLK,
                CLK_OUT1 => i2sclk
            );

        -- Instantiate the I2S Module
        I2S_inst : AXItoI2S
            generic map(
                mClkFreq  => 24576000,
                fsClkFreq => 96000,
                bitWidth  => 16,
                nChan     => 2
            )
            
            port map(
                ENABLE   => ENABLE,
                MCLK     => i2sclk,

                DIN1  => data1,

                PHONE1   => PHONE1,
                -- PHONE2   => open,
                -- PHONE3   => open,
                -- PHONE4   => open,
                LRCLK    => LRCLK,
                BCLK     => BCLK,
                READY    => READY
            );
            
        -- Instantiate COS ROM
        COS_ROM_inst : COS_ROM
            generic map ( -- Constants
            
                romWidth  => bitWidth,
                addrWidth => 12,
                romDepth  => 2**12
                
            )
  
            port map ( -- I/O
            
                CLK => i2sClk,

                ADDR => addr,
                DATA => data1
            );

        -- Process to drive the wave
        WAVE_PROCESS : process(i2sclk)
        begin
            if rising_edge(i2sclk) then
                if READY = '1' then
                    addr_accum <= addr_accum + phaseIncr;
                end if;
            end if;
        end process WAVE_PROCESS;


        LED_STATUS_PROCESS : process(i2sclk)
            variable ledCounter : natural := 0;
        begin
            if rising_edge(i2sclk) then
                if ledCounter = 10*updateRate then
                    ledOut <= data1;
                    ledCounter := 0;
                else 
                    ledCounter := ledCounter + 1;
                end if;
            end if;
        end process;

    end architecture RTL;

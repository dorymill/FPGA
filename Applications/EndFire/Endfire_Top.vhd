------------------------------------------------
-- The purpose of this project is to create
-- a four element array that is capable
-- of switching in and out of Endfire mode.
-- 
-- Quadspi: S25FL032
-- Author: dmmill

------------------------------------------------
-- Libraries
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------
entity EndfireTop is
------------------------------------------------

    generic ( -- Constants
    
        mClkFreq  : integer := 49152000;  -- Master Clock Frequency
        fsClkFreq : integer := 192000;    -- Frame Sync Clock Frequency (f_s = 96 kHz Audio)
        bitWidth  : integer := 32;        -- Audio Data Size
        nChan     : integer := 2;         -- Number of Channels
        nSeg      : integer := 7;         -- Number of Segements
        nAnode    : integer := 4          -- Number of Displays
    
    );

    port ( -- External IO
        
        MCLK     : in std_logic; -- Master Clock
        ENABLE   : in std_logic; -- Reset
        MODE     : in std_logic; -- Mode Selection
        SW       : in std_logic_vector(15 downto 3); -- Volume selection

        PHONE1   : out std_logic; -- Phone 1 bit output
        PHONE2   : out std_logic; -- Phone 2 bit output
        
        I2SMCLK  : out std_logic; -- I2S Master Clock
        LRCLK    : out std_logic; -- Frame Sync Clock
        BCLK     : out std_logic; -- Bit Sync Clock

        LED      : out std_logic_vector(15 downto 0);         -- LED Output
        AN       : out std_logic_vector(nAnode - 1 downto 0); -- Anode Output
        SEG      : out std_logic_vector(0 to nSeg - 1)        -- Segment Output

    );

end entity EndfireTop;

------------------------------------------------
architecture RTL of EndfireTop is
------------------------------------------------

    ------------------------------------------------
    -- Constants, Types, and Signals
    ------------------------------------------------
    constant addrWidth  : integer := 12;
    constant romDepth   : integer := 2**addrWidth;
    constant updateRate : integer := 96000;

    signal i2sClk      : std_logic;
    signal ready       : std_logic;
    signal readyLast   : std_logic;

    -- I2S Input Data Registers
    signal d1InReg   : std_logic_vector(bitWidth - 1 downto 0);
    signal d2InReg   : std_logic_vector(bitWidth - 1 downto 0);
    signal d1Out     : std_logic_vector(bitWidth - 1 downto 0);
    signal d2Out     : std_logic_vector(bitWidth - 1 downto 0);
    signal d1MultReg : std_logic_vector(2*bitWidth -1 downto 0);
    signal d2MultReg : std_logic_vector(2*bitWidth -1 downto 0);
    signal volume    : integer;

    -- COS ROM Address Registers  
    signal addr1  : std_logic_vector(addrWidth - 1 downto 0);
    signal addr2  : std_logic_vector(addrWidth - 1 downto 0);

    -- LED Drive signal
    signal ledOut : std_logic_vector(bitWidth - 1 downto 0);

    -- Frequency Generation Parameters
    constant toneFreq   : integer := 800;
    constant sampleRate : integer := fsClkFreq;  -- 96 kHz
    constant phaseIncr : unsigned(addrWidth - 1 downto 0) :=
        to_unsigned(((toneFreq * 2**addrWidth)) / sampleRate, addrWidth);

    constant endFireOffSet : unsigned(addrWidth - 1 downto 0) := to_unsigned(romDepth / 2, addrWidth);

    signal addr1Accumulator : unsigned(addrWidth - 1 downto 0);
    signal addr2Accumulator : unsigned(addrWidth - 1 downto 0);   -- This starts us off always 180 degrees out

    ------------------------------------------------
    -- Component Declarations
    ------------------------------------------------

    -- PLL to provide proper clock
    component clk_wiz_0
        port (
            CLK_IN1    : in  std_logic;
            CLK_OUT1   : out std_logic
        );
    end component;

    -- Cosine Table
    component COS_ROM
        generic ( -- Constants
    
        romWidth  : natural; -- Width in bits of the ROM bus
        addrWidth : natural; -- Size of the address (2**N - 1 range)
        romDepth  : natural  -- Number of romWidth "slots"
    
        );

        port ( -- I/O
        
            CLK : in std_logic; -- Master Clock

            ADDR1 : in std_logic_vector(addrWidth - 1 downto 0); -- Address 1 in ROM
            ADDR2 : in std_logic_vector(addrWidth - 1 downto 0); -- Address 2 in ROM
            DATA1 : out std_logic_vector(romWidth - 1 downto 0); -- Data out bus
            DATA2 : out std_logic_vector(romWidth - 1 downto 0)  -- Data out bus
            
        );
    end component;
    
    -- I2S Component
    component AXItoI2S
        generic ( -- Constants 

            mClkFreq  : integer;  -- Master Clock Frequency
            fsClkFreq : integer;  -- Frame Sync Clock Frequency (f_s = 96 kHz Audio)
            bitWidth  : integer;  -- Audio Data Size
            nChan     : integer  -- Number of Channels

        );

        port ( -- Physical IO defined in XDC file
   
            ENABLE   : in std_logic; -- Reset
            MCLK     : in std_logic; -- Master Clock

            DIN1     : in std_logic_vector(bitWidth - 1 downto 0); -- Phone 2 Data Input
            DIN2     : in std_logic_vector(bitWidth - 1 downto 0); -- Phone 2 Data Input

            PHONE1   : out std_logic; -- Phone 1 bit output
            PHONE2   : out std_logic; -- Phone 2 bit output

            
            LRCLK    : out std_logic; -- Frame Sync Clock
            BCLK     : out std_logic; -- Bit Sync Clock
            READY    : out std_logic -- Data Ready Signal

        );
    end component;

    component SevSeg is
        generic ( -- Constants
        
            clkFreq : integer; -- Master Clock Frequency
            nSeg    : integer; -- Number of Segements
            nAnode  : integer  -- Number of Displays
        
        );

        port ( -- External IO
            
            MCLK   : in std_logic; -- Master Clock
            ENABLE : in std_logic; -- Enable/Reset Switch
            MODE   : in std_logic; -- Mode Switch (Display Data Drive)

            AN     : out std_logic_vector(nAnode -1 downto 0); 
            SEG    : out std_logic_vector(0 to nSeg - 1)

        );
    end component;

    ------------------------------------------------
    -- Procedures and Functions
    ------------------------------------------------
    
    begin
        ------------------------------------------------
        -- Concurrent Statements
        ------------------------------------------------
        ready <= READY;
        I2SMCLK <= i2sClk;
        addr1 <= std_logic_vector(addr1Accumulator);
        addr2 <= std_logic_vector(addr2Accumulator) when MODE = '1' else std_logic_vector(addr1Accumulator);

        ------------------------------------------------
        -- Component Instantiation
        ------------------------------------------------

        -- Instantiate the PLL
        PLL_inst : clk_wiz_0
            port map (
                CLK_IN1  => MCLK,
                CLK_OUT1 => i2sclk
            );

        -- Instantiate the AXIS I2S Bridge
        I2S_inst : AXItoI2S
            generic map (
                mClkFreq  => mClkFreq,
                fsClkFreq => fsClkFreq,
                bitWidth  => bitWidth,
                nChan     => nChan

            )

            port map (
                ENABLE   => ENABLE,
                MCLK     => i2sclk,

                DIN1  => d1Out,
                DIN2  => d2Out,

                PHONE1   => PHONE1,
                PHONE2   => PHONE2,

                LRCLK    => LRCLK,
                BCLK     => BCLK,
                READY    => ready
            );

        -- Instantiate COS ROM
        COS_ROM_inst : COS_ROM
            generic map ( -- Constants
            
                romWidth  => bitWidth,
                addrWidth => addrWidth,
                romDepth  => romDepth
                
            )

            port map ( -- I/O
            
                CLK => i2sClk,

                ADDR1 => addr1,
                ADDR2 => addr2,
                DATA1 => d1InReg,
                DATA2 => d2InReg
            );

        -- Instantiate SevSeg Display
        SEV_SEG_inst : SevSeg
            generic map ( -- Constants
            
                clkFreq => mClkFreq,
                nSeg    => nSeg,
                nAnode  => nAnode
            )

            port map ( -- I/O
            
                MCLK   => i2sClk,
                ENABLE => ENABLE,
                MODE   => MODE,

                AN     => AN,
                SEG    => SEG
            );


        ------------------------------------------------
        -- Processes
        ------------------------------------------------

        -- Process to acquire the cosine samples
        ------------------------------------------------
        WAVE_PROCESS : process(i2sclk)
        ------------------------------------------------
        begin
            if rising_edge(i2sClk) then
                if ENABLE = '1' then
                    if ready = '1' then
                        addr1Accumulator <= addr1Accumulator + phaseIncr;
                        addr2Accumulator <= addr2Accumulator + phaseIncr;
                    end if;
                else 
                    addr1Accumulator <= (others => '0');
                    addr2Accumulator <= endFireOffset;
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


        -- This process shall drive the volume of the 
        -- audio signal using the available switches.
        ------------------------------------------------
        SWITCH_PROCESS : process(i2sclk)
        ------------------------------------------------
        begin
             if rising_edge(i2sclk) then
                if ENABLE = '1' then
            
                    volume <= 3*to_integer(unsigned(SW));

                else
                    volume <= 0;
                    
                end if;

             end if;
        end process SWITCH_PROCESS;


        -- This process shall drive the LED's based
        -- on data1 drive.
        ------------------------------------------------
        LED_STATUS_PROCESS : process(i2sclk)
        ------------------------------------------------
            variable ledCounter : natural := 0;
        begin
            if rising_edge(i2sclk) then
                if ENABLE = '1' then
                    if ledCounter = 10*updateRate then
                        LED <= d1InReg((bitWidth - 1) downto bitWidth - 16); -- This keeps only the top 16 bits for the LED[15:0]
                        ledCounter := 0;
                    else 
                        ledCounter := ledCounter + 1;
                    end if;
                else
                    ledCounter := 0;
                end if;
            end if;
        end process;

end architecture RTL;
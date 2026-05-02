------------------------------------------------
-- Top Level 7 Segement Design
--
-- The purpose of this project is to drive
-- the Bayses 3 7 seg displays!
-- 
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
    
        clkFreq : integer := 1000000000; -- Master Clock Frequency
        nSeg    : integer := 7;          -- Number of Segements
        nAnode  : integer := 4           -- Number of Displays
    
    );

    port ( -- I/O Defined in the XDC file
        
        MCLK   : in std_logic; -- Master Clock
        ENABLE : in std_logic; -- Enable/Reset Switch
        MODE   : in std_logic; -- Mode Switch (Display Data Drive)

        AN     : out std_logic_vector(nAnode -1 downto 0); 
        SEG    : out std_logic_vector(0 to nSeg - 1)

    );



end entity Top;

------------------------------------------------
architecture RTL of Top is
------------------------------------------------

    -- I2S Component
    component SevSeg
        generic ( -- Constants
        
            clkFreq : integer := 1000000000; -- Master Clock Frequency
            nSeg    : integer := 7;          -- Number of Segements
            nAnode  : integer := 4           -- Number of Displays
        
        );

        port ( -- External IO
            
            MCLK   : in std_logic; -- Master Clock
            ENABLE : in std_logic; -- Enable/Reset Switch
            MODE   : in std_logic; -- Mode Switch (Display Data Drive)

            AN     : out std_logic_vector(nAnode -1 downto 0); -- Anode Driver
            SEG    : out std_logic_vector(0 to nSeg - 1)       -- Segment Driver

        );
    end component;
    
    begin

        -- Instantiate COS ROM
        SEV_SEG_inst : SevSeg
            generic map ( -- Constants
            
                clkFreq => clkFreq, -- Master Clock Frequency
                nSeg    => nSeg,    -- Number of Segements
                nAnode  =>  nAnode  -- Number of Displays
                
            )
  
        port map ( -- I/O
            
            -- Inputs
            MCLK   => MCLK,   -- Master Clock
            ENABLE => ENABLE, -- Enable/Reset Switch
            MODE   => MODE,   -- Mode Switch (Display Data Drive)

            -- Outputs
            AN  => AN,   -- Anode Signal Vector
            SEG => SEG  -- Segment Signal Vector

        );

    end architecture RTL;

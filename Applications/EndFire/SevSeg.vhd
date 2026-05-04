------------------------------------------------
-- The purpose of this project is to drive the
-- four element seven segment display of the
-- Bayses 3.

-- Quadspi: S25FL032
-- Author: dmmill

------------------------------------------------
-- Libraries
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------
entity SevSeg is
------------------------------------------------

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
        SEG    : out std_logic_vector(0 to nSeg - 1)

    );

end entity SevSeg;

------------------------------------------------
architecture RTL of SevSeg is
------------------------------------------------

    ------------------------------------------------
    -- Constants, Types, and Signals
    ------------------------------------------------
    -- Strobe counter
    constant sweepCntr : integer   := 100000; -- Anode switch every 1 ms
    signal mode_z1     : std_logic := '0';    -- This handles clean mode swaps

    -- Hardware Output Signals
    signal anCntr : integer := 0;
    signal anode  : integer := 0;

    -- Enum type for the characters
    type char_type is (
        VAL_0, VAL_1, VAL_2, VAL_3, VAL_4, VAL_5, VAL_6, VAL_7, VAL_8, VAL_9,
        CHAR_A, CHAR_B, CHAR_C, CHAR_D, CHAR_E, CHAR_F, CHAR_G, CHAR_H, 
        CHAR_I, CHAR_J, CHAR_L, CHAR_N, CHAR_O, CHAR_P, CHAR_R, CHAR_S, 
        CHAR_T, CHAR_U, CHAR_Y, DASH, BLANK
    );

    -- Array of characters to be displayed
    type char_array is array (nAnode -1 downto 0) of char_type;
    signal characters : char_array := (DASH, DASH, DASH, DASH);

    
    ------------------------------------------------
    -- Procedures and Functions
    ------------------------------------------------
    
    begin
        ------------------------------------------------
        -- Concurrent Statements
        ------------------------------------------------
                    
        ------------------------------------------------
        -- Processes
        ------------------------------------------------

        -- This process drives the data for the 
        -- displays and can be replaced with A
        -- variety of input methods, like a 
        -- 32 word mapping to a set of characters.
        ------------------------------------------------
        CHARACTER_PROCESS : process (MCLK)
        ------------------------------------------------
        begin
            if rising_edge(MCLK) then
                if ENABLE = '1' then
                    if MODE = '1' then
                        characters <= (CHAR_E, CHAR_N, CHAR_D, CHAR_F);
                    elsif MODE = '0' then
                        characters <= (CHAR_I, CHAR_N, CHAR_P, CHAR_H);
                    end if;
                else
                    characters <= (DASH, DASH, DASH, DASH);
                end if;
            end if;
        end process;

        -- This process shall map the char_type Enum
        -- to their corresponding driven cathode
        -- bit representation.
        ------------------------------------------------
        DECODER_PROCESS : process (anode)
        ------------------------------------------------
        begin
            case characters(anode) is
                -- Numbers
                when VAL_0  => SEG <= "0000001";
                when VAL_1  => SEG <= "1001111";
                when VAL_2  => SEG <= "0010010";
                when VAL_3  => SEG <= "0000110";
                when VAL_4  => SEG <= "1001100";
                when VAL_5  => SEG <= "0100100";
                when VAL_6  => SEG <= "0100000";
                when VAL_7  => SEG <= "0001111";
                when VAL_8  => SEG <= "0000000";
                when VAL_9  => SEG <= "0000100";

                -- Letters (Case chosen for best readability on 7-segs)
                when CHAR_A  => SEG <= "0001000"; -- 'A'
                when CHAR_B  => SEG <= "1100000"; -- 'b'
                when CHAR_C  => SEG <= "0110001"; -- 'C'
                when CHAR_D  => SEG <= "1000010"; -- 'd'
                when CHAR_E  => SEG <= "0110000"; -- 'E'
                when CHAR_F  => SEG <= "0111000"; -- 'F'
                when CHAR_G  => SEG <= "0100001"; -- 'G'
                when CHAR_H  => SEG <= "1001000"; -- 'H'
                when CHAR_I  => SEG <= "1111001"; -- 'I'
                when CHAR_J  => SEG <= "1000111"; -- 'J'
                when CHAR_L  => SEG <= "1110001"; -- 'L'
                when CHAR_N  => SEG <= "1101010"; -- 'n'
                when CHAR_O  => SEG <= "0000001"; -- 'O'
                when CHAR_P  => SEG <= "0011000"; -- 'P'
                when CHAR_R  => SEG <= "1111010"; -- 'r'
                when CHAR_S  => SEG <= "0100100"; -- 'S'
                when CHAR_T  => SEG <= "1110000"; -- 't'
                when CHAR_U  => SEG <= "1000001"; -- 'U'
                when CHAR_Y  => SEG <= "1000100"; -- 'y'
                
                -- Symbols
                when DASH    => SEG <= "1111110"; -- '-'
                when BLANK   => SEG <= "1111111"; -- All OFF
                when others  => SEG <= "1111111";
            end case;
        end process;


        -- This process will cylce which anode/display
        -- is being driven every 1 ms. Rollover from 0
        -- to nAnode - 1 is handled via modulus.
        -- additionally we cleanly update the display
        -- on mode changes.
        ------------------------------------------------
        ANODE_PROCESS : process (MCLK)
        ------------------------------------------------
        begin
            if rising_edge(MCLK) then
                if ENABLE = '1' then
                    if anCntr = 0 then
                        anCntr <= sweepCntr - 1;
                        anode <= (anode + 1) mod nAnode;

                    else
                        anCntr <= anCntr - 1;
                    end if;

                    -- Clean Swap on Mode
                    if MODE /= mode_z1 then
                        anode <= 0;
                    end if;
                    
                    -- Synchronously set the anode vector
                    AN <= (others => '1');
                    AN(anode) <= '0';

                    mode_z1 <= MODE;

                end if;
            end if;
        end process;

    end architecture RTL;
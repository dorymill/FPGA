------------------------------------------------
-- The purpose of this block is to implement
-- an AXI Stream FIFO RAM utilizing a ring buffer
-- style internal architecture.

-- Quadspi: S25FL032
-- Author: dmmill

------------------------------------------------
-- Libraries
library IEEE;

use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

------------------------------------------------
entity AXIS_RAM is
------------------------------------------------

    generic ( -- Constants

        ramWidth : natural; -- Width in bits of the RAM DAta bus
        ramDepth : natural  -- Number of ramWidth size "slots" available 

    );

    port ( -- I/O

        CLK : in std_logic;  -- Master Clock
        RST : in std_logic;  -- Reset Line

        -- AXI Stream Input Lines
        RXREADY : out std_logic;
        RXVALID : in std_logic;
        RXDATA  : in std_logic_vector(ramWidth - 1 downto 0);

        -- AXI Stream Output Lines
        TXREADY : in std_logic;
        TXVALID : out std_logic;
        TXDATA  : out std_logic_vector(ramWidth - 1 downto 0)

    );


end entity AXIS_RAM;

------------------------------------------------
architecture RTL of AXIS_RAM is
------------------------------------------------

    ------------------------------------------------
    -- Constants, Types, and Signals
    ------------------------------------------------

    -- RAM Type Declartion
    type ram_type is array (0 to ramDepth -1)
        of std_logic_vector(RXDATA'range);

    signal ram : ram_type;

    -- Constants
    constant ramWidth : natural := ramWidth;
    constant ramDepth : natural := ramDepth;

    -- AXI Signals
    signal rxReady : std_logic := 0;
    signal txValid : std_logic := 0;

    -- RAM Processing Signals
    subtype index_type is natural range ram_type'range; -- Constraint to the size of the RAM via typedef
    signal head      : index_type; -- Head pointer in ring buffer
    signal tail      : index_type; -- Tail pointer in ring buffer
    signal count     : index_type; -- Current number of samples in buffer
    signal count_z1  : index_type; -- Prior number of samples in buffer
    signal rxTxSimul : std_logic;  -- Clock cycle after simultaneous R/W
    

    ------------------------------------------------
    -- Procedures and Functions
    ------------------------------------------------

    -- This function will handle calculation of the
    -- R/W pointers, accounting for rollover. This
    -- is where the heart of the ready valid logic
    -- lies, driving the motion of the R/W pointers
    -- throughout execution.
    function nextIndex (
        index : index_type;
        ready : std_logic;
        valid : std_logic
    ) return index_type is
        begin
            -- If Ready and Valid, I/O is occurring, increment the pointers
            if ready='1' and valid = '1' then 
                if index = index_type'high then -- If we're at the top, rollover to the bottom
                    return index_type'low
                else
                    return index + 1; -- Increment otherwise
                end if;
            end if;

            return index; -- If not ready or valid, do nothing to the pointer
        end function;

    -- This procedure encapsulates the actual motion
    -- of both the R/W pointers. It could be implemented
    -- as two separate processes further down as well.
    procedure indexProc (
            signal clk   : in std_logic;
            signal rst   : in std_logic;
            signal index : inout index_type;
            signal ready : in std_logic;
            signal valid : in std_logic
    ) is
        begin
            -- On the rising clock edges, simply apply the 
            -- nextIndex function on the AXI parameters and
            -- RAM address.
            if rising_edge(clk) then
                if rst = '1' then
                    index <= index_type'low;
                else
                    index <= nextIndex(index, ready, valid);
                end if;
            end if;
        end procedure;

    
    ------------------------------------------------
    -- Concurrent Statements
    ------------------------------------------------
    RXREADY <= rxReady; -- Wire the AXIS Ready port to an internal signal
    TXVALID <= txValid; -- Wire the AXIS Valid port to an internal signal
                        -- Note: Outputs can't be used directly

    begin
        ------------------------------------------------
        -- Processes
        ------------------------------------------------
        
        -- These two processes handles the explicit motion of the R/W
        -- pointer every clock cycle and with a synchronous reset
        HEAD_PROCESS : indexProc(CLK, RST, head, rxReady, RXVALID);
        TAIL_PROCESS : indexProc(CLK, RST, tail, TXREADY, txValid);

        -- This proccess handles the I/O operation 
        -- for the RAM FIFO itself, setting the input and 
        -- output data registers accordingly.
        RAM_PROCESS : process(CLK)
        begin
            if rising_edge(CLK) then
                ram(head) <= RXDATA;
                TXDATA    <= ram(nextIndex(tail, TXREADY, txValid));
            end if;
        end process;

        -- This process moves the counter of elements in the 
        -- FIFO Queue to keep track of whether or not we're going
        -- to overrun on an I/O operation. The next process
        -- Keeps track of count at the last I/O operation
        -- to detect when we're full.
        COUNT_PROCESS : process (CLK)
        begin
            if rising_edge(CLK) then
                if head < tail then 
                    count <= head - tail + ramDepth;
                else
                    count <= head - tail;
                end if;
            end if;
        end process;


        COUNT_PROCESS_Z1 : process (CLK)
        begin
            if rising_edge(CLK) then
                if RST = '1' then
                    count_z1 <= 0;
                else
                    count_z1 <= count;
                end if;
            end if;
        end process;

        -- This process drives the rxReady flag
        -- for FIFO Writes, halting I/O
        -- operations when it becomes full.
        RXREADY_PROCESS : process (count)
        begin
            if count < ramDepth - 1 then
                rxReady <= '1';
            else
                rxReady <= '0';
            end if;
        end process;

        -- This process shall handle the detection of a simultaneous
        -- Read and Write operation, which would leave the count unchanged.
        -- It sets the rxtxSimul flag high on occurence on the next clock cycle.
        RXTXSIMUL_PROCESS : process(CLK)
        begin
            if rising_edge(CLK) then
                if RST = '1' then
                    rxTxSimul <= '0';
                else
                    rxTxSimul <= '0';

                    -- If all the I/O Flags are high, trigger the simul flag
                    if rxReady = '1' and TXVALID = '1' and
                       TXREADY = '1' and rxValid = '1' then
                            rxTxSimul <= '1';
                    end if;
                end if;
            end if;
        end process;

        -- This process drives the TxValid flag
        -- for FIFO reads. This needs to handle the extra clock cycle delay
        -- in response, which is the purpose of count_z1!
        TXVALID_RROCESS : process (count, count_z1, rxTxSimul)
        begin

            -- We say we're valid if neither of the following
            -- have occurred
            txValid <= '1'

            --Other wise first check if the ram became empty
            -- last I/O operation
            if count = 0 or count_z1 = 0 then
                txValid <= '0';
            end if;

            -- If a simulatneous I/O operation happened near empty
            if count = 1 and rxTxSimul = '1' then
                txValid <= '0';
            end if;

        end process;


  end architecture RTL;
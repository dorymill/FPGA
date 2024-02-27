-- VHDL Data Types

-- Logical Data Types
-- Data Type: std_logic (boolean value)
signal sig_A : std_logic := '0'; -- Logic values need quotes
signal sig_B : std_logic := '1'; 

sig_A <= '1'; -- Flip signal A and B
sig_B <= '0';
sig_A <= sig_B -- Set the value of sig_A to sig_B

-- Data Type: std_logic_vector (array of boolean values)
signal sig_C : std_logic_vector(5 downto 0) := "000000"; -- More than one char for init gets double quotes
signal sig_D : std_logic_Vector(5 downto 0) := (others => '1'); -- others=> allows us to init all values at once
sig_C <= sig_D; -- Signal vectors can be assigned to each other as long as the size matches
sig_C(3) <= sig_D(1); -- Signal vectors can be changed element by element

-- Data Type: unsigned (unsigned integer of given length)
signal sig_E : unsigned(3 downto 0) := (others => '0'); -- Can be initialized bitwise
signal sig_F : unsigned(3 downto 0) := "0010"; -- Initialized to two!
sig_E <= (others=> '1'); -- Can be set using others=>
sig_E <= sig_F + 1; -- Can do assignment via math!
sig_F(3) <= '1'; -- Can manipulate the bits

-- Data Type: signed (two's complement representation of integer)
sig_G : signed(3 downto 0) := (others => '0'); -- Initialized to 0
sig_H : signed(3 downto 0) := "1011"; -- Initialized to -5
sig_G <= (others => '0'); -- Can also be intialized with others
sig_H <= sig_G - 1;

-- Data Type: integer (cannot be manipulated bitwise, 32 bits wide default)
signal sig_I : integer range 0 to 255 := 0; -- Range can be specified
signal sig_J : integer range 0 to 255 := 5;
sig_I <= 4;
sig_I <= sig_J + 5; -- 10
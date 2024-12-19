use IEEE.NUMERIC_STD_UNSIGNED.all;
ENTITY TB_Processor IS
END TB_Processor;


ARCHITECTURE behavior OF TB_Processor IS 

	 -- Component Declaration for the Design Under Test (DUT)
 
    COMPONENT Top
    PORT(
         clock : IN  std_logic;
         reset : IN  std_logic;
         addr : IN  std_logic_vector(31 downto 0);
         rdata : OUT  std_logic_vector(31 downto 0);
         wdata : IN  std_logic_vector(31 downto 0);
         flush : IN  std_logic;
         rd : IN  std_logic;
         wr : IN  std_logic;
         stall : OUT  std_logic
        );
    END COMPONENT;
  
  
  COMPONENT MIPSProcessor
    PORT(
         CLK : IN  std_logic;
			Reset : IN std_logic
        );
    END COMPONENT;
    
   --signal d : integer := 4;
   --Inputs
   signal clock : std_logic := '0';
   signal reset : std_logic := '0';
   signal addr : std_logic_vector(31 downto 0) := (others => '0');
   signal wdata : std_logic_vector(31 downto 0) := (others => '0');
   signal flush : std_logic := '0';
   signal rd : std_logic := '0';
   signal wr : std_logic := '0';
   
   
    type ramtype is array (489 downto 0) of

STD_LOGIC_VECTOR(31 downto 0);
   
   
        signal CLK : std_logic := '0';
--     signal Reset : std_logic := '0';
--     signal clock : std_logic := '0';
--     --signal reset : std_logic := '0';
--     signal addr : std_logic_vector(31 downto 0) := (others => '0');
--     signal rdata : std_logic_vector(31 downto 0);
--     signal wdata : std_logic_vector(31 downto 0) := (others => '0');
--     signal flush : std_logic := '0';
--     signal rd : std_logic := '0';
--     signal wr : std_logic := '0';
--     signal stall : std_logic;

--     -- Clock period definitions
     constant CLK_period : time := 10 ns;
--     constant clock_period : time := 20 us;

   
   signal current_test_data : std_logic_vector(31 downto 0);
	signal current_test_addr : std_logic_vector(31 downto 0);

 
 	--Outputs
   signal rdata : std_logic_vector(31 downto 0);
   signal stall : std_logic;

   -- Clock period definitions
   constant clock_period : time := 1 us; 
	
	-- ARRAY TO STORE TEST VECTORS
	type my_array is array (0 to 489) of STD_LOGIC_VECTOR (31 downto 0);
   signal test_data : my_array := (OTHERS => (OTHERS =>'0'));
   signal test_addr : my_array := (OTHERS => (OTHERS =>'0'));	
 
   ------------------- USER PROCEDURES ------------------------
	
	-- TO RESET SYSTEM 
	procedure RESET_SYS (signal reset : out std_logic) is
	begin
	   reset <= '0';
		wait for 4*clock_period;
		reset <= '1';
	end procedure;
	
	-- MODELS A LATENCY OF 4 CYCLES UNTIL THE NEXT INSTRUCTION IS DECODED
	procedure HALT (signal wr : out std_logic;
                   signal rd : out std_logic) is
	begin
	   wait for clock_period;
	   wait until clock = '1' and stall = '0';
	   wait for 1.5*clock_period; -- WAIT THEN ACKNOWLEDGE
	   wr <= '0';
		rd <= '0';		
	   wait for 4*clock_period;   -- MODELS THE LATENCY
	end procedure;
	
	-- FINISH
	procedure FINISH is
	begin
	   wait;
	end procedure;
	
	-- FLUSH INSTRUCTION
	procedure FLUSH_CACHE (signal flush : out std_logic) is
	begin
	   flush <= '1';
		wait for clock_period;
		flush <= '0';
	end procedure;
	
	-- WRITE INSTRUCTION
	procedure MEM_WR (signal tb_data : in std_logic_vector(31 downto 0);
							signal tb_addr : in std_logic_vector(31 downto 0);
							signal wdata   : out std_logic_vector(31 downto 0);
							signal addr    : out std_logic_vector(31 downto 0);
							signal wr      : out std_logic;
							signal rd      : out std_logic) is
	begin
      wdata <= tb_data;
		addr  <= tb_addr;
		wr    <= '1';
		rd	   <= '0';
   end procedure;	
	
	-- READ INSTRUCTION
	procedure MEM_RD (signal tb_addr : in std_logic_vector(31 downto 0);							
							signal addr    : out std_logic_vector(31 downto 0);
							signal wr      : out std_logic;
							signal rd      : out std_logic) is
	begin      
		addr  <= tb_addr;
		wr    <= '0';
		rd	   <= '1';
   end procedure;	
   
    --type Memory is array (0 to 269) of STD_LOGIC_VECTOR(31 downto 0);
    --signal IMem : Memory := (others => X"00000000");  -- Initialize with zeros

    -- File declaration for reading the instructions
    -- file imem_file : text open read_mode is "test.dat";
    file imem_file : text open read_mode is "bench4.bin";
	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Top PORT MAP (
          clock => clock,
          reset => reset,
          addr => addr,
          rdata => rdata,
          wdata => wdata,
          flush => flush,
          rd => rd,
          wr => wr,
          stall => stall
        );
        
        
      
    -- Process to read instructions from the file and initialize IMem
    load_instructions: process
    variable mem: ramtype;
        variable line_content : line;
        variable hex_instr : STD_LOGIC_VECTOR(31 downto 0);
         variable i, index, result, str_length: integer;
        variable L: line;
        variable j: integer;
        variable ch: character;
    begin
        -- Read each line and load it into IMem
--         while not endfile(imem_file) and i < 270 loop
--             -- Read one line from the file
--             readline(imem_file, line_content);
            
--             -- Report the line read from the file
--             --report "Read line from file: " & line_content.all;
            
--             -- Initialize hex_instr to all zeros
--             hex_instr := (others => '0');

--             result := 0;    
--             for j in 0 to 7 loop  -- Use 0 to 7 for the loop index
--                 read(line_content, ch);
--                 if '0' <= ch and ch <= '9' then 
--                     result := character'pos(ch) - character'pos('0');
--                 elsif 'a' <= ch and ch <= 'f' then
--                     result := character'pos(ch) - character'pos('a') + 10;
--                 elsif 'A' <= ch and ch <= 'F' then  -- Handle uppercase hex
--                     result := character'pos(ch) - character'pos('A') + 10;
--                 else
--                     report "Format error on line " & integer'image(i)
--                         severity error;
--                 end if;
--                 hex_instr(31 - j * 4 downto 28 - j * 4) := std_logic_vector(to_unsigned(result, 4));  -- Convert result to 4-bit
--             end loop;

--             -- Assign the instruction to the IMem array
--             test_data(i) <= hex_instr;  -- Assign the whole hex instruction
--             i := i + 1;
--         end loop;
         for i in 0 to 489 loop -- set all contents low

mem(i) := (others => '0');

end loop;

index := 0;

FILE_OPEN (imem_file, "bench2.bin", READ_MODE);

readline(imem_file, L);

result := 0;

index := 0;

str_length := L'length;

report integer'image(str_length);

i := 4;

for j in 1 to str_length loop

read (L, ch);

--hex_instr := (others => '0');

result := character'pos(ch);

mem(index)(39-i*8 downto 32-i*8) := to_std_logic_vector(result,8);

--hex_instr(39-i*8 downto 32-i*8) := to_std_logic_vector(to_unsigned(result, 4));
--report "Result:" & to_hstring(mem(index));
i := i - 1;

if i = 0 then

test_data(index) <= mem(index);  -- Assign the whole hex instruction
--report "Result:" & to_hstring(hex_instr(index));



           
index := index + 1;

i := 4;

end if;

end loop;
        
                wait;  -- End the process after initialization
    end process load_instructions;
        
        
        
        
        
        
        
        
        
        
init_test_addr : process
begin        
        
		  
-------------- TEST VECTORS -----------------
-- Initial addresses and data patterns
    test_addr(0)  <= x"00000201"; -- WRITE MISS
    test_addr(1)  <= x"00000201"; -- WRITE MISS
    test_addr(2)  <= x"00000203"; -- READ MISS
    test_addr(3)  <= x"00000201"; -- READ HIT
    test_addr(4)  <= x"00000202"; -- WRITE HIT
    test_addr(5)  <= x"00000142"; -- WRITE MISS
    test_addr(6)  <= x"00000201"; -- WRITE HIT
    test_addr(7)  <= x"00000203"; -- WRITE HIT
    test_addr(8)  <= x"00000203"; -- READ HIT
    test_addr(9)  <= x"00000200"; -- READ HIT
    test_addr(10) <= x"00000283"; -- READ MISS
    test_addr(11) <= x"00000282"; -- WRITE HIT
    test_addr(12) <= x"00000006"; -- READ MISS
    test_addr(13) <= x"00000004"; -- WRITE HIT
    test_addr(14) <= x"00000004"; -- READ HIT
    test_addr(15) <= x"00000282"; -- READ HIT
    test_addr(16) <= x"00000285"; -- READ MISS
    test_addr(17) <= x"00000286"; -- READ MISS
    test_addr(18) <= x"00000285"; -- READ HIT
    
    
    -------------- TEST VECTORS -----------------

test_addr(19)  <= std_logic_vector(to_unsigned(16#000004# + 19, test_addr(19)'length));  -- READ HIT
test_addr(20)  <= std_logic_vector(to_unsigned(16#000200# + (20 / 10), test_addr(20)'length)); -- READ MISS
test_addr(21)  <= std_logic_vector(to_unsigned(16#000004# + 21, test_addr(21)'length));  -- READ HIT
test_addr(22)  <= std_logic_vector(to_unsigned(16#000004# + 22, test_addr(22)'length));  -- READ HIT
test_addr(23)  <= std_logic_vector(to_unsigned(16#000004# + 23, test_addr(23)'length));  -- READ HIT
test_addr(24)  <= std_logic_vector(to_unsigned(16#000140# + (24 / 5), test_addr(24)'length));  -- WRITE MISS
test_addr(25)  <= std_logic_vector(to_unsigned(16#000004# + 25, test_addr(25)'length));  -- READ HIT
test_addr(26)  <= std_logic_vector(to_unsigned(16#000004# + 26, test_addr(26)'length));  -- READ HIT
test_addr(27)  <= std_logic_vector(to_unsigned(16#000004# + 27, test_addr(27)'length));  -- READ HIT
test_addr(28)  <= std_logic_vector(to_unsigned(16#000004# + 28, test_addr(28)'length));  -- READ HIT
test_addr(29)  <= std_logic_vector(to_unsigned(16#000004# + 29, test_addr(29)'length));  -- READ HIT
test_addr(30)  <= std_logic_vector(to_unsigned(16#000200# + (30 / 10), test_addr(30)'length)); -- READ MISS
test_addr(31)  <= std_logic_vector(to_unsigned(16#000004# + 31, test_addr(31)'length));  -- READ HIT

-- Continue this pattern for test_addr(32) to test_addr(209)


test_addr(32)  <= std_logic_vector(to_unsigned(16#000004# + 32, test_addr(32)'length));  -- READ HIT
test_addr(33)  <= std_logic_vector(to_unsigned(16#000004# + 33, test_addr(33)'length));  -- READ HIT
test_addr(34)  <= std_logic_vector(to_unsigned(16#000004# + 34, test_addr(34)'length));  -- READ HIT
test_addr(35)  <= std_logic_vector(to_unsigned(16#000140# + (35 / 5), test_addr(35)'length));  -- WRITE MISS
test_addr(36)  <= std_logic_vector(to_unsigned(16#000004# + 36, test_addr(36)'length));  -- READ HIT
test_addr(37)  <= std_logic_vector(to_unsigned(16#000004# + 37, test_addr(37)'length));  -- READ HIT
test_addr(38)  <= std_logic_vector(to_unsigned(16#000004# + 38, test_addr(38)'length));  -- READ HIT
test_addr(39)  <= std_logic_vector(to_unsigned(16#000004# + 39, test_addr(39)'length));  -- READ HIT
test_addr(40)  <= std_logic_vector(to_unsigned(16#000200# + (40 / 10), test_addr(40)'length)); -- READ MISS
test_addr(41)  <= std_logic_vector(to_unsigned(16#000004# + 41, test_addr(41)'length));  -- READ HIT
test_addr(42)  <= std_logic_vector(to_unsigned(16#000004# + 42, test_addr(42)'length));  -- READ HIT
test_addr(43)  <= std_logic_vector(to_unsigned(16#000004# + 43, test_addr(43)'length));  -- READ HIT
test_addr(44)  <= std_logic_vector(to_unsigned(16#000004# + 44, test_addr(44)'length));  -- READ HIT
test_addr(45)  <= std_logic_vector(to_unsigned(16#000140# + (45 / 5), test_addr(45)'length));  -- WRITE MISS
test_addr(46)  <= std_logic_vector(to_unsigned(16#000004# + 46, test_addr(46)'length));  -- READ HIT
test_addr(47)  <= std_logic_vector(to_unsigned(16#000004# + 47, test_addr(47)'length));  -- READ HIT
test_addr(48)  <= std_logic_vector(to_unsigned(16#000004# + 48, test_addr(48)'length));  -- READ HIT
test_addr(49)  <= std_logic_vector(to_unsigned(16#000004# + 49, test_addr(49)'length));  -- READ HIT
test_addr(50)  <= std_logic_vector(to_unsigned(16#000200# + (50 / 10), test_addr(50)'length)); -- READ MISS

test_addr(51)  <= std_logic_vector(to_unsigned(16#000004# + 51, test_addr(51)'length));  -- READ HIT
test_addr(52)  <= std_logic_vector(to_unsigned(16#000004# + 52, test_addr(52)'length));  -- READ HIT
test_addr(53)  <= std_logic_vector(to_unsigned(16#000004# + 53, test_addr(53)'length));  -- READ HIT
test_addr(54)  <= std_logic_vector(to_unsigned(16#000004# + 54, test_addr(54)'length));  -- READ HIT
test_addr(55)  <= std_logic_vector(to_unsigned(16#000140# + (55 / 5), test_addr(55)'length));  -- WRITE MISS
test_addr(56)  <= std_logic_vector(to_unsigned(16#000004# + 56, test_addr(56)'length));  -- READ HIT
test_addr(57)  <= std_logic_vector(to_unsigned(16#000004# + 57, test_addr(57)'length));  -- READ HIT
test_addr(58)  <= std_logic_vector(to_unsigned(16#000004# + 58, test_addr(58)'length));  -- READ HIT
test_addr(59)  <= std_logic_vector(to_unsigned(16#000004# + 59, test_addr(59)'length));  -- READ HIT
test_addr(60)  <= std_logic_vector(to_unsigned(16#000200# + (60 / 10), test_addr(60)'length)); -- READ MISS
test_addr(61)  <= std_logic_vector(to_unsigned(16#000004# + 61, test_addr(61)'length));  -- READ HIT
test_addr(62)  <= std_logic_vector(to_unsigned(16#000004# + 62, test_addr(62)'length));  -- READ HIT
test_addr(63)  <= std_logic_vector(to_unsigned(16#000004# + 63, test_addr(63)'length));  -- READ HIT
test_addr(64)  <= std_logic_vector(to_unsigned(16#000004# + 64, test_addr(64)'length));  -- READ HIT
test_addr(65)  <= std_logic_vector(to_unsigned(16#000140# + (65 / 5), test_addr(65)'length));  -- WRITE MISS
test_addr(66)  <= std_logic_vector(to_unsigned(16#000004# + 66, test_addr(66)'length));  -- READ HIT
test_addr(67)  <= std_logic_vector(to_unsigned(16#000004# + 67, test_addr(67)'length));  -- READ HIT
test_addr(68)  <= std_logic_vector(to_unsigned(16#000004# + 68, test_addr(68)'length));  -- READ HIT
test_addr(69)  <= std_logic_vector(to_unsigned(16#000004# + 69, test_addr(69)'length));  -- READ HIT
test_addr(70)  <= std_logic_vector(to_unsigned(16#000200# + (70 / 10), test_addr(70)'length)); -- READ MISS
test_addr(71)  <= std_logic_vector(to_unsigned(16#000004# + 71, test_addr(71)'length));  -- READ HIT
test_addr(72)  <= std_logic_vector(to_unsigned(16#000004# + 72, test_addr(72)'length));  -- READ HIT
test_addr(73)  <= std_logic_vector(to_unsigned(16#000004# + 73, test_addr(73)'length));  -- READ HIT
test_addr(74)  <= std_logic_vector(to_unsigned(16#000004# + 74, test_addr(74)'length));  -- READ HIT
test_addr(75)  <= std_logic_vector(to_unsigned(16#000140# + (75 / 5), test_addr(75)'length));  -- WRITE MISS
test_addr(76)  <= std_logic_vector(to_unsigned(16#000004# + 76, test_addr(76)'length));  -- READ HIT
test_addr(77)  <= std_logic_vector(to_unsigned(16#000004# + 77, test_addr(77)'length));  -- READ HIT
test_addr(78)  <= std_logic_vector(to_unsigned(16#000004# + 78, test_addr(78)'length));  -- READ HIT
test_addr(79)  <= std_logic_vector(to_unsigned(16#000004# + 79, test_addr(79)'length));  -- READ HIT
test_addr(80)  <= std_logic_vector(to_unsigned(16#000200# + (80 / 10), test_addr(80)'length)); -- READ MISS



test_addr(81)  <= std_logic_vector(to_unsigned(16#000004# + 81, test_addr(81)'length));  -- READ HIT
test_addr(82)  <= std_logic_vector(to_unsigned(16#000004# + 82, test_addr(82)'length));  -- READ HIT
test_addr(83)  <= std_logic_vector(to_unsigned(16#000004# + 83, test_addr(83)'length));  -- READ HIT
test_addr(84)  <= std_logic_vector(to_unsigned(16#000004# + 84, test_addr(84)'length));  -- READ HIT
test_addr(85)  <= std_logic_vector(to_unsigned(16#000140# + (85 / 5), test_addr(85)'length));  -- WRITE MISS
test_addr(86)  <= std_logic_vector(to_unsigned(16#000004# + 86, test_addr(86)'length));  -- READ HIT
test_addr(87)  <= std_logic_vector(to_unsigned(16#000004# + 87, test_addr(87)'length));  -- READ HIT
test_addr(88)  <= std_logic_vector(to_unsigned(16#000004# + 88, test_addr(88)'length));  -- READ HIT
test_addr(89)  <= std_logic_vector(to_unsigned(16#000004# + 89, test_addr(89)'length));  -- READ HIT
test_addr(90)  <= std_logic_vector(to_unsigned(16#000200# + (90 / 10), test_addr(90)'length)); -- READ MISS
test_addr(91)  <= std_logic_vector(to_unsigned(16#000004# + 91, test_addr(91)'length));  -- READ HIT
test_addr(92)  <= std_logic_vector(to_unsigned(16#000004# + 92, test_addr(92)'length));  -- READ HIT
test_addr(93)  <= std_logic_vector(to_unsigned(16#000004# + 93, test_addr(93)'length));  -- READ HIT
test_addr(94)  <= std_logic_vector(to_unsigned(16#000004# + 94, test_addr(94)'length));  -- READ HIT
test_addr(95)  <= std_logic_vector(to_unsigned(16#000140# + (95 / 5), test_addr(95)'length));  -- WRITE MISS
test_addr(96)  <= std_logic_vector(to_unsigned(16#000004# + 96, test_addr(96)'length));  -- READ HIT
test_addr(97)  <= std_logic_vector(to_unsigned(16#000004# + 97, test_addr(97)'length));  -- READ HIT
test_addr(98)  <= std_logic_vector(to_unsigned(16#000004# + 98, test_addr(98)'length));  -- READ HIT
test_addr(99)  <= std_logic_vector(to_unsigned(16#000004# + 99, test_addr(99)'length));  -- READ HIT
test_addr(100) <= std_logic_vector(to_unsigned(16#000200# + (100 / 10), test_addr(100)'length)); -- READ MISS
test_addr(101) <= std_logic_vector(to_unsigned(16#000004# + 101, test_addr(101)'length));  -- READ HIT
test_addr(102) <= std_logic_vector(to_unsigned(16#000004# + 102, test_addr(102)'length));  -- READ HIT
test_addr(103) <= std_logic_vector(to_unsigned(16#000004# + 103, test_addr(103)'length));  -- READ HIT
test_addr(104) <= std_logic_vector(to_unsigned(16#000004# + 104, test_addr(104)'length));  -- READ HIT
test_addr(105) <= std_logic_vector(to_unsigned(16#000140# + (105 / 5), test_addr(105)'length));  -- WRITE MISS
test_addr(106) <= std_logic_vector(to_unsigned(16#000004# + 106, test_addr(106)'length));  -- READ HIT
test_addr(107) <= std_logic_vector(to_unsigned(16#000004# + 107, test_addr(107)'length));  -- READ HIT
test_addr(108) <= std_logic_vector(to_unsigned(16#000004# + 108, test_addr(108)'length));  -- READ HIT
test_addr(109) <= std_logic_vector(to_unsigned(16#000004# + 109, test_addr(109)'length));  -- READ HIT
test_addr(110) <= std_logic_vector(to_unsigned(16#000200# + (110 / 10), test_addr(110)'length)); -- READ MISS

test_addr(111) <= std_logic_vector(to_unsigned(16#000004# + 111, test_addr(111)'length));  -- READ HIT
test_addr(112) <= std_logic_vector(to_unsigned(16#000004# + 112, test_addr(112)'length));  -- READ HIT
test_addr(113) <= std_logic_vector(to_unsigned(16#000004# + 113, test_addr(113)'length));  -- READ HIT
test_addr(114) <= std_logic_vector(to_unsigned(16#000004# + 114, test_addr(114)'length));  -- READ HIT
test_addr(115) <= std_logic_vector(to_unsigned(16#000140# + (115 / 5), test_addr(115)'length));  -- WRITE MISS
test_addr(116) <= std_logic_vector(to_unsigned(16#000004# + 116, test_addr(116)'length));  -- READ HIT
test_addr(117) <= std_logic_vector(to_unsigned(16#000004# + 117, test_addr(117)'length));  -- READ HIT
test_addr(118) <= std_logic_vector(to_unsigned(16#000004# + 118, test_addr(118)'length));  -- READ HIT
test_addr(119) <= std_logic_vector(to_unsigned(16#000004# + 119, test_addr(119)'length));  -- READ HIT
test_addr(120) <= std_logic_vector(to_unsigned(16#000200# + (120 / 10), test_addr(120)'length)); -- READ MISS
test_addr(121) <= std_logic_vector(to_unsigned(16#000004# + 121, test_addr(121)'length));  -- READ HIT
test_addr(122) <= std_logic_vector(to_unsigned(16#000004# + 122, test_addr(122)'length));  -- READ HIT
test_addr(123) <= std_logic_vector(to_unsigned(16#000004# + 123, test_addr(123)'length));  -- READ HIT
test_addr(124) <= std_logic_vector(to_unsigned(16#000004# + 124, test_addr(124)'length));  -- READ HIT
test_addr(125) <= std_logic_vector(to_unsigned(16#000140# + (125 / 5), test_addr(125)'length));  -- WRITE MISS
test_addr(126) <= std_logic_vector(to_unsigned(16#000004# + 126, test_addr(126)'length));  -- READ HIT
test_addr(127) <= std_logic_vector(to_unsigned(16#000004# + 127, test_addr(127)'length));  -- READ HIT
test_addr(128) <= std_logic_vector(to_unsigned(16#000004# + 128, test_addr(128)'length));  -- READ HIT
test_addr(129) <= std_logic_vector(to_unsigned(16#000004# + 129, test_addr(129)'length));  -- READ HIT
test_addr(130) <= std_logic_vector(to_unsigned(16#000200# + (130 / 10), test_addr(130)'length)); -- READ MISS
test_addr(131) <= std_logic_vector(to_unsigned(16#000004# + 131, test_addr(131)'length));  -- READ HIT
test_addr(132) <= std_logic_vector(to_unsigned(16#000004# + 132, test_addr(132)'length));  -- READ HIT
test_addr(133) <= std_logic_vector(to_unsigned(16#000004# + 133, test_addr(133)'length));  -- READ HIT
test_addr(134) <= std_logic_vector(to_unsigned(16#000004# + 134, test_addr(134)'length));  -- READ HIT
test_addr(135) <= std_logic_vector(to_unsigned(16#000140# + (135 / 5), test_addr(135)'length));  -- WRITE MISS
test_addr(136) <= std_logic_vector(to_unsigned(16#000004# + 136, test_addr(136)'length));  -- READ HIT
test_addr(137) <= std_logic_vector(to_unsigned(16#000004# + 137, test_addr(137)'length));  -- READ HIT
test_addr(138) <= std_logic_vector(to_unsigned(16#000004# + 138, test_addr(138)'length));  -- READ HIT
test_addr(139) <= std_logic_vector(to_unsigned(16#000004# + 139, test_addr(139)'length));  -- READ HIT
test_addr(140) <= std_logic_vector(to_unsigned(16#000200# + (140 / 10), test_addr(140)'length)); -- READ MISS
test_addr(141) <= std_logic_vector(to_unsigned(16#000004# + 141, test_addr(141)'length));  -- READ HIT
test_addr(142) <= std_logic_vector(to_unsigned(16#000004# + 142, test_addr(142)'length));  -- READ HIT
test_addr(143) <= std_logic_vector(to_unsigned(16#000004# + 143, test_addr(143)'length));  -- READ HIT
test_addr(144) <= std_logic_vector(to_unsigned(16#000004# + 144, test_addr(144)'length));  -- READ HIT
test_addr(145) <= std_logic_vector(to_unsigned(16#000140# + (145 / 5), test_addr(145)'length));  -- WRITE MISS
test_addr(146) <= std_logic_vector(to_unsigned(16#000004# + 146, test_addr(146)'length));  -- READ HIT
test_addr(147) <= std_logic_vector(to_unsigned(16#000004# + 147, test_addr(147)'length));  -- READ HIT
test_addr(148) <= std_logic_vector(to_unsigned(16#000004# + 148, test_addr(148)'length));  -- READ HIT
test_addr(149) <= std_logic_vector(to_unsigned(16#000004# + 149, test_addr(149)'length));  -- READ HIT
test_addr(150) <= std_logic_vector(to_unsigned(16#000200# + (150 / 10), test_addr(150)'length)); -- READ MISS
test_addr(151) <= std_logic_vector(to_unsigned(16#000004# + 151, test_addr(151)'length));  -- READ HIT
test_addr(152) <= std_logic_vector(to_unsigned(16#000004# + 152, test_addr(152)'length));  -- READ HIT
test_addr(153) <= std_logic_vector(to_unsigned(16#000004# + 153, test_addr(153)'length));  -- READ HIT
test_addr(154) <= std_logic_vector(to_unsigned(16#000004# + 154, test_addr(154)'length));  -- READ HIT
test_addr(155) <= std_logic_vector(to_unsigned(16#000140# + (155 / 5), test_addr(155)'length));  -- WRITE MISS
test_addr(156) <= std_logic_vector(to_unsigned(16#000004# + 156, test_addr(156)'length));  -- READ HIT
test_addr(157) <= std_logic_vector(to_unsigned(16#000004# + 157, test_addr(157)'length));  -- READ HIT
test_addr(158) <= std_logic_vector(to_unsigned(16#000004# + 158, test_addr(158)'length));  -- READ HIT
test_addr(159) <= std_logic_vector(to_unsigned(16#000004# + 159, test_addr(159)'length));  -- READ HIT
test_addr(160) <= std_logic_vector(to_unsigned(16#000200# + (160 / 10), test_addr(160)'length)); -- READ MISS
test_addr(161) <= std_logic_vector(to_unsigned(16#000004# + 161, test_addr(161)'length));  -- READ HIT
test_addr(162) <= std_logic_vector(to_unsigned(16#000004# + 162, test_addr(162)'length));  -- READ HIT
test_addr(163) <= std_logic_vector(to_unsigned(16#000004# + 163, test_addr(163)'length));  -- READ HIT
test_addr(164) <= std_logic_vector(to_unsigned(16#000004# + 164, test_addr(164)'length));  -- READ HIT
test_addr(165) <= std_logic_vector(to_unsigned(16#000140# + (165 / 5), test_addr(165)'length));  -- WRITE MISS
test_addr(166) <= std_logic_vector(to_unsigned(16#000004# + 166, test_addr(166)'length));  -- READ HIT
test_addr(167) <= std_logic_vector(to_unsigned(16#000004# + 167, test_addr(167)'length));  -- READ HIT
test_addr(168) <= std_logic_vector(to_unsigned(16#000004# + 168, test_addr(168)'length));  -- READ HIT
test_addr(169) <= std_logic_vector(to_unsigned(16#000004# + 169, test_addr(169)'length));  -- READ HIT
test_addr(170) <= std_logic_vector(to_unsigned(16#000200# + (170 / 10), test_addr(170)'length)); -- READ MISS

test_addr(191) <= std_logic_vector(to_unsigned(16#000004# + 191, test_addr(191)'length));  -- READ HIT
test_addr(192) <= std_logic_vector(to_unsigned(16#000004# + 192, test_addr(192)'length));  -- READ HIT
test_addr(193) <= std_logic_vector(to_unsigned(16#000004# + 193, test_addr(193)'length));  -- READ HIT
test_addr(194) <= std_logic_vector(to_unsigned(16#000004# + 194, test_addr(194)'length));  -- READ HIT
test_addr(195) <= std_logic_vector(to_unsigned(16#000140# + (195 / 5), test_addr(195)'length));  -- WRITE MISS
test_addr(196) <= std_logic_vector(to_unsigned(16#000004# + 196, test_addr(196)'length));  -- READ HIT
test_addr(197) <= std_logic_vector(to_unsigned(16#000004# + 197, test_addr(197)'length));  -- READ HIT
test_addr(198) <= std_logic_vector(to_unsigned(16#000004# + 198, test_addr(198)'length));  -- READ HIT
test_addr(199) <= std_logic_vector(to_unsigned(16#000004# + 199, test_addr(199)'length));  -- READ HIT
test_addr(200) <= std_logic_vector(to_unsigned(16#000200# + (200 / 10), test_addr(200)'length));  -- READ MISS
test_addr(201) <= std_logic_vector(to_unsigned(16#000004# + 201, test_addr(201)'length));  -- READ HIT
test_addr(202) <= std_logic_vector(to_unsigned(16#000004# + 202, test_addr(202)'length));  -- READ HIT
test_addr(203) <= std_logic_vector(to_unsigned(16#000004# + 203, test_addr(203)'length));  -- READ HIT
test_addr(204) <= std_logic_vector(to_unsigned(16#000004# + 204, test_addr(204)'length));  -- READ HIT
test_addr(205) <= std_logic_vector(to_unsigned(16#000140# + (205 / 5), test_addr(205)'length));  -- WRITE MISS
test_addr(206) <= std_logic_vector(to_unsigned(16#000004# + 206, test_addr(206)'length));  -- READ HIT
test_addr(207) <= std_logic_vector(to_unsigned(16#000004# + 207, test_addr(207)'length));  -- READ HIT
test_addr(208) <= std_logic_vector(to_unsigned(16#000004# + 208, test_addr(208)'length));  -- READ HIT
test_addr(209) <= std_logic_vector(to_unsigned(16#000004# + 209, test_addr(209)'length));  -- READ HIT
test_addr(210) <= std_logic_vector(to_unsigned(16#000200# + (210 / 10), test_addr(210)'length));  -- READ MISS
test_addr(211) <= std_logic_vector(to_unsigned(16#000004# + 211, test_addr(211)'length));  -- READ HIT
test_addr(212) <= std_logic_vector(to_unsigned(16#000004# + 212, test_addr(212)'length));  -- READ HIT
test_addr(213) <= std_logic_vector(to_unsigned(16#000004# + 213, test_addr(213)'length));  -- READ HIT
test_addr(214) <= std_logic_vector(to_unsigned(16#000004# + 214, test_addr(214)'length));  -- READ HIT
test_addr(215) <= std_logic_vector(to_unsigned(16#000140# + (215 / 5), test_addr(215)'length));  -- WRITE MISS
test_addr(216) <= std_logic_vector(to_unsigned(16#000004# + 216, test_addr(216)'length));  -- READ HIT
test_addr(217) <= std_logic_vector(to_unsigned(16#000004# + 217, test_addr(217)'length));  -- READ HIT
test_addr(218) <= std_logic_vector(to_unsigned(16#000004# + 218, test_addr(218)'length));  -- READ HIT
test_addr(219) <= std_logic_vector(to_unsigned(16#000004# + 219, test_addr(219)'length));  -- READ HIT
test_addr(220) <= std_logic_vector(to_unsigned(16#000200# + (220 / 10), test_addr(220)'length));  -- READ MISS
test_addr(221) <= std_logic_vector(to_unsigned(16#000004# + 221, test_addr(221)'length));  -- READ HIT
test_addr(222) <= std_logic_vector(to_unsigned(16#000004# + 222, test_addr(222)'length));  -- READ HIT
test_addr(223) <= std_logic_vector(to_unsigned(16#000004# + 223, test_addr(223)'length));  -- READ HIT
test_addr(224) <= std_logic_vector(to_unsigned(16#000004# + 224, test_addr(224)'length));  -- READ HIT
test_addr(225) <= std_logic_vector(to_unsigned(16#000140# + (225 / 5), test_addr(225)'length));  -- WRITE MISS
test_addr(226) <= std_logic_vector(to_unsigned(16#000004# + 226, test_addr(226)'length));  -- READ HIT
test_addr(227) <= std_logic_vector(to_unsigned(16#000004# + 227, test_addr(227)'length));  -- READ HIT
test_addr(228) <= std_logic_vector(to_unsigned(16#000004# + 228, test_addr(228)'length));  -- READ HIT
test_addr(229) <= std_logic_vector(to_unsigned(16#000004# + 229, test_addr(229)'length));  -- READ HIT
test_addr(230) <= std_logic_vector(to_unsigned(16#000200# + (230 / 10), test_addr(230)'length));  -- READ MISS
test_addr(231) <= std_logic_vector(to_unsigned(16#000004# + 231, test_addr(231)'length));  -- READ HIT
test_addr(232) <= std_logic_vector(to_unsigned(16#000004# + 232, test_addr(232)'length));  -- READ HIT
test_addr(233) <= std_logic_vector(to_unsigned(16#000004# + 233, test_addr(233)'length));  -- READ HIT
test_addr(234) <= std_logic_vector(to_unsigned(16#000004# + 234, test_addr(234)'length));  -- READ HIT
test_addr(235) <= std_logic_vector(to_unsigned(16#000140# + (235 / 5), test_addr(235)'length));  -- WRITE MISS
test_addr(236) <= std_logic_vector(to_unsigned(16#000004# + 236, test_addr(236)'length));  -- READ HIT
test_addr(237) <= std_logic_vector(to_unsigned(16#000004# + 237, test_addr(237)'length));  -- READ HIT
test_addr(238) <= std_logic_vector(to_unsigned(16#000004# + 238, test_addr(238)'length));  -- READ HIT
test_addr(239) <= std_logic_vector(to_unsigned(16#000004# + 239, test_addr(239)'length));  -- READ HIT
test_addr(240) <= std_logic_vector(to_unsigned(16#000200# + (240 / 10), test_addr(240)'length));  -- READ MISS
test_addr(241) <= std_logic_vector(to_unsigned(16#000004# + 241, test_addr(241)'length));  -- READ HIT
test_addr(242) <= std_logic_vector(to_unsigned(16#000004# + 242, test_addr(242)'length));  -- READ HIT
test_addr(243) <= std_logic_vector(to_unsigned(16#000004# + 243, test_addr(243)'length));  -- READ HIT
test_addr(244) <= std_logic_vector(to_unsigned(16#000004# + 244, test_addr(244)'length));  -- READ HIT
test_addr(245) <= std_logic_vector(to_unsigned(16#000140# + (245 / 5), test_addr(245)'length));  -- WRITE MISS
test_addr(246) <= std_logic_vector(to_unsigned(16#000004# + 246, test_addr(246)'length));  -- READ HIT
test_addr(247) <= std_logic_vector(to_unsigned(16#000004# + 247, test_addr(247)'length));  -- READ HIT
test_addr(248) <= std_logic_vector(to_unsigned(16#000004# + 248, test_addr(248)'length));  -- READ HIT
test_addr(249) <= std_logic_vector(to_unsigned(16#000004# + 249, test_addr(249)'length));  -- READ HIT
test_addr(250) <= std_logic_vector(to_unsigned(16#000200# + (250 / 10), test_addr(250)'length));  -- READ MISS


    wait; -- Ensure the initialization completes
end process;

-- Print process
--print_test_addr : process
   -- variable i : integer := 0;
--begin
  --  wait for 10 ns; -- Allow time for initialization to complete
   -- for i in 0 to 250 loop  -- Adjust the range as needed
     --   report "Address at index " & integer'image(i) & ": " & std_logic_vector'image(test_addr(i));
   -- end loop;
   -- wait; -- End the process after printing
--end process;

    
-- process
-- variable s: integer := 19;
-- begin
    
--     while s < 40 loop
--         if s mod 10 = 0 then
--             test_addr(s) <= std_logic_vector(to_unsigned(16#00200# + (s / 10), 		 test_addr(s)'length)); -- Example READ MISS
--         elsif s mod 5 = 0 then
--             test_addr(s) <= std_logic_vector(to_unsigned(16#00140# + (s / 5), test_addr(s)'length)); -- Example WRITE MISS
--         else
--             test_addr(s) <= std_logic_vector(to_unsigned(16#00004# + s, test_addr(s)'length));       -- READ HIT example
--         end if;
--         report "Read line from file: IN THE LOOP" & integer'image(s);
--     	s := s + 1;
--     end loop;
-- end process;
   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 
   
   -- Stimulus process
   stim_proc: process
   variable i : integer := 0;
   begin	
	
      ---------- MODELLING INSTRUCTION EXECUTION BY A PROCESSOR --------
		
		-- INITIAL OPERATIONS
      RESET_SYS(reset);
      FLUSH_CACHE(flush);
		
		-- RANDOM READ WRITE REQUESTS TO MEMORY BY PROCESSOR
      MEM_WR(test_data(0),test_addr(0),wdata,addr,wr,rd);		
		HALT(wr,rd);
		
		MEM_WR(test_data(1),test_addr(1),wdata,addr,wr,rd);
		HALT(wr,rd);
		
		MEM_RD(test_addr(2),addr,wr,rd);
		HALT(wr,rd);
		
		MEM_RD(test_addr(3),addr,wr,rd);	
		HALT(wr,rd);
		
		MEM_WR(test_data(4),test_addr(4),wdata,addr,wr,rd);	
		HALT(wr,rd);
		
	   MEM_WR(test_data(5),test_addr(5),wdata,addr,wr,rd);	
		HALT(wr,rd);	
		
		MEM_WR(test_data(6),test_addr(6),wdata,addr,wr,rd);	
		HALT(wr,rd);
		
		MEM_WR(test_data(7),test_addr(7),wdata,addr,wr,rd);	
		HALT(wr,rd);
		
		MEM_RD(test_addr(8),addr,wr,rd);	
		HALT(wr,rd);
		
		MEM_RD(test_addr(9),addr,wr,rd);	
		HALT(wr,rd);
		
		MEM_RD(test_addr(10),addr,wr,rd);	
		HALT(wr,rd);
		
		MEM_WR(test_data(11),test_addr(11),wdata,addr,wr,rd);	
		HALT(wr,rd);
		
		MEM_RD(test_addr(12),addr,wr,rd);	
		HALT(wr,rd);
		
		MEM_WR(test_data(13),test_addr(13),wdata,addr,wr,rd);	
		HALT(wr,rd);
		
		MEM_RD(test_addr(14),addr,wr,rd);	
		HALT(wr,rd);
		
		MEM_RD(test_addr(15),addr,wr,rd);	
		HALT(wr,rd);
        
        MEM_WR(test_data(16),test_addr(16),wdata,addr,wr,rd);	
		HALT(wr,rd);
        
        MEM_WR(test_data(17),test_addr(17),wdata,addr,wr,rd);	
		HALT(wr,rd);
        
        MEM_WR(test_data(18),test_addr(18),wdata,addr,wr,rd);	
		HALT(wr,rd);
        
        
        
        MEM_WR(test_data(19),test_addr(19),wdata,addr,wr,rd);		
		HALT(wr,rd);
		
		MEM_WR(test_data(20),test_addr(20),wdata,addr,wr,rd);
		HALT(wr,rd);
		
		MEM_RD(test_addr(21),addr,wr,rd);
		HALT(wr,rd);
		
		MEM_RD(test_addr(22),addr,wr,rd);	
		HALT(wr,rd);
		
		MEM_WR(test_data(23),test_addr(23),wdata,addr,wr,rd);	
		HALT(wr,rd);
		
	   MEM_WR(test_data(24),test_addr(24),wdata,addr,wr,rd);	
		HALT(wr,rd);	
		
		MEM_WR(test_data(25),test_addr(25),wdata,addr,wr,rd);	
		HALT(wr,rd);
		
		MEM_WR(test_data(26),test_addr(26),wdata,addr,wr,rd);	
		HALT(wr,rd);
		
		MEM_RD(test_addr(27),addr,wr,rd);	
		HALT(wr,rd);
		
		MEM_RD(test_addr(28),addr,wr,rd);	
		HALT(wr,rd);
		
		MEM_RD(test_addr(29),addr,wr,rd);	
		HALT(wr,rd);
		
		MEM_WR(test_data(30),test_addr(30),wdata,addr,wr,rd);	
		HALT(wr,rd);
		
		MEM_RD(test_addr(31),addr,wr,rd);	
		HALT(wr,rd);
		
		MEM_WR(test_data(32),test_addr(32),wdata,addr,wr,rd);	
		HALT(wr,rd);
		
		MEM_RD(test_addr(33),addr,wr,rd);	
		HALT(wr,rd);
		
        -- Read Hit/Miss?
		MEM_RD(test_addr(34),addr,wr,rd);	
		HALT(wr,rd);
        
        MEM_WR(test_data(35),test_addr(35),wdata,addr,wr,rd);	
		HALT(wr,rd);
        
        MEM_WR(test_data(36),test_addr(36),wdata,addr,wr,rd);	
		HALT(wr,rd);
        
        -- Write Hit/Miss?
        MEM_WR(test_data(37),test_addr(37),wdata,addr,wr,rd);	
		HALT(wr,rd);
        
        
    while i < 232 loop
        current_test_data <= test_data(38 + i);
        current_test_addr <= test_addr(38 + i);
			
        if i mod 2 > 0 then
            MEM_RD(current_test_addr,addr,wr,rd);	
            HALT(wr,rd);
               -- Report final value for validation
    report "Final value read from test_addr(" & integer'image(i - 1) & ") = " 
        & std_logic_vector'image(rdata);
        end if;
           
        if i mod 2 = 0 then
            -- Use the static signals in MEM_WR
            MEM_WR(current_test_data, current_test_addr, wdata, addr, wr, rd);
            HALT(wr, rd);
               -- Report final value for validation
    report "Final value read from test_addr(" & integer'image(i - 1) & ") = " 
        & std_logic_vector'image(rdata);
        end if;
           
        i := i + 1;
     

    end loop;
    
    
    
    for i in 0 to 231 loop  -- Adjust the range as needed
       -- report "Address at index " & integer'image(i) & ": " & std_logic_vector'image(test_addr(i));
       current_test_addr <= test_addr(i);
       MEM_RD(current_test_addr,addr,wr,rd);	
               report "Address at test address " & std_logic_vector'image(current_test_addr) & " read data " & std_logic_vector'image(rdata);
		HALT(wr,rd);
        --IMem(i) := rdata;
        
        --report "IMEM " & integer'image(i) & " read data " & std_logic_vector'image(IMem(i));

    end loop;
   



    -- Final read and validation
    FLUSH_CACHE(flush);
    MEM_RD(current_test_addr, addr, wr, rd);
    HALT(wr, rd);

    -- Report final value for validation
    report "Final value read from test_addr(" & integer'image(i - 1) & ") = " 
        & std_logic_vector'image(rdata);

    -- Finish the simulation
    FINISH;
end process stim_proc; -- Close the process





-- -- Instantiate the Unit Under Test (UUT)
--    uut_MIPS: MIPSProcessor PORT MAP (
--           CLK => CLK,
-- 			 Reset => Reset
--         );

--    -- Clock process definitions
--    CLK_process :process
--    begin
-- 		CLK <= '0';
-- 		wait for CLK_period/2;
-- 		CLK <= '1';
-- 		wait for CLK_period/2;
--    end process;
 

--    -- Stimulus process
--    stim_proc_MIPS: process
--    begin		
	
-- 		Reset <= '1';
-- 		wait for 10 ns;	
-- 		Reset <= '0';
-- 		wait for 100 ns;

--       wait for CLK_period*10;
		
--    end process;
end behavior;

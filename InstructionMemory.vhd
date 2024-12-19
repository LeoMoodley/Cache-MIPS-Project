library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.NUMERIC_STD_UNSIGNED.all;

use IEEE.NUMERIC_STD_UNSIGNED.all;

entity InstructionMemory is
    port (
        Address     : in  STD_LOGIC_VECTOR(31 downto 0);
        Instruction : out STD_LOGIC_VECTOR(31 downto 0)
    );
end InstructionMemory;

architecture Behavioral of InstructionMemory is
    type Memory is array (0 to 489) of STD_LOGIC_VECTOR(31 downto 0);
    signal IMem : Memory := (others => X"00000000");  -- Initialize with zeros

    -- File declaration for reading the instructions
    -- file imem_file : text open read_mode is "test.dat";
    
    type ramtype is array (489 downto 0) of

STD_LOGIC_VECTOR(31 downto 0);



    file imem_file : text open read_mode is "bench4.bin";

begin
    -- Process to read instructions from the file and initialize IMem
    load_instructions: process
    variable mem: ramtype;
        variable line_content : line;
        variable hex_instr : STD_LOGIC_VECTOR(31 downto 0);
        variable i, index, result, str_length: integer;
        variable L: line;

		variable ch: character;
        variable j: integer;
       -- variable ch: character;
    begin
--         -- Read each line and load it into IMem
--         while not endfile(imem_file) and i < 231 loop
--             -- Read one line from the file
--             readline(imem_file, line_content);
            
--             -- Report the line read from the file
--             report "Read line from file: " & line_content.all;

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

IMem(index) <= mem(index);  -- Assign the whole hex instruction
--report "Result:" & to_hstring(hex_instr(index));



           
index := index + 1;

i := 4;

end if;

end loop;



--             -- Assign the instruction to the IMem array
--             IMem(i) <= hex_instr;  -- Assign the whole hex instruction
--             i := i + 1;
--         end loop;
        
        wait;  -- End the process after initialization
    end process load_instructions;

    -- Process to output the instruction based on the address
    process (Address)
    begin
        Instruction <= IMem(to_integer(unsigned(Address(5 downto 2))));
    end process;

end Behavioral;

-- Adder bit a bit --
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_adder is 
port(
	clk_adder: std_logic;
	data1, data2, carry_in: in std_logic;
	carry_out: out std_logic);
	sum: out std_logic;
end full_adder;

architecture adder of full_adder is
	begin
		sum <= data1 XOR data2 XOR carry_in;
		carry_out <= (data1 AND data2) OR (data1 AND carry_in) OR (data2 AND carry_in);
end architecture adder;

-- End Adder bit a bit --


-- Full adder 8 bits --

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_adder8bits is 
port(
	clk_adder8bits: in std_logic;
	data1_8bits, data2_8bits: in std_logic_vector(7 downto 0);
	carry_in_8bits: in std_logic;
	carry_out_8bits: out std_logic;
	sum_8bits: out std_logic_vector(7 downto 0)
); 
end full_adder8bits;

architecture adder_8_bits of full_adder8bits is
	
	signal carry_vector : std_logic_vector(8 downto 0);

	begin 

	process(clk_adder8bits)
	
	begin 
	if rising_edge(clk_adder8bits) then
	carry_vector(0) <= carry_in_8bits;
		
		for i in 0 to 7 generate
			entity work.full_adder port map(
			data1 => data1_8bits(i),
			data2 => data2_8bits(i),
			carry_in => carry_vector(i),
			sum => sum_8bits(i),
			carry_out => carry_vector(i+1)
			);
		end generate;
		carry_out_8bits <= carry_vector(8);
		end if;
	end process;
end architecture; 

-- End Full adder 8 bits --



-- Subtrator 8 bits -- 

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity subtrador is 
port (
	clk_sub: std_logic;
	data1_sub, data2_sub: std_logic_vector(7 downto 0);
	signal_number: std_logic;
	carry_out_sub: std_logic;
	sub_8bits: std_logic_vector(7 downto 0);
)
end subtrator; 

	signal carry_vector_sub : std_logic_vector(8 downto 0);


architecture sub of subtrator is 
begin
	for i in 0 to 7 generate
			entity work.full_adder port map(
			data1 => data1_sub(i),
			data2 => (NOT data2_sub(i)) + 1,
			carry_in => carry_vector_sub(i),
			sum => sum_8bits(i),
			carry_out => carry_vector(i+1)
			);
		end generate;
	carry_out_8bits <= 1;
end architecture;

-- Subtrator 8 bits --
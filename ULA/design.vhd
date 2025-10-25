library ieee;
use ieee.std_logic_1164.all;

entity ULA is
port(
		clk_ula: in std_logic;
		operation_select_ula: in std_logic_vector(7 downto 0);
		data1_ula: in std_logic_vector(7 downto 0);
		data2_ula: in std_logic_vector(7 downto 0);
        output_ula: out std_logic_vector(7 downto 0));
end ULA;

architecture operations of ULA is
  signal output_signal_add: std_logic_vector(7 downto 0);	
  signal output_signal_sub: std_logic_vector(7 downto 0);	
  signal output_signal_and: std_logic_vector(7 downto 0);
  signal output_signal_or: std_logic_vector(7 downto 0);
  signal output_signal_xor: std_logic_vector(7 downto 0);
  signal output_signal_not: std_logic_vector(7 downto 0);
begin


		full_adder_inst: entity work.full_adder8bits port map(
				data1_8bits => data1_ula,
				data2_8bits => data2_ula,
                sum_8bits => output_signal_add
				);

        full_sub_inst: entity work.subtrator port map(
				data1_sub_8bits => data1_ula,
				data2_sub_8bits => data2_ula,
                sub_8bits => output_signal_sub
				);

        and_inst: entity work.and_logic port map(
				data1_and => data1_ula,
				data2_and => data2_ula,
                output_and => output_signal_and
				);

        or_inst: entity work.or_logic port map(
				data1_or => data1_ula,
				data2_or => data2_ula,
                output_or => output_signal_or
				);

        xor_inst: entity work.xor_logic port map(
				data1_xor => data1_ula,
				data2_xor => data2_ula,
                output_xor => output_signal_xor
				);

        not_inst: entity work.not_logic port map(
				data1_not => data1_ula,
                output_not => output_signal_not
				);
   
		process(clk_ula)

		begin

		if rising_edge(clk_ula) then 

        case operation_select_ula is
          when "00000001" =>
            output_ula <= output_signal_add;
          when "00000010" =>
            output_ula <= output_signal_sub;
          when "00000011" =>
            output_ula <= "00000011";
          when "00000100" =>
            output_ula <= "00000100";
          when "00000101" =>
            output_ula <= "00000101";
          when "00000110" => --Aqui
            output_ula <= output_signal_and;
          when "00000111" =>
            output_ula <= output_signal_or;
          when "00001000" =>
            output_ula <= output_signal_xor;
          when "00001001" =>
            output_ula <= output_signal_not;
          when others =>
            output_ula <= (others => '1');	
        end case;
	end if;
end process;
end architecture operations;

--END ULA

-- Somador Bit a bit
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_adder is 
port(
	data1, data2, carry_in: in std_logic;
	carry_out: out std_logic;
	sum: out std_logic);
end full_adder;

architecture adder of full_adder is
	begin
		sum <= data1 XOR data2 XOR carry_in;
		carry_out <= (data1 AND data2) OR (data1 AND carry_in) OR (data2 AND carry_in);
end architecture adder;
-- Fim somador bit a bit

--Somador 8 bits

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_adder8bits is 
port(
	data1_8bits, data2_8bits: in std_logic_vector(7 downto 0);
	carry_out_8bits: out std_logic;
	sum_8bits: out std_logic_vector(7 downto 0)
); 
end full_adder8bits;

architecture adder_8bits of full_adder8bits is
	
	signal carry_vector : std_logic_vector(8 downto 0);

	begin 

    carry_vector(0) <= '0';
		
	G_RIPPLE_ADD:
    for i in 0 to 7 generate
        FA_i: entity work.full_adder
        port map(
            data1 => data1_8bits(i),
            data2 => data2_8bits(i),
            carry_in => carry_vector(i),
            sum => sum_8bits(i),
            carry_out => carry_vector(i+1)
        );
    end generate G_RIPPLE_ADD;
	 
		carry_out_8bits <= carry_vector(8);

end architecture adder_8bits; 
--Fim somador 8 bits

--Subtrator 8 bits
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity subtrator is 
port(
	data1_sub_8bits, data2_sub_8bits: in std_logic_vector(7 downto 0);
	carry_out_sub_8bits: out std_logic;
	sub_8bits: out std_logic_vector(7 downto 0)
); 
end subtrator;

architecture sub_8bits of subtrator is
	
	signal carry_vector_sub : std_logic_vector(8 downto 0);

	begin 

    carry_vector_sub(0) <= '1';
		
	G_RIPPLE_SUB:
    for i in 0 to 7 generate
        FA_i: entity work.full_adder
        port map(
            data1 => data1_sub_8bits(i),
            data2 => (NOT data2_sub_8bits(i)),
            carry_in => carry_vector_sub(i),
            sum => sub_8bits(i),
            carry_out => carry_vector_sub(i+1)
        );
    end generate G_RIPPLE_SUB;
	 
		carry_out_sub_8bits <= carry_vector_sub(8);

end architecture sub_8bits; 

-- Fim subtrator


-- AND
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity and_logic is
port(
  data1_and, data2_and: in std_logic_vector(7 downto 0);
  output_and: out std_logic_vector(7 downto 0)
);
end and_logic; 
 
architecture and_op of and_logic is
begin

  output_and <= data1_and AND data2_and;

end architecture and_op;
--Fim da AND

-- OR
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity or_logic is
port(
  data1_or, data2_or: in std_logic_vector(7 downto 0);
  output_or: out std_logic_vector(7 downto 0)
);
end or_logic; 
 
architecture or_op of or_logic is
begin

  output_or <= data1_or OR data2_or;

end architecture or_op;
--Fim da OR

-- XOR
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xor_logic is
port(
  data1_xor, data2_xor: in std_logic_vector(7 downto 0);
  output_xor: out std_logic_vector(7 downto 0)
);
end xor_logic; 
 
architecture xor_op of xor_logic is
begin

  output_xor <= data1_xor XOR data2_xor;

end architecture xor_op;
-- Fim XOR

-- NOT
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity not_logic is
port(
  data1_not: in std_logic_vector(7 downto 0);
  output_not: out std_logic_vector(7 downto 0)
);
end not_logic; 
 
architecture not_op of not_logic is
begin

  output_not <= (NOT data1_not);

end architecture not_op;
--FIM NOT
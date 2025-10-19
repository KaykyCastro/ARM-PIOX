-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                                                                   │
-- │                                     ARM PIOX                                      │
-- │                                                                                   │
-- │                                                                                   │
-- │                                 Operações da ULA                                  │
-- │                                                                                   │
-- │           ┌─────────────────────┐            ┌─────────────────────┐  			   │
-- │           │     Aritméticas     │            │       Lógicas       │              │
-- │           │─────────────────────│            │─────────────────────│              │                                 
-- │           │ Soma(00000001)	     │		      │ Soma(00000001)	    │		       │
-- │           │ Subtração(00000010) │		      │ Subtração(00000010) │	           │	
-- │		   │ Multi(00000011)     │		      │ Multi(00000011)     │              │	
-- │		   │ Divisão(00000100)   │		      │ Divisão(00000100)   │		       │	
-- │		   │ Mod(00000101)       │		      │ Mod(00000101)       │              │          				
-- │           └─────────────────────┘            └─────────────────────┘              │
-- |																				   │
-- |  Acionamento das funções só ocorrem com clock em borda de subida(Nivél lógico 1)  |
-- │																				   │
-- │                                                                                   │
-- └───────────────────────────────────────────────────────────────────────────────────┘

-- #####################################################################################

-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                                                                                   ┃
-- ┃                               Operações aritméticas                               ┃
-- ┃                                                                                   ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                               Somador Bit a Bit(+)                                │
-- └───────────────────────────────────────────────────────────────────────────────────┘
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
-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        END                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘



-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                               Somador Completo(8+)                                │
-- └───────────────────────────────────────────────────────────────────────────────────┘
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

architecture adder_8bits of full_adder8bits is
	
	signal carry_vector : std_logic_vector(8 downto 0);
	signal temp_carry_out8bits: std_logic;
	signal temp_sum8bits : std_logic_vector(7 downto 0);

	begin 

	carry_vector(0) <= carry_in_8bits;
		
	G_RIPPLE_ADD:
    for i in 0 to 7 generate
        FA_i: entity work.full_adder
        port map(
            data1 => data1_8bits(i),
            data2 => data2_8bits(i),
            carry_in => carry_vector(i),
            sum => temp_sum8bits(i),
            carry_out => carry_vector(i+1)
        );
    end generate G_RIPPLE_ADD;
	 
		temp_carry_out8bits <= carry_vector(8);
	
	process(clk_adder8bits)
	
	begin 
	if rising_edge(clk_adder8bits) then
			sum_8bits <= temp_sum8bits;
			carry_out_8bits <= temp_carry_out8bits;
		end if;
	end process;
end architecture adder_8bits; 
-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        END                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘

-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                              Subtrator Completo(8-)                               │
-- └───────────────────────────────────────────────────────────────────────────────────┘
 library IEEE;
 use IEEE.std_logic_1164.all;
 use ieee.numeric_std.all;
 
 entity subtrator is 
 port (
 	clk_sub8bits: std_logic;
 	data1_sub8bits, data2_sub8bits: std_logic_vector(7 downto 0);
 	carry_out_sub: std_logic;
 	sub_8bits: std_logic_vector(7 downto 0);
 );
 end subtrator; 
 
 	signal carry_vector_sub : std_logic_vector(8 downto 0);
	signal temp_carry_outsub8bits: std_logic;
	signal temp_sub8bits : std_logic_vector(7 downto 0);
 
 architecture sub of subtrator is 
 begin
 	for i in 0 to 7 generate
 			entity work.full_adder port map(
 			data1 => data1_sub8bits(i),
 			data2 => (NOT data2_sub8bits(i)) + 1,
 			carry_in => carry_vector_sub(i),
 			sum => sum_8bits(i),
 			carry_out => carry_vector(i+1)
 			);
 		end generate;
 	carry_out_8bits <= 1;

	process(clk_adder8bits)
	
	begin 
	if rising_edge(clk_adder8bits) then
			sub_8bits <= temp_sub8bits;
			carry_out_8bits <= temp_carry_outsub8bits;
		end if;
	end process;

 end architecture sub;
 
--						    _   ___ __  __   ___ ___ _____  __
--						   /_\ | _ \  \/  | | _ \_ _/ _ \ \/ /
--						  / _ \|   / |\/| | |  _/| | (_) >  < 
--						 /_/ \_\_|_\_|  |_| |_| |___\___/_/\_\
--						
-- Testbench for Fulladder in VHDL by Kayky;

library ieee;
use ieee.std_logic_1164.all;

entity testbench is
-- empty
end testbench;

architecture testbench_adder of testbench is

-- DUT component
component full_adder is 
port(
	x: std_logic;
	y: std_logic;
	c_in: std_logic;
	s: out std_logic;
	c_out: out std_logic);
end component;

signal x_in, y_in, c_in_in, s_out, c_out: std_logic;

begin 

	DUT: full_adder port map(x_in, y_in, c_in, s_out, c_out);
	
	process
	begin
		x_in <= '0';
		y_in <= '0';
		c_in <= '0';
		wait for 1 ns;
		assert(s_out = '0') report "Erro: Resultado inesperado" severity error;
		assert(c_out = '0') report"Erro: Resultado inesperado" severity error;
	
		x_in <= '0';
		y_in <= '0';
		c_in <= '1';
		wait for 1 ns;
		assert(s_out = '1') report "Erro: Resultado inesperado" severity error;
		assert(c_out = '0') report"Erro: Resultado inesperado" severity error;
			
		x_in <= '0';
		y_in <= '1';
		c_in <= '0';
		wait for 1 ns;
		assert(s_out = '1') report "Erro: Resultado inesperado" severity error;
		assert(c_out = '0') report"Erro: Resultado inesperado" severity error;
		
		x_in <= '0';
		y_in <= '1';
		c_in <= '1'; 
		wait for 1 ns;
		assert(s_out = '0') report "Erro: Resultado inesperado" severity error;
		assert(c_out = '1') report"Erro: Resultado inesperado" severity error;
		
		x_in <= '0';
		y_in <= '0';
		wait for 1 ns;
		assert(s_out = '0') report "Erro: Resultado inesperado" severity error;
		assert(c_out = '1') report"Erro: Resultado inesperado" severity error;

		wait;
	end process;
end testbench_adder;		
		

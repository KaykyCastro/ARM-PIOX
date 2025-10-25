library ieee;
use ieee.std_logic_1164.all;

entity testbench is
-- empty
end testbench;

architecture testbench_ula of testbench is

-- DUT component
component ULA is 
port(
	clk_ula: in std_logic;
	operation_select_ula: in std_logic_vector(7 downto 0);
	data1_ula: in std_logic_vector(7 downto 0);
	data2_ula: in std_logic_vector(7 downto 0);
    output_ula: out std_logic_vector(7 downto 0)
);
end component;

signal clk_in, carry_in: std_logic;
signal operation_in, data1_in, data2_in, output: std_logic_vector(7 downto 0);

begin 

  DUT: ULA port map(clk_in, operation_in ,data1_in, data2_in, output);
	
	process
	begin
        
        operation_in <= "00000001";
        data1_in <= "00000001";
        data2_in <= "00000011";
        clk_in <= '1';
		wait for 2 ns;
        clk_in <= '0';
        wait for 1 ns;
        clk_in <= '1';
        wait for 1 ns;

       	report "Resultado da Soma (1+1) em Binario: " & output'image severity NOTE;
     		assert(output = "00000100") report "Erro: Resultado inesperado" severity error;

      
       operation_in <= "00000010";
        data1_in <= "00000001";
        data2_in <= "00000001";
        clk_in <= '1';
		wait for 2 ns;
        clk_in <= '0';
        wait for 1 ns;
        clk_in <= '1';
        wait for 1 ns;

       	report "Resultado da Sub (1-1) em Binario: " & output'image severity NOTE;
     		assert(output = "00000000") report "Erro: Resultado inesperado" severity error;

        operation_in <= "00000110";
        data1_in <= "00000001";
        data2_in <= "00000010";
        clk_in <= '1';
		wait for 2 ns;
        clk_in <= '0';
        wait for 1 ns;
        clk_in <= '1';
        wait for 1 ns;

       	report "Resultado da AND em Binario: " & output'image severity NOTE;
     		assert(output = "00000000") report "Erro: Resultado inesperado" severity error;

operation_in <= "00000111";
        data1_in <= "00000001";
        data2_in <= "00000011";
        clk_in <= '1';
		wait for 2 ns;
        clk_in <= '0';
        wait for 1 ns;
        clk_in <= '1';
        wait for 1 ns;

       	report "Resultado da OR em Binario: " & output'image severity NOTE;
     		assert(output = "00000011") report "Erro: Resultado inesperado" severity error;

        operation_in <= "00001000";
        data1_in <= "00000001";
        data2_in <= "10000011";
        clk_in <= '1';
		wait for 2 ns;
        clk_in <= '0';
        wait for 1 ns;
        clk_in <= '1';
        wait for 1 ns;

       	report "Resultado da XOR em Binario: " & output'image severity NOTE;
     		assert(output = "10000010") report "Erro: Resultado inesperado" severity error;

        operation_in <= "00001001";
        data1_in <= "10000001";
        clk_in <= '1';
		wait for 2 ns;
        clk_in <= '0';
        wait for 1 ns;
        clk_in <= '1';
        wait for 1 ns;

       	report "Resultado da NOT em Binario: " & output'image severity NOTE;
     		assert(output = "01111110") report "Erro: Resultado inesperado" severity error;

		wait;
end process;
end testbench_ULA;
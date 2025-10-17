library ieee;
use ieee.std_logic_1164.all;

--Entity ULA

entity ULA is
port(
		clk: in std_logic;
		operation_select_ula: in std_logic_vector(7 downto 0);
		data1_ula: in std_logic_vector(7 downto 0);
		data2_ula: in std_logic_vector(7 downto 0);
		addrs: in std_logic_vector(7 downto 0);
    output_ula: out std_logic_vector(7 downto 0));
end ULA;

architecture operations of ULA is
	signal operation_select_ula_signal, data1_ula_signal, data2_ula_signal, addrs_signal: std_logic_vector(7 downto 0);	
begin

		process(clk)
		operation_select_ula_signal <= operation_select_ula;
		data1_ula_signal <= data1_ula;
		data2_ula_signal <= data2_ula;
		addrs_signal <= addrs_signal;

		full_adder_inst: entity work.full_adder8bits port map(
				data1_8bits => data1_ula_signal;
				data2_8bits => data1_ula_signal;
				output_ula => sum_8bits;
				);

		begin

		if rising_edge(clk) then 

    with operation_select_ula select 
				
        output_ula <= sum_8bits when "00000001",
                 "11111111" when others;
		end if;
end operations;

--END ULA

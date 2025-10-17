library ieee;
use ieee.std_logic_1164.all;

entity testbanch_ula is 
end testbanch_ula;

architecture signal_tb of testbanch_ula is

component ULA is
port(
    operation_select_ula: in std_logic_vector(7 downto 0);
    data1_ula: in std_logic_vector(7 downto 0);
	data2_ula: in std_logic_vector(7 downto 0);
    output_ula: out std_logic_vector(7 downto 0)
    );
end component;

signal operation_select_ula_signal, data1_ula_signal, data2_ula_signal: std_logic_vector(7 downto 0);
    
begin

   DUT: ULA port map(operation_select_ula_signal, data1_ula_signal, data2_ula_signal);

    process
    begin
        
        input_tb <= "00000000";
        wait for 1 ns;
        assert(output_tb = "0000") report "Erro" severity error;
        
        input_tb <= "00000001";
        wait for 1 ns;
        assert(output_tb = "0000") report "Erro" severity error;
        
        wait;
    end process;
end architecture; 
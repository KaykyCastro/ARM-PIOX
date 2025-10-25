library ieee;
use ieee.std_logic_1164.all;

--Entity Controller--

entity controller is
port(
    operation_select : in std_logic_vector(7 downto 0);
    data1_controller : in std_logic_vector(7 downto 0);
    data2_controller: in std_logic_vector(7 downto 0);
    output_controller: out std_logic_vector(7 downto 0)
);
end controller;

architecture control_operations of cotroller is

    signal operation_select_ula_signal, data1_controller_signal, data2_controller_signal: std_logic_vector(7 downto 0);

    process(operation_select_ula_signal, data1_controller_signal, data2_controller_signal)
        begin
            if (operation_select = "00000000") then 
                operation_select_ula => operation_select;
                data1_ula => data1_controller;
            end if;
end control_operations;       
--END Controller

--ULA entity

entity ULA is
port(
		operation_select_ula: in std_logic_vector(7 downto 0);
		data1_ula: in std_logic_vector(7 downto 0);
		data2_ula: in std_logic_vector(7 downto 0);
    output_ula: out std_logic_vector(7 downto 0));
end ULA;

architecture operations of ULA is
begin
    with operation_select_ula select 
        output_ula <= "00000000" when "00000000",
                 "00000001" when "00000001",
                 "11111111" when others;
end operations;
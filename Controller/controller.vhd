library IEEE;
use IEEE.std_logic_1164.all;

entity 	controller is 
port (
	clk: in std_logic;
	operation_select_controller: in std_logic_vector(7 downto 0);
	data1_controller: in std_logic_vector(7 downto 0);
	datat2_controller: in std_logic_vector(7 downto 0);
	out_controller: out std_logic_vector(7 downto 0;
)
end controller;

architecture controller_operations of controller is 
begin 
		with operation_select_controller select
			

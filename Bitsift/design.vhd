LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity bit_shift is 
port(
    operation_s: in std_logic_vector(7 downto 0);
    data_s: in std_logic_vector(7 downto 0);
    output_s: out std_logic_vector(7 downto 0)
);
end entity bit_shift;

architecture shift_op of bit_shift is
begin

process(operation_s, data_s)
begin
    case operation_s is
        when "00000000" =>
         output_s <= data_s;
        when "00000001" =>
         output_s <= '0' & data_s()
end process
end architecture shift_op;

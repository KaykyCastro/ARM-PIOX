LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity testbench is
end testbench;

architecture tb of testbench is

component reg is
port ( 
    clk_reg : IN STD_LOGIC;
    rst_reg : IN STD_LOGIC;
    cs_reg : IN STD_LOGIC;
    we_reg : IN STD_LOGIC;
    addrs_fixed_data: IN STD_LOGIC;
    addrs_reg : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    R0_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --Registrador 1 Fixo para dados
    R1_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --Registrador 2 Fixo para dados
    R2_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --Registrador Fixo para armazenamento
    R3_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --Registrador Geral
    R0_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --Registrador 1 Fixo para dados
    R1_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --Registrador 2 Fixo para dados
    R2_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --Registrador Fixo para armazenamento
    R3_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) --Registrador Geral
         );
end component; 

signal clk_in, rst_in, cs_in, we_in, addrs_fixed_in : STD_LOGIC;

signal addrs_in, data_reg_in, R0_in, R1_in, R2_in, R3_in, R0_out, R1_out, R2_out, R3_out: std_logic_vector(7 downto 0); 

begin 

    DUT: reg port map(clk_in, rst_in, cs_in, we_in, addrs_fixed_in, addrs_in, R0_in, R1_in, R2_in, R3_in, R0_out, R1_out, R2_out, R3_out);

    process
    begin 

    clk_in <= '1';
    wait for 1 ns;
    clk_in <= '0';
    wait for 1 ns;
    cs_in <= '1';
    addrs_in <= "00000000";
    R0_in <= "00000001";
    we_in <= '1';
    clk_in <= '1';
    wait for 1 ns;
    clk_in <= '0';
    wait for 1 ns;
    cs_in <= '1';
    addrs_in <= "00000001";
    R1_in <= "11111111";
    we_in <= '1';
    clk_in <= '1';
    wait for 1 ns;
     clk_in <= '0';
    wait for 1 ns;
    cs_in <= '1';
    we_in <= '0';
    addrs_fixed_in <= '1';
    clk_in <= '1';
    wait for 1 ns;
    report "Dado 1" & R0_out'image severity NOTE;
    report "Dado 2" & R1_out'image severity NOTE;
    wait;
end process;
end architecture tb;
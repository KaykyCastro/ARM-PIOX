library IEEE;
use IEEE.std_logic_all_1164;

entity reg is
port(
		clk : in std_logic;
		we : in std_logic;
		cs : in std_logic;
		rst: in std_logic;
		data: inout std_logic_vector(7 downto 0);
		addrs: in std_logic;
		reg0: inout std_logic_vector(7 downto 0);
		reg1: inout std_logic_vector(7 downto 0);
		reg2: inout std_logic_vector(7 downto 0);
		reg3: inout std_logic_vector(7 downto 0);
		);
end entity reg;

architecture reg_operations of reg is

	type reg_array is array(0 to 3) of std_logic_vector(7 downto 0); --Estou criando um vetor de 4 posições com 8 espaços de memória
	signal regs: reg_array := (others => (others => '0')); -- Estou criando um sinal que vai enviar 0 para todas as posições do registrador, definindo um estado inicial, mas só quando eu chama-lo;
	
	begin
	process(clock)
	begin 
		if rising_edge(clk) then
			if rst = '1' then
				regs <= (others => (others => '0'));
			elsif we = '1' then'
				regs(addrs) <= data;
			elsif we = '0' then
				data <= regs(eddrs);
			else (others => 'Z');
				end if
			end if
	end process;
		
	

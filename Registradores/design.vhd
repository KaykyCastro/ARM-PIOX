library IEEE;
use IEEE.std_logic_all_1164;

entity reg is
port(
		clk_reg : in std_logic;
		we_reg : in std_logic;
		cs_reg : in std_logic;
		rst_reg: in std_logic;
		data_reg: inout std_logic_vector(7 downto 0);
		addrs: in std_logic;
		R0: inout std_logic_vector(7 downto 0); --Registrador 1 Fixo para dados
		R1: inout std_logic_vector(7 downto 0); --Registrador 2 Fixo para dados
		R2: inout std_logic_vector(7 downto 0); --Registrador Fixo para armazenamento
		R3: inout std_logic_vector(7 downto 0); --Registrador Geral
		);
end entity reg;

architecture reg_operations of reg is

	type reg_array is array(0 to 3) of std_logic_vector(7 downto 0); --Estou criando um vetor de 4 posições com 8 espaços de memória
	signal regs: reg_array := (others => (others => '0')); -- Estou criando um sinal que vai enviar 0 para todas as posições do registrador, definindo um estado inicial, mas só quando eu chama-lo;
	
	begin

	process(clock)

	begin 
		if rising_edge(clk_reg) then
			if rst_reg = '1' then
				regs <= (others => (others => '0'));
			elsif we_reg = '1' then'
				regs(addrs) <= data_reg;
			elsif we_reg = '0' then
				data_reg <= regs(eddrs);
			else (others => 'Z');
				end if;
			end if;
	end process;

end architecture reg_operations;
	

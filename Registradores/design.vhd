LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY reg IS
  PORT (
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
END ENTITY reg;

ARCHITECTURE reg_operations OF reg IS

  TYPE reg_array IS ARRAY(0 TO 3) OF STD_LOGIC_VECTOR(7 DOWNTO 0); --Estou criando um vetor de 4 posições com 8 espaços de memória
  SIGNAL regs : reg_array := (OTHERS => (OTHERS => '0'));
  -- Estou criando um sinal que vai enviar 0 para todas as posições do registrador, definindo um estado inicial, mas só quando eu chama-lo;

BEGIN
 
  PROCESS (clk_reg)

  BEGIN
    IF rising_edge(clk_reg) THEN
      
          report "We" & we_reg'image severity NOTE;
  
      IF rst_reg = '1' THEN
        regs <= (OTHERS => (OTHERS => '0'));

      
      ELSIF cs_reg = '1' AND we_reg = '1' AND addrs_fixed_data = '1' THEN
        regs(2) <= R2_in;

      ELSIF cs_reg = '1' AND we_reg = '1' AND addrs_reg = "00000000" THEN
        regs(0) <= R0_in;
      ELSIF cs_reg = '1' AND we_reg = '1' AND addrs_reg = "00000001" THEN
        regs(1) <= R1_in;
      ELSIF cs_reg = '1' AND we_reg = '1' AND addrs_reg = "00000010" THEN
        regs(2) <= R2_in;
      ELSIF cs_reg = '1' AND we_reg = '1' AND addrs_reg = "00000011" THEN
        regs(3) <= R3_in;


      ELSIF cs_reg = '1' AND we_reg = '0' AND addrs_fixed_data = '1' THEN
        R0_out <= regs(0);
        R1_out <= regs(1);
        
      ELSIF cs_reg = '1' AND we_reg = '0' AND addrs_reg = "00000000" THEN
        R0_out <= regs(0);
      ELSIF cs_reg = '1' AND we_reg = '0' AND addrs_reg = "00000001" THEN
        R1_out <= regs(1);
      ELSIF cs_reg = '1' AND we_reg = '0' AND addrs_reg = "00000010" THEN
        R2_out <= regs(2);
      ELSIF cs_reg = '1' AND we_reg = '0' AND addrs_reg = "00000011" THEN
        R3_out <= regs(3);

      END IF;
    END IF;

  END PROCESS;

END ARCHITECTURE reg_operations;
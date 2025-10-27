 LIBRARY ieee;
 USE ieee.std_logic_1164.ALL;
 
 ENTITY Processor IS
   PORT (
     clk_p : IN STD_LOGIC;
     rst_p : IN STD_LOGIC;
     instruction : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
     addrs_p : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
     data_to_reg_p : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
     data_out_p : out STD_LOGIC_VECTOR(7 DOWNTO 0);
   );
 END ENTITY Processor;
 
 ARCHITECTURE structural OF Processor IS
 
   SIGNAL opcode_ula_p, R0_data1, R1_data2,R2_data3, R3_data4, addrs_to_write_in_reg, data_to_write_in_reg, result_ula_to_save_memory : STD_LOGIC_VECTOR(7 DOWNTO  0);
   SIGNAL cs_p, we_p: STD_LOGIC;
   
 
 BEGIN

   addrs_to_write_in_reg <= "00000010" WHEN (opcode_ula_p /= "00000000") ELSE addrs_p;

   data_to_write_in_reg <= result_ula_to_save_memory WHEN (opcode_ula_p /= "00000000") ELSE data_to_reg_p;

   REGS_inst : ENTITY work.reg PORT MAP(
     clk_reg => clk_p,
     rst_reg => rst_p,
     cs_reg => cs_p,
     we_reg => we_p,
     addrs_reg => addrs_to_write_in_reg,
     data_reg => data_to_write_in_reg,
     R0_out => R0_data1,
     R1_out => R1_data2,
     R2_out => R2_data3,
     R3_out => R3_data4
     );

   UC_inst : ENTITY work.UC PORT MAP(
     rst_uc => rst_p,
     opcode_in => instruction,
     cs_uc => cs_p,
     we_uc => we_p,
     opcode_ula => opcode_ula_p
     );
 
   ULA_inst : ENTITY work.ULA PORT MAP(
     operation_select_ula => opcode_ula_p,
     data1_ula => R0_data1,
     data2_ula => R1_data2,
     output_ula => result_ula_to_save_memory
     );

     data_out_p <= 
        R0_data1 WHEN addrs_p(7 DOWNTO 0) = "00000000" ELSE -- Lê R0 (endereço 0)
        R1_data2 WHEN addrs_p(7 DOWNTO 0) = "00000001" ELSE -- Lê R1 (endereço 1)
        R2_data3  WHEN addrs_p(7 DOWNTO 0) = "00000010" ELSE -- Lê R2 (endereço 2)
        R3_data4 WHEN addrs_p(7 DOWNTO 0) = "00000011" ELSE -- Lê R3 (endereço 3)
        (OTHERS => '0');
 
 END ARCHITECTURE structural;

-- Banco de registradores
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY reg IS
  PORT (
    clk_reg : IN STD_LOGIC;
    rst_reg : IN STD_LOGIC;
    cs_reg : IN STD_LOGIC;
    we_reg : IN STD_LOGIC;
    addrs_reg : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data_reg: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
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

  R0_out <= regs(0);
  R1_out <= regs(1);
  R2_out <= regs(2);
  R3_out <= regs(3);
 
  PROCESS (clk_reg)

  BEGIN
    IF rising_edge(clk_reg) THEN
      
  
      IF rst_reg = '1' THEN
        regs <= (OTHERS => (OTHERS => '0'));

      ELSIF cs_reg = '1' AND we_reg = '1' AND addrs_reg = "00000000" THEN
        regs(0) <= data_reg;
      ELSIF cs_reg = '1' AND we_reg = '1' AND addrs_reg = "00000001" THEN
        regs(1) <= data_reg;
      ELSIF cs_reg = '1' AND we_reg = '1' AND addrs_reg = "00000010" THEN
        regs(2) <= data_reg;
      ELSIF cs_reg = '1' AND we_reg = '1' AND addrs_reg = "00000011" THEN
        regs(3) <= data_reg;

      END IF;
    END IF;


  END PROCESS;

END ARCHITECTURE reg_operations;
-- Fim banco de registradores	

-- UC
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY UC IS
  PORT (
    rst_uc : IN STD_LOGIC;
    cs_uc : OUT STD_LOGIC;
    we_uc : OUT STD_LOGIC;
    opcode_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    opcode_ula : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
  );
END UC;

ARCHITECTURE uc_op OF UC IS

BEGIN
  PROCESS (opcode_in)

  BEGIN

    cs_uc <= '0';
    we_uc <= '0';
    opcode_ula <= (OTHERS => '0');

    CASE opcode_in IS
      WHEN "00000000" =>
        cs_uc <= '1';
        we_uc <= '1';
      WHEN "00000001" =>
        cs_uc <= '1';
        we_uc <= '1';
        opcode_ula <= "00000001";
      WHEN "00000010" =>
        cs_uc <= '1';
        we_uc <= '1';
        opcode_ula <= "00000010";
      WHEN "00000011" =>
        cs_uc <= '1';
        we_uc <= '1';
        opcode_ula <= "00000011";
      WHEN "00000100" =>
        cs_uc <= '1';
        we_uc <= '1';
        opcode_ula <= "00000100";
      WHEN "00000101" =>
        cs_uc <= '1';
        we_uc <= '1';
        opcode_ula <= "00000101";
      WHEN "00000110" => --Aqui
        cs_uc <= '1';
        we_uc <= '1';
        opcode_ula <= "00000110";
      WHEN "00000111" =>
        cs_uc <= '1';
        we_uc <= '1';
        opcode_ula <= "00000111";
      WHEN "00001000" =>
        cs_uc <= '1';
        we_uc <= '1';
        opcode_ula <= "00001000";
      WHEN "00001001" =>
        cs_uc <= '1';
        we_uc <= '1';
        opcode_ula <= "00001001";
      WHEN OTHERS =>
        cs_uc <= '0';
        we_uc <= '0';
        opcode_ula <= (OTHERS => '0');
    END CASE;

  END PROCESS;
END ARCHITECTURE uc_op;
-- Fim da UC

-- ULA
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ULA IS
  PORT (
    operation_select_ula : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data1_ula : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data2_ula : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    output_ula : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END ULA;

ARCHITECTURE ula_op OF ULA IS
  SIGNAL output_signal_add : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL output_signal_sub : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL output_signal_and : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL output_signal_or : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL output_signal_xor : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL output_signal_not : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
  full_adder_inst : ENTITY work.full_adder8bits PORT MAP(
    data1_8bits => data1_ula,
    data2_8bits => data2_ula,
    sum_8bits => output_signal_add
    );

  full_sub_inst : ENTITY work.subtrator PORT MAP(
    data1_sub_8bits => data1_ula,
    data2_sub_8bits => data2_ula,
    sub_8bits => output_signal_sub
    );

  and_inst : ENTITY work.and_logic PORT MAP(
    data1_and => data1_ula,
    data2_and => data2_ula,
    output_and => output_signal_and
    );

  or_inst : ENTITY work.or_logic PORT MAP(
    data1_or => data1_ula,
    data2_or => data2_ula,
    output_or => output_signal_or
    );

  xor_inst : ENTITY work.xor_logic PORT MAP(
    data1_xor => data1_ula,
    data2_xor => data2_ula,
    output_xor => output_signal_xor
    );

  not_inst : ENTITY work.not_logic PORT MAP(
    data1_not => data1_ula,
    output_not => output_signal_not
    );
   

process(operation_select_ula, data1_ula, data2_ula)
begin  

report "Data 1: " & data1_ula'image severity NOTE;
report "Data 2: " & data2_ula'image severity NOTE;
   
WITH operation_select_ula SELECT
        output_ula <= output_signal_add WHEN "00000001", -- ADD
                      output_signal_sub WHEN "00000010", -- SUB
                      "00000011"        WHEN "00000011",
                      "00000100"        WHEN "00000100",
                      "00000101"        WHEN "00000101",
                      output_signal_and WHEN "00000110", -- AND
                      output_signal_or  WHEN "00000111", -- OR
                      output_signal_xor WHEN "00001000", -- XOR
                      output_signal_not WHEN "00001001", -- NOT
                      (OTHERS => '1')   WHEN OTHERS;    -- Default (FFh)
end process;
END ARCHITECTURE ula_op;

--END ULA

-- Somador Bit a bit
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY full_adder IS
  PORT (
    data1, data2, carry_in : IN STD_LOGIC;
    carry_out : OUT STD_LOGIC;
    sum : OUT STD_LOGIC);
END full_adder;

ARCHITECTURE adder OF full_adder IS
BEGIN
  sum <= data1 XOR data2 XOR carry_in;
  carry_out <= (data1 AND data2) OR (data1 AND carry_in) OR (data2 AND carry_in);
END ARCHITECTURE adder;
-- Fim somador bit a bit

--Somador 8 bits

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY full_adder8bits IS
  PORT (
    data1_8bits, data2_8bits : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    carry_out_8bits : OUT STD_LOGIC;
    sum_8bits : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END full_adder8bits;

ARCHITECTURE adder_8bits OF full_adder8bits IS

  SIGNAL carry_vector : STD_LOGIC_VECTOR(8 DOWNTO 0);

BEGIN

  carry_vector(0) <= '0';

  G_RIPPLE_ADD :
  FOR i IN 0 TO 7 GENERATE
    FA_i : ENTITY work.full_adder
      PORT MAP(
        data1 => data1_8bits(i),
        data2 => data2_8bits(i),
        carry_in => carry_vector(i),
        sum => sum_8bits(i),
        carry_out => carry_vector(i + 1)
      );
  END GENERATE G_RIPPLE_ADD;

  carry_out_8bits <= carry_vector(8);

END ARCHITECTURE adder_8bits;
--Fim somador 8 bits

--Subtrator 8 bits
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY subtrator IS
  PORT (
    data1_sub_8bits, data2_sub_8bits : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    carry_out_sub_8bits : OUT STD_LOGIC;
    sub_8bits : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END subtrator;

ARCHITECTURE sub_8bits OF subtrator IS

  SIGNAL carry_vector_sub : STD_LOGIC_VECTOR(8 DOWNTO 0);

BEGIN

  carry_vector_sub(0) <= '1';

  G_RIPPLE_SUB :
  FOR i IN 0 TO 7 GENERATE
    FA_i : ENTITY work.full_adder
      PORT MAP(
        data1 => data1_sub_8bits(i),
        data2 => (NOT data2_sub_8bits(i)),
        carry_in => carry_vector_sub(i),
        sum => sub_8bits(i),
        carry_out => carry_vector_sub(i + 1)
      );
  END GENERATE G_RIPPLE_SUB;

  carry_out_sub_8bits <= carry_vector_sub(8);

END ARCHITECTURE sub_8bits;

-- Fim subtrator
-- AND
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY and_logic IS
  PORT (
    data1_and, data2_and : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    output_and : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END and_logic;

ARCHITECTURE and_op OF and_logic IS
BEGIN

  output_and <= data1_and AND data2_and;

END ARCHITECTURE and_op;
--Fim da AND

-- OR
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY or_logic IS
  PORT (
    data1_or, data2_or : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    output_or : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END or_logic;

ARCHITECTURE or_op OF or_logic IS
BEGIN

  output_or <= data1_or OR data2_or;

END ARCHITECTURE or_op;
--Fim da OR

-- XOR
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY xor_logic IS
  PORT (
    data1_xor, data2_xor : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    output_xor : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END xor_logic;

ARCHITECTURE xor_op OF xor_logic IS
BEGIN

  output_xor <= data1_xor XOR data2_xor;

END ARCHITECTURE xor_op;
-- Fim XOR

-- NOT
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY not_logic IS
  PORT (
    data1_not : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    output_not : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END not_logic;

ARCHITECTURE not_op OF not_logic IS
BEGIN

  output_not <= (NOT data1_not);

END ARCHITECTURE not_op;
--FIM NOT
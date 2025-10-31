--┌───────────────────────────────────────────────────────────────────────────────────┐
--│                                    Processador                                    │
--└───────────────────────────────────────────────────────────────────────────────────┘

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Processor IS
  PORT (
    clk_p : IN STD_LOGIC;
    rst_p : IN STD_LOGIC;
    instruction : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    addrs_p : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data_to_reg_p : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data_out_p : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
  );
END ENTITY Processor;

ARCHITECTURE structural OF Processor IS

  SIGNAL opcode_ula_p, opcode_ula_shift_p, R0_data1, R1_data2, R2_data3, R3_data4, addrs_to_write_in_reg, data_to_write_in_reg, result_ula_to_save_memory : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL cs_p, we_p : STD_LOGIC;

  SIGNAL halt_flag : STD_LOGIC := '0';
  SIGNAL overflow_flag : STD_LOGIC := '0';
  SIGNAL we_gated_p : STD_LOGIC;

BEGIN

  p_halt_logic : PROCESS (clk_p, rst_p)
  BEGIN
   
    IF rst_p = '1' THEN
      halt_flag <= '0';
    ELSIF rising_edge(clk_p) THEN
      IF instruction = "00001111" THEN
        halt_flag <= '1';
      END IF;
    END IF;
  END PROCESS p_halt_logic;

  we_gated_p <= we_p AND (NOT halt_flag) AND (NOT overflow_flag);
  addrs_to_write_in_reg <=
    addrs_p WHEN instruction = "00000000" ELSE
    "00000001" WHEN instruction = "00010000" ELSE
    "00000010";
  
  data_to_write_in_reg <=
    data_to_reg_p WHEN instruction = "00000000" ELSE 
    R2_data3 WHEN instruction = "00010000" ELSE 
    result_ula_to_save_memory; 
  REGS_inst : ENTITY work.reg PORT MAP(
    clk_reg => clk_p,
    rst_reg => rst_p,
    cs_reg => cs_p,
    we_reg => we_gated_p,
    addrs_reg => addrs_to_write_in_reg,
    data_reg => data_to_write_in_reg,
    R0_out => R0_data1,
    R1_out => R1_data2,
    R2_out => R2_data3,
    R3_out => R3_data4
    );

  UC_inst : ENTITY work.UC PORT MAP(
    rst_uc => rst_p,
    opcode_shift_ula_uc => opcode_ula_shift_p,
    opcode_in => instruction,
    cs_uc => cs_p,
    we_uc => we_p,
    opcode_ula => opcode_ula_p
    );

  ULA_inst : ENTITY work.ULA PORT MAP(
    opcode_shift_ula => opcode_ula_shift_p,
    operation_select_ula => opcode_ula_p,
    data1_ula => R0_data1,
    data2_ula => R1_data2,
    output_ula => result_ula_to_save_memory,
    overflow_ula => overflow_flag
    );

  data_out_p <=
    R0_data1 WHEN addrs_p(7 DOWNTO 0) = "00000000" ELSE 
    R1_data2 WHEN addrs_p(7 DOWNTO 0) = "00000001" ELSE 
    R2_data3 WHEN addrs_p(7 DOWNTO 0) = "00000010" ELSE 
    R3_data4 WHEN addrs_p(7 DOWNTO 0) = "00000011" ELSE 
    (OTHERS => '0');

END ARCHITECTURE structural;
-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        END                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘

-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                   Registradores                                   │
-- └───────────────────────────────────────────────────────────────────────────────────┘
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
    data_reg : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    R0_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --Registrador 1 Fixo para dados
    R1_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --Registrador 2 Fixo para dados
    R2_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --Registrador Fixo para armazenamento
    R3_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- Registrador flag 0
  );
END ENTITY reg;

ARCHITECTURE reg_operations OF reg IS

  TYPE reg_array IS ARRAY(0 TO 3) OF STD_LOGIC_VECTOR(7 DOWNTO 0); 
  SIGNAL regs : reg_array := (OTHERS => (OTHERS => '0'));


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

        REPORT "DADO 1: " & R0_out'image severity NOTE;
        REPORT "DADOS 2: " & R1_out'image severity NOTE;
  END PROCESS;

END ARCHITECTURE reg_operations;
-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        END                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘

-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        UC                                         │
-- └───────────────────────────────────────────────────────────────────────────────────┘
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY UC IS
  PORT (
    rst_uc : IN STD_LOGIC;
    cs_uc : OUT STD_LOGIC;
    we_uc : OUT STD_LOGIC;
    opcode_shift_ula_uc : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    opcode_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    opcode_ula : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
  );
END ENTITY UC;

ARCHITECTURE uc_op OF UC IS

BEGIN
  PROCESS (opcode_in, rst_uc)

  BEGIN

    IF rst_uc = '1' THEN
      cs_uc <= '0';
      we_uc <= '0';
      opcode_ula <= (OTHERS => '0');
      opcode_shift_ula_uc <= (OTHERS => '0');
    ELSE

      cs_uc <= '0';
      we_uc <= '0';
      opcode_ula <= (OTHERS => '0');
      opcode_shift_ula_uc <= (OTHERS => '0');

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
        WHEN "00000110" =>
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
        WHEN "00001011" =>
          cs_uc <= '1';
          we_uc <= '1';
          opcode_shift_ula_uc <= "00000010";
          opcode_ula <= "00001011";
        WHEN "00001100" =>
          cs_uc <= '1';
          we_uc <= '1';
          opcode_shift_ula_uc <= "00000001";
          opcode_ula <= "00001100";
        WHEN "00010000" => 
          cs_uc <= '1';
          we_uc <= '1';
          opcode_ula <= (OTHERS => '0');
        WHEN OTHERS =>
          cs_uc <= '0';
          we_uc <= '0';
          opcode_ula <= (OTHERS => '0');
      END CASE;
    END IF;
  END PROCESS;
END ARCHITECTURE uc_op;
-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        END                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘

-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        ULA                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY ULA IS
  PORT (
    opcode_shift_ula : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    operation_select_ula : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data1_ula : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data2_ula : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    output_ula : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    overflow_ula : OUT STD_LOGIC;
  );
END ULA;

ARCHITECTURE ula_op OF ULA IS
  SIGNAL overflow_mult_signal : STD_LOGIC;
  SIGNAL overflow_add_signal : STD_LOGIC;
  SIGNAL overflow_sub_signal : STD_LOGIC;

  SIGNAL output_signal_add : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL output_signal_sub : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL output_signal_comp : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL output_signal_noshift : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL output_signal_shift_left : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL output_signal_shift_right : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL output_signal_mult : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL output_signal_div : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL output_signal_mod : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL output_signal_and : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL output_signal_or : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL output_signal_xor : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL output_signal_not : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
  full_adder_inst : ENTITY work.full_adder8bits PORT MAP(
    data1_8bits => data1_ula,
    data2_8bits => data2_ula,
    sum_8bits => output_signal_add,
    overflow_add => overflow_add_signal
    );

  full_sub_inst : ENTITY work.subtrator PORT MAP(
    data1_sub_8bits => data1_ula,
    data2_sub_8bits => data2_ula,
    sub_8bits => output_signal_sub,
    overflow_sub => overflow_sub_signal
    );

  comp_inst : ENTITY work.comp PORT MAP(
    data1_comp => data1_ula,
    data2_comp => data2_ula,
    data1_eq_data2 => output_signal_comp
    );

  bitshift_inst : ENTITY work.bit_shift PORT MAP(
    operation_s => opcode_shift_ula,
    data_s => data1_ula,
    output_nosh_s => output_signal_noshift,
    output_shl_s => output_signal_shift_left,
    output_shr_s => output_signal_shift_right
    );

  mul_inst : ENTITY work.mult PORT MAP(
    data1_mult => data1_ula,
    data2_mult => data2_ula,
    output_mult => output_signal_mult,
    overflow_mult => overflow_mult_signal
    );

  div_inst : ENTITY work.div_2 PORT MAP(
    data1_div2 => data1_ula,
    data2_div2 => data2_ula,
    output_div2 => output_signal_div
    );

  mod_inst : ENTITY work.mod_8bits PORT MAP(
    data1_mod => data1_ula,
    data2_mod => data2_ula,
    output_mod => output_signal_mod
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

  PROCESS (ALL)
  BEGIN

    WITH operation_select_ula SELECT
      output_ula <= output_signal_add WHEN "00000001", -- ADD
      output_signal_sub WHEN "00000010", -- SUB
      output_signal_mult WHEN "00000011", -- MULT
      output_signal_div WHEN "00000100", -- DIV
      output_signal_mod WHEN "00000101", -- MOD
      output_signal_and WHEN "00000110", -- AND
      output_signal_or WHEN "00000111", -- OR
      output_signal_xor WHEN "00001000", -- XOR
      output_signal_not WHEN "00001001", -- NOT
      output_signal_comp WHEN "00001010", -- COMP
      output_signal_shift_left WHEN "00001011", -- SHL
      output_signal_shift_right WHEN "00001100", -- SHR
      (OTHERS => '1') WHEN OTHERS; -- Default (FFh)

    WITH operation_select_ula SELECT
      overflow_ula <= overflow_add_signal WHEN "00000001",
      overflow_sub_signal WHEN "00000010",
      overflow_mult_signal WHEN "00000011",
      '0' WHEN OTHERS;

  END PROCESS;
END ARCHITECTURE ula_op;
-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        END                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘

-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                 Somador Bit a Bit                                 │
-- └───────────────────────────────────────────────────────────────────────────────────┘
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
-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        END                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘

-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                   Somador 8Bits                                   │
-- └───────────────────────────────────────────────────────────────────────────────────┘
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY full_adder8bits IS
  PORT (
    data1_8bits, data2_8bits : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    carry_out_8bits : OUT STD_LOGIC;
    sum_8bits : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    overflow_add : OUT STD_LOGIC
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

  overflow_add <= carry_vector(8);

END ARCHITECTURE adder_8bits;
-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        END                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘

-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                  Subtrator 8Bits                                  │
-- └───────────────────────────────────────────────────────────────────────────────────┘
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY subtrator IS
  PORT (
    data1_sub_8bits, data2_sub_8bits : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    carry_out_sub_8bits : OUT STD_LOGIC;
    sub_8bits : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    overflow_sub : OUT STD_LOGIC
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
  overflow_sub <= carry_vector_sub(8);

END ARCHITECTURE sub_8bits;
-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        END                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘

-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        Mod                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY mod_8bits IS
  PORT (
    data1_mod : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data2_mod : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    output_mod : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END ENTITY mod_8bits;

ARCHITECTURE mod_op OF mod_8bits IS
BEGIN

  PROCESS (data1_mod, data2_mod)
    VARIABLE data1_mod_unsigned, data2_mod_unsigned : unsigned(7 DOWNTO 0);
  BEGIN
    data1_mod_unsigned := unsigned(data1_mod);
    data2_mod_unsigned := unsigned(data2_mod);

    IF data2_mod_unsigned = 0 THEN
      output_mod <= (OTHERS => '1');
    ELSE
      output_mod <= STD_LOGIC_VECTOR(data1_mod_unsigned MOD data2_mod_unsigned);
    END IF;
  END PROCESS;
END ARCHITECTURE mod_op;
-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        END                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘

-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                    Bitshifter                                     │
-- └───────────────────────────────────────────────────────────────────────────────────┘
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY bit_shift IS
  PORT (
    operation_s : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data_s : IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
    output_nosh_s : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    output_shl_s : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    output_shr_s : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END ENTITY bit_shift;

ARCHITECTURE shift_op OF bit_shift IS
BEGIN

  PROCESS (operation_s, data_s)
  BEGIN

    output_nosh_s <= (OTHERS => '0');
    output_shl_s <= (OTHERS => '0');
    output_shr_s <= (OTHERS => '0');

    CASE operation_s IS
      WHEN "00000000" =>
        output_nosh_s <= data_s;
      WHEN "00000001" =>
        output_shr_s <= '0' & data_s(7 DOWNTO 1); -- SHR
      WHEN "00000010" =>
        output_shl_s <= data_s(6 DOWNTO 0) & '0'; -- SHL
        -- WHEN "00000011" =>
        --   output_s <= data_s(0) & data_s(7 DOWNTO 1);
        -- WHEN "00000100" =>
        --   output_s <= data_s(6 DOWNTO 0) & data_s(7);
        -- WHEN "00000101" =>
        --   output_s <= data_s(7) & data_s(7 DOWNTO 1);
        -- WHEN "00000110" =>
        --   output_s <= data_s(3 DOWNTO 0) & data_s(7 DOWNTO 4);
        -- WHEN "00000111" =>
        --   output_s <= data_s;
      WHEN OTHERS =>
        NULL;
    END CASE;

  END PROCESS;

END ARCHITECTURE shift_op;
-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        END                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘

-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                    Comparador                                     │
-- └───────────────────────────────────────────────────────────────────────────────────┘
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY comp IS
  PORT (
    data1_comp : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data2_comp : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data1_eq_data2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END ENTITY comp;

ARCHITECTURE rtl OF comp IS

  COMPONENT subtrator IS
    PORT (
      data1_sub_8bits : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      data2_sub_8bits : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      carry_out_sub_8bits : OUT STD_LOGIC;
      sub_8bits : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
      overflow_sub : OUT STD_LOGIC
    );
  END COMPONENT;

  SIGNAL s_sub_result : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL s_carry_out : STD_LOGIC;
  SIGNAL s_overflow : STD_LOGIC;

BEGIN
  sub_inst : subtrator
  PORT MAP(
    data1_sub_8bits => data1_comp,
    data2_sub_8bits => data2_comp,
    sub_8bits => s_sub_result,
    carry_out_sub_8bits => s_carry_out,
    overflow_sub => s_overflow
  );

  data1_eq_data2 <= "00000001" WHEN s_sub_result = "00000000" ELSE
    "00000000";

END ARCHITECTURE rtl;
-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        END                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘

-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                 Função Logaritmo                                  │
-- └───────────────────────────────────────────────────────────────────────────────────┘
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE utilitarios_log IS

 
  FUNCTION log2_inteiro (vetor_in : STD_LOGIC_VECTOR) RETURN INTEGER;

END PACKAGE utilitarios_log;

-- #############################################################

PACKAGE BODY utilitarios_log IS

  FUNCTION log2_inteiro (vetor_in : STD_LOGIC_VECTOR) RETURN INTEGER IS
    CONSTANT W : INTEGER := vetor_in'LENGTH;
    VARIABLE resultado : INTEGER;
  BEGIN
    
    IF vetor_in(W - 1) = '1' THEN
      resultado := W - 1;
    ELSIF W > 1 AND vetor_in(W - 2) = '1' THEN
      resultado := W - 2;
    ELSIF W > 2 AND vetor_in(W - 3) = '1' THEN
      resultado := W - 3;
    ELSIF W > 3 AND vetor_in(W - 4) = '1' THEN
      resultado := W - 4;
    ELSIF W > 4 AND vetor_in(W - 5) = '1' THEN
      resultado := W - 5;
    ELSIF W > 5 AND vetor_in(W - 6) = '1' THEN
      resultado := W - 6;
    ELSIF W > 6 AND vetor_in(W - 7) = '1' THEN
      resultado := W - 7;
    ELSIF W > 7 AND vetor_in(W - 8) = '1' THEN
      resultado := W - 8;
      
    ELSE
      resultado := 0;
    END IF;

    RETURN resultado;
  END FUNCTION log2_inteiro;

END PACKAGE BODY utilitarios_log;
-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        END                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘

-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                   Multiplicação                                   │
-- └───────────────────────────────────────────────────────────────────────────────────┘
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE WORK.utilitarios_log.ALL;

ENTITY mult IS
  PORT (
    data1_mult : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data2_mult : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    output_mult : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    overflow_mult : OUT STD_LOGIC
  );
END ENTITY mult;

ARCHITECTURE mult_op OF mult IS
BEGIN

  PROCESS (data1_mult, data2_mult)
    VARIABLE mult_var : unsigned(15 DOWNTO 0);
    VARIABLE a_16bit : unsigned(15 DOWNTO 0);
  BEGIN
    a_16bit := resize(unsigned(data1_mult), 16);
    mult_var := (OTHERS => '0');

    FOR i IN 0 TO 7 LOOP
      IF data2_mult(i) = '1' THEN
        mult_var := mult_var + shift_left(a_16bit, i);
      END IF;
    END LOOP;

    output_mult <= STD_LOGIC_VECTOR(mult_var(7 DOWNTO 0));

    IF mult_var(15 DOWNTO 8) = ("00000000") THEN
      overflow_mult <= '0';
    ELSE
      overflow_mult <= '1';
    END IF;

  END PROCESS;

END ARCHITECTURE mult_op;

-- Fim da mult

-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                      Divisão                                      │
-- └───────────────────────────────────────────────────────────────────────────────────┘
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE WORK.utilitarios_log.ALL;

ENTITY div_2 IS
  PORT (
    data1_div2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data2_div2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    output_div2 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
  );
END ENTITY div_2;

ARCHITECTURE div2_op OF div_2 IS
BEGIN
  
  PROCESS (data1_div2, data2_div2)
    VARIABLE num_shift_var : INTEGER RANGE 0 TO 7;
    VARIABLE data2_verify_0_var : unsigned(7 DOWNTO 0);
  BEGIN
    data2_verify_0_var := unsigned(data2_div2);
    num_shift_var := log2_inteiro(data2_div2);

    IF data2_verify_0_var = to_unsigned(0, 8) THEN
      output_div2 <= (OTHERS => '1');
    ELSE
      output_div2 <= STD_LOGIC_VECTOR(SHIFT_RIGHT(SIGNED(data1_div2), num_shift_var));
    END IF;
  END PROCESS;
END ARCHITECTURE div2_op;
-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        END                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘

-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                     And Logic                                     │
-- └───────────────────────────────────────────────────────────────────────────────────┘
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
-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        END                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘

-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                     Or Logic                                      │
-- └───────────────────────────────────────────────────────────────────────────────────┘
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
-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        END                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘

-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                     Xor Logic                                     │
-- └───────────────────────────────────────────────────────────────────────────────────┘
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
-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        END                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘

-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                     Not Logic                                     │
-- └───────────────────────────────────────────────────────────────────────────────────┘
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
-- ┌───────────────────────────────────────────────────────────────────────────────────┐
-- │                                        END                                        │
-- └───────────────────────────────────────────────────────────────────────────────────┘
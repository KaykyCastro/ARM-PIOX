LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;

ENTITY tb_Processor IS
END ENTITY tb_Processor;

ARCHITECTURE behavior OF tb_Processor IS

    -- Declaração da Unidade Sob Teste (UUT)
    COMPONENT Processor
    PORT (
      clk_p : IN STD_LOGIC;
      rst_p : IN STD_LOGIC;
      instruction : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      addrs_p : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      data_to_reg_p : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      data_out_p : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
    END COMPONENT;

    -- Sinais
    SIGNAL clk_s : STD_LOGIC := '0';
    SIGNAL rst_s : STD_LOGIC := '1'; -- Começa em reset
    SIGNAL instruction_s : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL addrs_p_s : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL data_to_reg_p_s : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL data_out_p_s : STD_LOGIC_VECTOR(7 DOWNTO 0);

    -- Constantes para controle e Opcodes
    CONSTANT CLK_PERIOD : TIME := 10 ns;

    -- Opcodes (baseados na sua UC):
    CONSTANT OP_MOV : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000"; -- Instrução de Escrita (usa MUX Externo)
    CONSTANT OP_ADD : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000001"; -- ADD R0, R1 -> R2
    CONSTANT OP_SUB : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000010"; -- SUB R0, R1 -> R2
    CONSTANT OP_AND : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000110"; -- AND R0, R1 -> R2
    CONSTANT OP_NOT : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00001001"; -- NOT R0 -> R2
    
    -- Novo: Opcode NOP (assumindo que 11111111 ou 00000000 desliga cs/we)
    CONSTANT OP_NOP : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => 'X'); 

    -- Endereços dos Registradores (apenas os 2 LSBs são usados pelo reg)
    CONSTANT R0_ADDR : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    CONSTANT R1_ADDR : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000001";
    CONSTANT R2_ADDR : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000010"; -- Destino padrão para ULA

BEGIN

    -- Instanciação da Unidade Sob Teste (UUT)
    UUT : Processor
    PORT MAP (
      clk_p       => clk_s,
      rst_p       => rst_s,
      instruction => instruction_s,
      addrs_p     => addrs_p_s,
      data_to_reg_p => data_to_reg_p_s,
      data_out_p  => data_out_p_s
    );

    -- Geração do Clock
    CLK_PROCESS : PROCESS
    BEGIN
      LOOP
        clk_s <= '0';
        WAIT FOR CLK_PERIOD / 2;
        clk_s <= '1';
        WAIT FOR CLK_PERIOD / 2;
      END LOOP;
    END PROCESS CLK_PROCESS;

    -- Geração do Estímulo
    STIMULUS_PROCESS : PROCESS
    BEGIN
        REPORT "--- Início da Simulação do Processador ---" SEVERITY NOTE;

        -------------------------------------------
        -- 1. FASE DE RESET
        -------------------------------------------
        rst_s <= '1';
        WAIT FOR CLK_PERIOD * 2;
        rst_s <= '0';
        WAIT FOR CLK_PERIOD * 1;

        REPORT "--- 2. Testando MOV/LOAD (Escrita de Dados) ---" SEVERITY NOTE;

        -- 2.1. MOV R0, 10 (0Ah)
        instruction_s   <= OP_MOV;
        addrs_p_s       <= R0_ADDR;
        data_to_reg_p_s <= "00001010"; -- Decimal 10 (0Ah)
        WAIT FOR CLK_PERIOD * 1; -- Executa a escrita no flanco de subida

        -- 2.2. MOV R1, 05 (05h)
        instruction_s   <= OP_MOV;
        addrs_p_s       <= R1_ADDR;
        data_to_reg_p_s <= "00000101"; -- Decimal 5 (05h)
        WAIT FOR CLK_PERIOD * 1; -- Executa a escrita

        -- 2.3. Lendo o conteúdo de R1 (SEM sobrescrever o dado!)
        -- Envia uma instrução NOP para DESATIVAR cs/we.
        instruction_s   <= OP_NOP;
        addrs_p_s       <= R1_ADDR;  -- Endereço de leitura R1
        data_to_reg_p_s <= (OTHERS => '0'); -- Irrelevante (mas setado para boa prática)
        
        REPORT "Dado do R1 (Leitura): " & data_out_p_s'image severity NOTE;
        WAIT FOR CLK_PERIOD / 2; -- Verifica a leitura (assíncrona)
        ASSERT (data_out_p_s = X"05") REPORT "Erro na Leitura de R1: R1 deveria conter 05h, mas contém " & data_out_p_s'image SEVERITY FAILURE;
        WAIT FOR CLK_PERIOD / 2;


        REPORT "--- 3. Testando Operações da ULA (Resultado em R2) ---" SEVERITY NOTE;

        -- 3.1. ADD R0 + R1 -> R2 (10 + 5 = 15 = 0Fh)
        instruction_s <= OP_ADD;
        -- addrs_p_s e data_to_reg_p_s são ignorados, mas devem ser mantidos.
        -- Como a instrução ADD usa o valor de R0 e R1, eles devem estar intactos.
        WAIT FOR CLK_PERIOD * 1; -- Executa ADD

        -- Verificar R2 (muda o endereço de leitura para R2)
        instruction_s   <= OP_NOP; -- Desativa a escrita novamente
        addrs_p_s       <= R2_ADDR;  
        WAIT FOR CLK_PERIOD / 2;
        ASSERT (data_out_p_s = X"0F") REPORT "Erro: ADD (10+5 != 15). Resultado lido: " & data_out_p_s'image SEVERITY FAILURE;
        WAIT FOR CLK_PERIOD / 2;
        
        -- Garante que R0 e R1 permanecem inalterados (opcional, mas bom debug)
        addrs_p_s       <= R0_ADDR;
        WAIT FOR 1 ns;
        ASSERT (data_out_p_s = X"0A") REPORT "Erro: R0 foi alterado após ADD." SEVERITY FAILURE;
        addrs_p_s       <= R1_ADDR;
        WAIT FOR 1 ns;
        ASSERT (data_out_p_s = X"05") REPORT "Erro: R1 foi alterado após ADD." SEVERITY FAILURE;


        -- 3.2. SUB R0 - R1 -> R2 (10 - 5 = 5 = 05h)
        instruction_s <= OP_SUB;
        WAIT FOR CLK_PERIOD * 1; -- Executa SUB

        -- Verificar R2
        instruction_s   <= OP_NOP;
        addrs_p_s       <= R2_ADDR;  
        WAIT FOR CLK_PERIOD / 2;
        ASSERT (data_out_p_s = X"05") REPORT "Erro: SUB (10-5 != 5). Resultado lido: " & data_out_p_s'image SEVERITY FAILURE;
        WAIT FOR CLK_PERIOD / 2;


        -- 3.3. AND R0 & R1 -> R2 (10 & 5 = 00001010 & 00000101 = 00000000 = 00h)
        instruction_s <= OP_AND;
        WAIT FOR CLK_PERIOD * 1; -- Executa AND

        -- Verificar R2
        instruction_s   <= OP_NOP;
        addrs_p_s       <= R2_ADDR;  
        WAIT FOR CLK_PERIOD / 2;
        ASSERT (data_out_p_s = X"00") REPORT "Erro: AND (10&5 != 0). Resultado lido: " & data_out_p_s'image SEVERITY FAILURE;
        WAIT FOR CLK_PERIOD / 2;

        -- 3.4. NOT R0 -> R2 (NOT 10 = NOT 0A = F5h)
        instruction_s <= OP_NOT;
        WAIT FOR CLK_PERIOD * 1; -- Executa NOT

        -- Verificar R2
        instruction_s   <= OP_NOP;
        addrs_p_s       <= R2_ADDR;  
        WAIT FOR CLK_PERIOD / 2;
        ASSERT (data_out_p_s = X"F5") REPORT "Erro: NOT (NOT 0A != F5). Resultado lido: " & data_out_p_s'image SEVERITY FAILURE;
        WAIT FOR CLK_PERIOD / 2;


        REPORT "--- Simulacao Concluida. Todos os testes basicos PASSARAM. ---" SEVERITY NOTE;
        
        -- Finaliza a simulação
        WAIT; 
    END PROCESS STIMULUS_PROCESS;

END ARCHITECTURE behavior;
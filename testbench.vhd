LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;

ENTITY Processor_tb IS
END ENTITY Processor_tb;

ARCHITECTURE test OF Processor_tb IS

    -- 1. Componente (Processador)
    COMPONENT Processor IS
      PORT (
        clk_p : IN STD_LOGIC;
        rst_p : IN STD_LOGIC;
        instruction : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        addrs_p : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        data_to_reg_p : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        data_out_p : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    END COMPONENT Processor;

    -- 2. "Fila de Execução" (A Memória de Programa)
    --    Primeiro, definimos o que é uma "linha de programa"
    TYPE t_program_step IS RECORD
        inst : STD_LOGIC_VECTOR(7 DOWNTO 0);
        addr : STD_LOGIC_VECTOR(7 DOWNTO 0);
        data : STD_LOGIC_VECTOR(7 DOWNTO 0);
    END RECORD;
    
    --    Agora, criamos a memória (a "fila")
    TYPE t_program_memory IS ARRAY (0 TO 255) OF t_program_step;
    
    --    Instanciamos a memória como um sinal
    SIGNAL program_memory : t_program_memory := (OTHERS => (x"0F", x"00", x"00")); -- Preenche com HALT

    -- 3. Constantes
    CONSTANT OP_HALT : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"0F";
    CONSTANT OP_NOP  : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"FF";
    CONSTANT ADDR_R1 : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"01";
    CONSTANT ADDR_R2 : STD_LOGIC_VECTOR(7 DOWNTO 0) := x"02";
    CONSTANT C_CLK_PERIOD  : TIME := 10 ns;

    -- 4. Sinais de Teste (fios)
    SIGNAL s_clk           : STD_LOGIC := '0';
    SIGNAL s_rst_p         : STD_LOGIC := '0';
    SIGNAL s_instruction   : STD_LOGIC_VECTOR(7 DOWNTO 0) := OP_NOP;
    SIGNAL s_addrs_p       : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL s_data_to_reg_p : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL s_data_out_p    : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL s_halt_flag     : STD_LOGIC := '0'; -- Trava para parar o clock

BEGIN

    -- 5. Instanciação do DUT
    UUT : Processor
      PORT MAP(
        clk_p         => s_clk,
        rst_p         => s_rst_p,
        instruction   => s_instruction,
        addrs_p       => s_addrs_p,
        data_to_reg_p => s_data_to_reg_p,
        data_out_p    => s_data_out_p
      );

    -- 6. Gerador de Clock
    clock_gen : PROCESS
    BEGIN
        LOOP
            s_clk <= '0';
            WAIT FOR C_CLK_PERIOD / 2;
            s_clk <= '1';
            WAIT FOR C_CLK_PERIOD / 2;
            EXIT WHEN s_halt_flag = '1'; -- Para o clock quando o HALT for detectado
        END LOOP;
        WAIT;
    END PROCESS clock_gen;

    -- 7. Processo 1: Leitor de Arquivo (Carrega a "fila")
    load_memory_proc : PROCESS
        FILE f : text OPEN read_mode IS "program.txt";
        VARIABLE f_line : line;
        VARIABLE f_inst, f_addr, f_data : bit_vector(7 DOWNTO 0);
        VARIABLE i : INTEGER := 0;
    BEGIN
        REPORT "Carregando 'program.txt' na memoria do testbench...";
        
        WHILE NOT endfile(f) LOOP
            readline(f, f_line);
            
            -- Pula linhas vazias ou comentários (que começam com ';')
            IF f_line'length = 0 OR f_line(f_line'left) = ';' THEN
                NEXT;
            END IF;
            
            read(f_line, f_inst);
            read(f_line, f_addr);
            read(f_line, f_data);
            
            program_memory(i) <= (
                inst => to_stdlogicvector(f_inst),
                addr => to_stdlogicvector(f_addr),
                data => to_stdlogicvector(f_data)
            );
            i := i + 1;
        END LOOP;
        
        file_close(f);
        REPORT "Carregamento concluido. " & integer'image(i) & " linhas lidas.";
        WAIT; -- Este processo roda apenas uma vez e "morre".
    END PROCESS load_memory_proc;

    -- 8. Processo 2: O "Leitor" (Program Counter)
    cpu_cycle_proc : PROCESS(s_clk, s_rst_p)
        VARIABLE pc : INTEGER range 0 to 255 := 0; -- Nosso Program Counter
    BEGIN
        IF s_rst_p = '1' THEN
            pc := 0;
            s_instruction <= OP_NOP; -- Envia NOP durante o reset
            s_addrs_p     <= (OTHERS => '0');
            s_data_to_reg_p <= (OTHERS => '0');
            s_halt_flag   <= '0';
            
        ELSIF rising_edge(s_clk) THEN
            -- FETCH: Busca a linha do programa da nossa memória
            s_instruction   <= program_memory(pc).inst;
            s_addrs_p       <= program_memory(pc).addr;
            s_data_to_reg_p <= program_memory(pc).data;

            -- EXECUTE: O processador executa a instrução
            
            -- INCREMENT: Avança o PC, a menos que seja HALT
            IF s_instruction /= OP_HALT THEN
                pc := pc + 1;
            ELSE
                REPORT "Instrucao HALT detectada. Parando o PC.";
                s_halt_flag <= '1'; -- Trava o clock
            END IF;
        END IF;
    END PROCESS cpu_cycle_proc;
    
    -- 9. Processo 3: Verificador (Opcional, mas útil)
    checker_proc : PROCESS
    BEGIN
        -- Espera o reset terminar
        WAIT UNTIL s_rst_p = '0';
        -- Espera o HALT
        WAIT UNTIL s_halt_flag = '1';
        
        -- Após o HALT, esperamos um ciclo para a última escrita
        WAIT FOR C_CLK_PERIOD; 
        
        REPORT "Verificacao final apos HALT:";
        
        -- Verifica o resultado do programa (R2 deve ser 25, R1 deve ser 25)
        s_addrs_p <= ADDR_R2; -- Pede para ler R2
        WAIT FOR C_CLK_PERIOD / 4; -- Espera combinacional
        ASSERT s_data_out_p = std_logic_vector(to_unsigned(25, 8))
            REPORT "FALHA: R2 deveria ser 25, mas e " & integer'image(to_integer(unsigned(s_data_out_p)))
            SEVERITY ERROR;
            
        s_addrs_p <= ADDR_R1; -- Pede para ler R1
        WAIT FOR C_CLK_PERIOD / 4; -- Espera combinacional
        ASSERT s_data_out_p = std_logic_vector(to_unsigned(25, 8))
            REPORT "FALHA: R1 (do MOV R1,R2) deveria ser 25, mas e " & integer'image(to_integer(unsigned(s_data_out_p)))
            SEVERITY ERROR;
            
        REPORT "Verificacao final BEM SUCEDIDA.";
        WAIT;
    END PROCESS checker_proc;

END ARCHITECTURE test;
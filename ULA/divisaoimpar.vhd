-- Divisão
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; -- << BIBLIOTECA NECESSÁRIA

entity div is 
port (
    clk_div: IN STD_LOGIC;
    rst_div: IN STD_LOGIC;
    select_op_div: IN STD_LOGIC; -- '0' = Par (Rápido), '1' = Impar (Lento)
    start_init_impar_dev: IN STD_LOGIC; -- << Renomeado para start_init_div
    reg_flag0_div: OUT STD_LOGIC;
    done_div : OUT STD_LOGIC;
    data1_div: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    data2_div: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    output_div: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    resto_div: OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
);
end entity div;

architecture div_op of div is

    -- Sinais da FSM principal (como você pediu)
    signal flag0_signal : std_logic := '0'; -- 'busy' interno
    signal done_out : std_logic := '0'; -- 'done' interno
    signal registra_selecao : std_logic := '0'; -- trava a seleção

    -- Sinais de resultado (registradores de saída)
    -- CORREÇÃO: Nomes únicos, sem duplicatas
    signal r_quociente : unsigned(7 downto 0) := (others => '0');
    signal r_resto     : unsigned(7 downto 0) := (others => '0');

    -- Sinais de conexão para o filho "impar" (Sequencial)
    signal s_impar_start_pulse : std_logic := '0';
    signal s_impar_busy        : std_logic;
    signal s_impar_done        : std_logic;
    signal s_impar_quociente   : std_logic_vector(7 downto 0);
    signal s_impar_resto       : std_logic_vector(7 downto 0);

    -- Sinais de conexão para o filho "par" (Combinatorial)
    signal s_par_quociente : std_logic_vector(7 downto 0);
    signal s_par_resto     : std_logic_vector(7 downto 0);

begin

    -- =============================================================
    -- Instanciação dos Filhos
    -- =============================================================

    -- Filho "Par" (Rápido, Combinatorial)
    DIV_par_inst: entity work.div_2 -- << A entidade que criamos
        port map (
            data1_div2  => data1_div,
            data2_div2  => data2_div,
            output_div2 => s_par_quociente,
            resto_div2  => s_par_resto
        );

    -- Filho "Impar" (Lento, Sequencial)
    -- CORREÇÃO: Mapa de portas corrigido
    DIV_impar_inst: entity work.div_impar
        port map (
            clk_impar    => clk_div,
            rst_impar    => rst_div,
            start_init_impar => s_impar_start_pulse, -- << Controlado pela FSM
            reg_flag0    => s_impar_busy,
            done_impar   => s_impar_done,
            data1_impar  => data1_div,
            data2_impar  => data2_div,
            output_impar => s_impar_quociente,
            resto_impar  => s_impar_resto
        );

    -- =============================================================
    -- CORREÇÃO: FSM (Máquina de Estados) principal que estava faltando
    -- =============================================================
    p_control_fsm : process (clk_div, rst_div)
    begin
        if rst_div = '1' then
            flag0_signal      <= '0';
            done_out          <= '0';
            s_impar_start_pulse <= '0';
            registra_selecao  <= '0';
        elsif rising_edge(clk_div) then
            
            -- Reseta pulsos
            done_out <= '0';
            s_impar_start_pulse <= '0';

            if flag0_signal = '0' then
                -- ESTADO OCIOSO
                if start_init_impar_dev = '1' then
                    flag0_signal <= '1'; -- Fica ocupado
                    registra_selecao <= select_op_div; -- Salva a escolha
                    
                    if select_op_div = '1' then
                        -- Se for "impar" (lento), manda o start
                        s_impar_start_pulse <= '1';
                    end if;
                end if;
            else
                -- ESTADO OCUPADO
                if registra_selecao = '0' then
                    -- Se a escolha foi "par" (rápido), termina em 1 ciclo
                    flag0_signal <= '0';
                    done_out     <= '1';
                else
                    -- Se a escolha foi "impar" (lento), espera o 'done' do filho
                    if s_impar_done = '1' then
                        flag0_signal <= '0';
                        done_out     <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process p_control_fsm;

    -- =============================================================
    -- Lógica de Saída (MUX para selecionar o resultado)
    -- =============================================================
    p_output_reg : process (clk_div, rst_div)
    begin
        if rst_div = '1' then
            r_quociente <= (others => '0');
            r_resto     <= (others => '0');
        elsif rising_edge(clk_div) then
            if done_out = '1' then -- << Trava o resultado no pulso 'done'
                if registra_selecao = '0' then
                    -- A escolha foi "par", salva o resultado de div_2
                    r_quociente <= unsigned(s_par_quociente);
                    r_resto     <= unsigned(s_par_resto);
                else
                    -- A escolha foi "impar", salva o resultado de div_impar
                    r_quociente <= unsigned(s_impar_quociente);
                    r_resto     <= unsigned(s_impar_resto);
                end if;
            end if;
        end if;
    end process p_output_reg;

    -- =============================================================
    -- Conexão final das saídas
    -- =============================================================
    reg_flag0_div <= flag0_signal;
    done_div      <= done_out;
    output_div    <= std_logic_vector(r_quociente);
    resto_div     <= std_logic_vector(r_resto);

end architecture div_op;
-- Fim da divisão


-- Divisão por impar
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; 
 
entity div_impar is 
port (
    clk_impar: IN STD_LOGIC;
    rst_impar: IN STD_LOGIC;
    start_init_impar: IN STD_LOGIC;
    reg_flag0 : OUT STD_LOGIC;
    done_impar: OUT STD_LOGIC;
    data1_impar: IN STD_LOGIC_VECTOR(7 downto 0);
    data2_impar: IN STD_LOGIC_VECTOR(7 downto 0);
    output_impar: OUT STD_LOGIC_VECTOR(7 downto 0);
    resto_impar: OUT STD_LOGIC_VECTOR(7 downto 0)
);
end entity div_impar;

architecture divimpar_op of div_impar is

    signal flag_0 : std_logic := '0'; -- registrador para flag 0
    signal signal_to_resto : unsigned(7 downto 0) := (others => '0'); -- Sinal para resto
    signal quociente : unsigned(7 downto 0) := (others => '0'); -- Sinal para enviar o resultado
    signal done : std_logic := '0';
    signal s_divisor_int : unsigned(7 downto 0); 

begin

    -- Converte o divisor (std_logic_vector) para unsigned UMA VEZ.
    s_divisor_int <= unsigned(data2_impar);

    process(clk_impar, rst_impar)
    begin
        
        -- Rest estado inicial
        if rst_impar = '1' then 
            flag_0          <= '0';
            signal_to_resto <= (others => '0');
            quociente       <= (others => '0');
            done            <= '0';
            
        elsif rising_edge(clk_impar) then
        
            done <= '0';
        
            if flag_0 = '0' then
                -- ESTADO OCIOSO (flag = 0)
                --- <<< CORREÇÃO 3: O nome da porta era 'start_init_impar'
                if start_init_impar = '1' then 
                    
                    --- <<< CORREÇÃO 4: Comparação correta (unsigned com unsigned)
                    if s_divisor_int /= 0 then
                        flag_0 <= '1'; 
                        signal_to_resto <= unsigned(data1_impar);
                        quociente       <= (others => '0');
                    end if;
                end if;
                
            else -- flag_0 = '1'
                -- ESTADO CALCULANDO (flag = 1)
                
                --- <<< CORREÇÃO 4: Comparação correta (unsigned com unsigned)
                if signal_to_resto >= s_divisor_int then
                    --- <<< CORREÇÃO 4: Subtração correta (unsigned com unsigned)
                    signal_to_resto <= signal_to_resto - s_divisor_int;
                    quociente       <= quociente + 1;
                else
                    flag_0 <= '0'; 
                    done   <= '1';
                end if;
            end if;
        end if;

    end process;

    reg_flag0    <= flag_0;
    done_impar   <= done;
    output_impar <= std_logic_vector(quociente);
    resto_impar  <= std_logic_vector(signal_to_resto);

end architecture divimpar_op;
-- End divisão por impar
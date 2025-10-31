#include "compilador.hpp"


map<string, uint8_t> Opcode::opcodeTable;
map<string, uint8_t> Registradores::regsTable;




// OPCODE ---------------------------------------------------------------------------------------------------------

uint8_t Opcode::getOpcode(string mnemonico) {
    try {
        auto it = opcodeTable.find(mnemonico);
        if (it != opcodeTable.end()) {
            return it->second;
        } else {
            throw invalid_argument("Opcode not found: " + mnemonico);
        }
    } catch (const exception& e) {
        cout << "Erro de execucao - " << e.what() << '\n';
        return 0;
    }
}

void Opcode::setOpcodeTable(const map<string, uint8_t>& table) {
    opcodeTable = table;
}




// REGISTRADORES ---------------------------------------------------------------------------------------------------------

uint8_t Registradores::getReg(string nomeReg) {
    try {
        auto it = regsTable.find(nomeReg);
        if (it != regsTable.end()) {
            return it->second;
        } else {
            throw invalid_argument("Register not found: " + nomeReg);
        }
    } catch (const exception& e) {
        cout << "Erro de execuçao - " << e.what() << '\n';
       
    }
}

void Registradores::setRegsTable(const map<string, uint8_t>& table) {
    regsTable = table;
}




// INSTRUCTION ---------------------------------------------------------------------------------------------------------
Instruction::Instruction(string mnemonico, vector<uint8_t>& operandos) {
    operacao = Opcode::getOpcode(mnemonico);
    this->operandos = operandos;
}

uint8_t Instruction::getOperacao() { return operacao; }

vector<uint8_t> Instruction::getOperandos() { return operandos; }

void Instruction::printInstruction() {
    cout << "Opcode: " << bitset<8>(operacao) << endl;
    cout << "Operadores: " << endl;
    for (uint8_t op : operandos) {
        cout << "Operando: " << bitset<8>(op) << endl;
    }
}




// ====== Controle ------------------------------------------------------------------------------
vector<Controle::LinhaInstrucao> Controle::readFile(string caminho) {
    vector<LinhaInstrucao> instrucoes; //vetor onde vou guardar as intruções pra retornar no final

    try {
        ifstream file(caminho);
        //se o arquivo n abrir lança um erro
        if (!file.is_open()) {
            throw runtime_error("Could not open the file: " + caminho);
        }

        string line;
        LinhaInstrucao instrAtual; //usa a struct que eu criei pra guardar o mnemonico e os operandos

        while (getline(file, line)) {
            // essas duas linhas tiram os espaçoes em branco 
            line.erase(0, line.find_first_not_of(" \t"));
            line.erase(line.find_last_not_of(" \t") + 1);

            
            if (line.empty()) continue; //se a linha for vazia pula ela
            if (line.substr(0, 2) == "//") continue; //se a linha começar com // pula ela (comentario)

            //aqui é o caso de ter um comentario no final de uma linha com instrução valida
            size_t pos = line.find("//");
            if (pos != string::npos) {
                line = line.substr(0, pos);
                line.erase(line.find_last_not_of(" \t") + 1);
            }

            //verificação pra ver se é mnemonico
            bool isMnemonic = true;
            for (char c : line) {
                //ele analisa cada caractere da linha, se achar um que não seja um char ele define que n é mnemonico
                if (!isalpha(c)) { isMnemonic = false; break; }
            }

            //caso seja mnemonico 
            if (isMnemonic) {
                if (!instrAtual.mnemonic.empty()) {
                    instrucoes.push_back(instrAtual); //salva a instrução anterior antes de começar uma nova
                    instrAtual = LinhaInstrucao(); //ai ele reseta a instrução atual pq ja foi salva
                }
                instrAtual.mnemonic = line; 
            } else {
                instrAtual.operandos.push_back(line); //no caso se não for mnemonico é porque é operando, ai salva no vetor de operandos da instrução atual
            }
        }

        if (!instrAtual.mnemonic.empty()) {
            instrucoes.push_back(instrAtual);
        }

        //depois de ler tudo fecha o arquivo
        file.close();

    } catch (const exception& e) {
        cerr << "Erro - " << e.what() << endl;
    }

    return instrucoes;
}


void Controle::makeFile(vector<uint8_t> instr) {
    //cria o arquivo de saída no formato txt
    ofstream file("output.txt");
    if (!file) {
        cerr << "Erro ao criar o arquivo de saida." << endl;
        return;
    }

    // aqui ele separa cada byte em oito bits e escreeve no txt, com um espaço entre cada byte
    for(int i=0; i < instr.size(); i++){
        file << bitset<8>(instr[i]);

        if( i < instr.size() -1){ // adiciona um espaço entre cada byte
            file << " ";
        }
        
    }
    //fecha o arquivo depois de escrever tudo
    file.close();
}

void Controle::process(string caminho) {
    try {
        vector<LinhaInstrucao> linhas = readFile(caminho); //pega o vetor de saida de readFile e salva aqui pra usar
        vector<uint8_t> instrBinario; //a instrução final que vai ser jogada no arquivo de saída

        //caso não tenha lido nenhuma instrução lança um erro
        if (linhas.empty()) {
            throw runtime_error("No instructions found in file: " + caminho);
        }

        for (auto& linha : linhas) {
            //agora ele vai ler linha por linha do vetor recebido do readFile
            vector<uint8_t> operandosByte;

            for (auto& op : linha.operandos) {
                //aqui ele faz a vetificação pra saber o que é o que
                uint8_t byte;
                if (op[0] == 'R') { //caso a linha comece com R é um registrador
                    byte = Registradores::getReg(op); //usa o método getReg pra pegar o valor do registrador em binario
                } 
                else if (regex_match(op, regex("^[01]+$"))) { // caso a linha seja só 0 e 1 é um valor imediato em binario
                    byte = static_cast<uint8_t>(stoi(op, nullptr, 2));
                } 
                else {
                    throw invalid_argument("Invalid operand: " + op); //caso não seja nenhum dos dois lança um erro
                }
                
                operandosByte.push_back(byte);//ao final ele adiciona o byte no vetor de operandos em binario
            }

            // aQUI ele cria um objeto da classe Instruction com o mnemonico e os operandos em binario
            Instruction instr(linha.mnemonic, operandosByte);

            // Adiciona o opcode ao vetor de saída usando o objeto que eu acabei de criar
            instrBinario.push_back(instr.getOperacao());

            // Adiciona os operandos ao vetor de saída
            for (uint8_t opByte : instr.getOperandos()) {
                instrBinario.push_back(opByte);
            }
        }

        // Preenchimento automático para instruções sem operandos, se necessário
        if (instrBinario.size() < 2) {
            //usa os registradores fixos pra operações matematicas como ADD, SUB, MUL, DIV, etc
            if (instrBinario[0] >= 0 && instrBinario[0] <= 8) {
                instrBinario.push_back(Registradores::getReg("R0"));
                instrBinario.push_back(Registradores::getReg("R1"));
                instrBinario.push_back(Registradores::getReg("R2"));
                //aqui é o caso do NOT que só pode ser feito com o R0
            } else if (instrBinario[0] == 9) {
                instrBinario.push_back(Registradores::getReg("R0"));
                instrBinario.push_back(Registradores::getReg("R2"));
            }
        }

        // Gera o arquivo de saída passando esse vetor de instruções em binario
        makeFile(instrBinario);
    }
    catch (const exception& e) {
        cout << "Erro - " << e.what() << endl;
    }
}



int main(){

    // Setando a tabela de opcodes
    Opcode::setOpcodeTable({
        {"MOV", 0},
        {"ADD", 1},
        {"SUB", 2},
        {"MUL", 3},
        {"DIV", 4},
        {"MOD", 5},
        {"AND", 6},
        {"OR", 7},
        {"XOR", 8},
        {"NOT", 9},
        {"CMP", 10},
        {"SHL", 11},
        {"SHR", 12},
        {"NOP", 13},
        {"HALT", 14}
    });


    //Setando a tabela de registradores
     Registradores::setRegsTable({
        {"R0", 0}, //dado1
        {"R1", 1}, //dado2
        {"R2", 2}, //resultado
        {"R3", 3},  //flag sinal
        {"R4", 4},  //flag zero
        {"R5", 5}  //flag overflow
 
    });

    Controle::process("../instrucao.txt");


}
#include "compilador.hpp"


map<string, uint8_t> Opcode::opcodeTable;
map<string, uint8_t> Registradores::regsTable;
map<uint8_t, uint8_t> Registradores::bancoRegs;

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
        cout << "Erro de execução - " << e.what() << '\n';
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
        cout << "Erro de execução - " << e.what() << '\n';
        return 0;
    }
}

void Registradores::setRegsTable(const map<string, uint8_t>& table) {
    regsTable = table;
}

// INSTRUCTION ---------------------------------------------------------------------------------------------------------
Instruction::Instruction(string mnemonico, vector<uint8_t> operandos) {
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

// ====== Controle ======
vector<Controle::LinhaInstrucao> Controle::readFile(string caminho) {
    vector<LinhaInstrucao> instrucoes;

    try {
        ifstream file(caminho);
        if (!file.is_open()) {
            throw runtime_error("Could not open the file: " + caminho);
        }

        string line;
        LinhaInstrucao instrAtual;

        while (getline(file, line)) {
            // Remove espaços extras
            line.erase(0, line.find_first_not_of(" \t"));
            line.erase(line.find_last_not_of(" \t") + 1);

            if (line.empty()) continue;
            if (line.substr(0, 2) == "//") continue;

            size_t pos = line.find("//");
            if (pos != string::npos) {
                line = line.substr(0, pos);
                line.erase(line.find_last_not_of(" \t") + 1);
            }

            bool isMnemonic = true;
            for (char c : line) {
                if (!isalpha(c)) { isMnemonic = false; break; }
            }

            if (isMnemonic) {
                if (!instrAtual.mnemonic.empty()) {
                    instrucoes.push_back(instrAtual);
                    instrAtual = LinhaInstrucao();
                }
                instrAtual.mnemonic = line;
            } else {
                instrAtual.operandos.push_back(line);
            }
        }

        if (!instrAtual.mnemonic.empty()) {
            instrucoes.push_back(instrAtual);
        }

        file.close();
    } catch (const exception& e) {
        cerr << "Erro - " << e.what() << endl;
    }

    return instrucoes;
}

void Controle::makeFile(vector<uint8_t> instr) {
    ofstream file("output.bin");
    if (!file) {
        cerr << "Erro ao criar o arquivo de saída." << endl;
        return;
    }

    for (uint8_t byte : instr) {
        file << bitset<8>(byte) << endl;
    }

    file.close();
}

void Controle::process(string caminho) {
    try {
        vector<LinhaInstrucao> linhas = readFile(caminho);
        vector<uint8_t> instrBinario;
        string mnemonic;

        if (linhas.empty()) {
            throw runtime_error("No instructions found in file: " + caminho);
        }

        for (auto& linha : linhas) {
            mnemonic = linha.mnemonic;
            uint8_t opcode = Opcode::getOpcode(mnemonic);
            instrBinario.push_back(opcode);

            cout << "Mnemonico: " << mnemonic << endl;

            for (auto& op : linha.operandos) {
                uint8_t byte;

                if (op[0] == 'R') {
                    byte = Registradores::getReg(op);
                } else {
                    byte = static_cast<uint8_t>(stoi(op, nullptr, 2));
                }

                instrBinario.push_back(byte);
                cout << "  Operando: " << op << endl;
            }

            cout << "---------------------" << endl;
        }

        if (instrBinario.size() < 2) {
            if (instrBinario[0] >= 0 && instrBinario[0] <= 8) {
                instrBinario.push_back(Registradores::getReg("R0"));
                instrBinario.push_back(Registradores::getReg("R1"));
                instrBinario.push_back(Registradores::getReg("R2"));
            } else if (instrBinario[0] == 9) {
                instrBinario.push_back(Registradores::getReg("R0"));
                instrBinario.push_back(Registradores::getReg("R2"));
            }
        }

        makeFile(instrBinario);
    } catch (const exception& e) {
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
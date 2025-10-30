#include <iostream>
#include <map>
#include <bitset>
#include <vector>
#include <fstream>
#include <sstream>


using namespace std;

class Opcode{
    static map<string, uint8_t> opcodeTable;

    public:

    static uint8_t getOpcode(string mnemonico);
    static void setOpcodeTable(const map<string, uint8_t>& table);


};

class Registradores{
    static map<string, uint8_t> regsTable;
    static map<uint8_t, uint8_t> bancoRegs;

    public:
        static uint8_t getReg(string nomeReg);
        static void setRegsTable(const map<string, uint8_t>& table);
};

class Instruction{

    uint8_t operacao;
    vector<uint8_t> operandos;

    public:
    Instruction(string mnemonico,vector<uint8_t> operandos);
    uint8_t getOperacao();
    vector<uint8_t> getOperandos();
    void printInstruction();


};

class Controle{
   
    struct LinhaInstrucao {
        string mnemonic;
        vector<string> operandos;
    };

    public:
    static vector<LinhaInstrucao> readFile(string caminho);
    static void makeFile(vector<uint8_t> instr);
    static void process(string caminho);
};
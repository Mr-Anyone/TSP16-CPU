#include <verilated.h>
#include <verilated_vcd_c.h>
#include <iostream>
#include "VArithmeticLogicUnit.h"

VerilatedContext* init(){
    Verilated::traceEverOn(true); // trace is on now
    VerilatedContext* context = new VerilatedContext();
    context->debug(0); // log level
    context->randReset(2); // 2
    context->traceEverOn(true); // must trace 
    return  context;
}

void check_rd(VArithmeticLogicUnit* dut, uint64_t expected, VerilatedContext* context){
    if(dut->rd != expected){ std::cout << "not equal at time "  << context->time() << std::endl;
        std::cout << "failed" << std::endl;
    }
}

int main(int argc, char **argv) {
    VerilatedContext* context = init();
    VArithmeticLogicUnit *dut = new VArithmeticLogicUnit(context);

    // Create the waveform for the top level module
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, /*levels=*/5);
    m_trace->open("alu-waveform.vcd");

    // Setting initial data 
    dut->instr = 0b0000000100100100;
    dut->rn = 10;
    dut->rm = 20;
    dut->eval();
    m_trace->dump(context->time());
    context->timeInc(1);
    check_rd(dut, 30, context); // does timing matter? rd + rm

    dut->instr = 0b0000001100100100;
    dut->rn = 10;
    dut->rm = 20;
    dut->eval();
    m_trace->dump(context->time());
    context->timeInc(1);

    dut->instr = 0b0000010100100100;
    dut->rn = 10;
    dut->rm = 20;
    dut->eval();
    m_trace->dump(context->time());
    context->timeInc(1);

    dut->instr = 0b0000011100100100;
    dut->rn = 10;
    dut->rm = 20;
    dut->eval();
    m_trace->dump(context->time());
    context->timeInc(1);
    
    dut->instr = 0b0000100100100100;
    dut->rn = 30;
    dut->rm = 20;
    dut->eval();
    m_trace->dump(context->time());
    context->timeInc(1);
    check_rd(dut, 30-20, context); // does timing matter? rd = rn - rm

    m_trace->close(); // save waveform file
    std::cout << "done running test!" << std::endl;

    delete dut;
    delete m_trace;
    return 0;
}

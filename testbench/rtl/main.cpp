#include <verilated.h>
#include <verilated_vcd_c.h>
#include <iostream>
#include <math.h>

#include "VTop.h"
#include "VTop___024root.h"

constexpr int MEM_SIZE = 65536; // 2^16
constexpr int MAX_SIMULATE_TIME = 10; 

VerilatedContext* init(){
    Verilated::traceEverOn(true); // trace is on now
    VerilatedContext* context = new VerilatedContext();
    context->debug(0); // log level
    context->randReset(2); // 2
    context->traceEverOn(true); // must trace 
    return  context;
}

void init_cpu(VTop* dut){
    dut->rootp->Top__DOT__fetch_pc = 0;
    dut->eval();
    // memset the entire set
    for(int i = 0;i<MEM_SIZE; ++i){
        dut->rootp->Top__DOT__memory__DOT__mem[i] = 0;
    }
} 

int main(int argc, char **argv) {
    VerilatedContext* context = init();

    // Creating the design under test 
    VTop *dut = new VTop(context);
    init_cpu(dut);

    // Create the waveform for the top level module
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, /*levels=*/5);
    m_trace->open("waveform.vcd");

    // Setting initial data 
    while(context->time() < 1000){
        dut->clk = 0;
        dut->eval();
        m_trace->dump(context->time());
        context->timeInc(1);

        dut->clk = 1;
        dut->eval();
        m_trace->dump(context->time());
        context->timeInc(1);
    }

    m_trace->close(); // save waveform file
    std::cout << "done" << std::endl;
    
    delete dut;
    delete m_trace;
    return 0;
}

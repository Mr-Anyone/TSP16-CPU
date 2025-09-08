#include <verilated.h>
#include <verilated_vcd_c.h>
#include <iostream>
#include "VTop.h"

VerilatedContext* init(){
    Verilated::traceEverOn(true); // trace is on now
    VerilatedContext* context = new VerilatedContext();
    context->debug(0); // log level
    context->randReset(2); // 2
    context->traceEverOn(true); // must trace 
    return  context;
}

int main(int argc, char **argv) {
    VerilatedContext* context = init();

    // Creating the design under test 
    VTop *dut = new VTop(context);

    // Create the waveform for the top level module
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, /*levels=*/5);
    m_trace->open("waveform.vcd");

    // Setting initial data 
    while(context->time() < 10){
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

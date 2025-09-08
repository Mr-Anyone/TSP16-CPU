#include <verilated.h>
#include <verilated_vcd_c.h>
#include <iostream>
#include "VMemory.h"

VerilatedContext* init(){
    Verilated::traceEverOn(true); // trace is on now
    VerilatedContext* context = new VerilatedContext();
    context->debug(0); // log level
    context->randReset(2); // 2
    context->traceEverOn(true); // must trace 
    return  context;
}

int main(){
    VerilatedContext* context = init();
    VMemory *dut = new VMemory(context);

    // Create the waveform for the top level module
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, /*levels=*/5);
    m_trace->open("memory-waveform.vcd");

    dut->clk = 0;
    dut->write = 1;
    dut->write_address = 0x0; 
    dut->write_input = 10;
    dut->eval(); 
    m_trace->dump(context->time());
    context->timeInc(1); 

    dut->clk = 1; 
    dut->eval(); 
    m_trace->dump(context->time());
    context->timeInc(1); 

    dut->clk = 0; 
    dut->read_address = 0x0;
    dut->eval(); 
    if(dut->read_output != 10){
        std::cout << "test has failed" << std::endl;
    }
    m_trace->dump(context->time());
    context->timeInc(1); 

    m_trace->close(); 

    delete dut; 
    delete m_trace;

    std::cout << "memory has been tested" << std::endl; 
    return 0;
}
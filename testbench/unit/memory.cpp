#include <verilated.h>
#include <verilated_vcd_c.h>
#include <cstdlib>
#include <iostream>
#include <vector>

#include "VMemory.h"

// FIXME: fix this jankness, this really should be some fixture instead of global variable

VerilatedContext* init(){
    Verilated::traceEverOn(true); // trace is on now
    VerilatedContext* context = new VerilatedContext();
    context->debug(0); // log level
    context->randReset(2); // 2
    context->traceEverOn(true); // must trace 
    return  context;
}

void write_mem(VMemory* dut, VerilatedVcdC* m_trace, VerilatedContext* context, uint16_t address, uint16_t content){
    dut->clk = 0;
    dut->write = 1;
    dut->write_address = address; 
    dut->write_input = content;
    dut->eval(); 
    m_trace->dump(context->time());
    context->timeInc(1); 

    dut->clk = 1; 
    dut->eval(); 
    m_trace->dump(context->time());
    context->timeInc(1); 
}

uint16_t read_mem(VMemory* dut, VerilatedVcdC* m_trace, VerilatedContext* context, uint16_t address){
    dut->read_address = address;
    dut->eval(); 
    uint16_t result = dut->read_output;
    m_trace->dump(context->time());
    context->timeInc(1);

    return result;
}

int main(){
    VerilatedContext* context = init();
    VMemory *dut = new VMemory(context);
    constexpr int size = 65536;

    // Create the waveform for the top level module
    VerilatedVcdC *m_trace = new VerilatedVcdC;
    dut->trace(m_trace, /*levels=*/5);
    m_trace->open("memory-waveform.vcd");
    std::vector<uint16_t> mem(size, 0);
    
    // FIXME: don't hardcode this size!
    for(int i = 0;i<size; ++i){
        uint16_t result = (uint16_t)(rand()); 
        mem[i] = result;
        write_mem(dut, m_trace, context, i, mem[i]);
        uint16_t read = read_mem(dut, m_trace, context, i);
        if(read != mem[i]){
            std::cout << "test have failed" << std::endl; 
        }
    }

    for(int i = 0;i<size; ++i){
        if(read_mem(dut, m_trace, context, i) != mem[i]){
            std::cout << "test have failed" << std::endl; 
        }
    }

    m_trace->close(); 

    delete dut; 
    delete m_trace;

    std::cout << "memory has been tested" << std::endl; 
    return 0;
}
#include <iostream>
#include <math.h>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include "VTop.h"
#include "VTop___024root.h"

constexpr int MEM_SIZE = 65536; // 2^16
constexpr int MAX_SIMULATE_TIME = 10;

VerilatedContext *init() {
  Verilated::traceEverOn(true); // trace is on now
  VerilatedContext *context = new VerilatedContext();
  context->debug(0);          // log level
  context->randReset(2);      // 2
  context->traceEverOn(true); // must trace
  return context;
}

void init_cpu(VTop *dut, VerilatedContext *context, VerilatedVcdC *m_trace) {
  for (int i = 0; i < MEM_SIZE; ++i) {
    dut->rootp->Top__DOT__memory__DOT__mem[i] = 0;
  }

  dut->rootp->Top__DOT__memory__DOT__mem[0] =  0b1000000001010001; // MOV R1, #10
  dut->rootp->Top__DOT__memory__DOT__mem[1] =  0b1000000000101010; // MOV R2, #5
  dut->rootp->Top__DOT__memory__DOT__mem[2] =  0b1000000000110011; // MOV R3, #6
  dut->rootp->Top__DOT__memory__DOT__mem[3] =  0b0000000011010001; // ADD R1, R2, R3
  dut->rootp->Top__DOT__memory__DOT__mem[4] =  0b0000000011001010; // ADD R2, R1, R3
  dut->rootp->Top__DOT__memory__DOT__mem[5] =  0b0000000010001011; // ADD R3, R1, R2
  dut->rootp->Top__DOT__memory__DOT__mem[6] =  0b1000100000000001; // MOV R1, #256
  dut->rootp->Top__DOT__memory__DOT__mem[7] =  0b1000000011110010; // MOV R2, #30
  dut->rootp->Top__DOT__memory__DOT__mem[8] =  0b0101000000001010; // STR R2, [R1]
  dut->rootp->Top__DOT__memory__DOT__mem[9] =  0b0100000000001011; // LDR R3, [R1] 
  dut->rootp->Top__DOT__memory__DOT__mem[10] = 0b0000000011011100; // ADD R4, R3, R3

  // dut->rootp
  //     ->Top__DOT__regfile__DOT____Vcellout__genblk1__BRA__1__KET____DOT__register__out =
  //     10;
  // dut->rootp
  //     ->Top__DOT__regfile__DOT____Vcellout__genblk1__BRA__2__KET____DOT__register__out =
  //     5;
  // dut->rootp
  //     ->Top__DOT__regfile__DOT____Vcellout__genblk1__BRA__3__KET____DOT__register__out =
  //     6;
  dut->eval();
  m_trace->dump(context->time());
  context->timeInc(1);

  // reset
  dut->reset = 1;
  dut->clk = 0;
  dut->eval();
  m_trace->dump(context->time());
  context->timeInc(1);

  dut->reset = 1;
  dut->clk = 1;
  dut->eval();
  m_trace->dump(context->time());
  context->timeInc(1);

  // pull reset down to 0
  dut->reset = 0;
  dut->eval();
  m_trace->dump(context->time());
  context->timeInc(1);
}

int main(int argc, char **argv) {
  VerilatedContext *context = init();

  // Creating the design under test
  VTop *dut = new VTop(context);

  // Create the waveform for the top level module
  VerilatedVcdC *m_trace = new VerilatedVcdC;
  dut->trace(m_trace, /*levels=*/5);
  m_trace->open("waveform.vcd");

  init_cpu(dut, context, m_trace);

  // Setting initial data
  while (context->time() < 1000) {
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

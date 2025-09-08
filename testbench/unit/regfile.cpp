#include "VRegfile.h"
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>

VerilatedContext *init() {
  Verilated::traceEverOn(true); // trace is on now
  VerilatedContext *context = new VerilatedContext();
  context->debug(0);          // log level
  context->randReset(2);      // 2
  context->traceEverOn(true); // must trace
  return context;
}

void check(SData &actual, uint64_t expected, VerilatedContext *context) {
  if (actual != expected) {
    std::cout << "actual does not equal to expected at time: "
              << context->time() << std::endl;
    std::cout << "test failed" << std::endl;
  }
}

int main(int argc, char **argv) {
  VerilatedContext *context = init();
  VRegfile *dut = new VRegfile(context);

  // Create the waveform for the top level module
  VerilatedVcdC *m_trace = new VerilatedVcdC;
  dut->trace(m_trace, /*levels=*/5);
  m_trace->open("regfile-waveform.vcd");

  delete dut;
  delete m_trace;
  std::cout << "done testing regfile!" << std::endl;
  return 0;
}

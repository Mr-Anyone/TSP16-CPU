#include "VRegfile.h"
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>

struct Context{
    VerilatedContext* context; 
    VRegfile* regfile;
    VerilatedVcdC* trace;
};

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

void one_write_transaction(Context context, uint16_t in, uint8_t reg_num){
    context.regfile->write = 1;
    context.regfile->write_reg_num =  reg_num;
    context.regfile->write_data = in;
    context.regfile->clk = 0;
    context.regfile->eval();
    context.trace->dump(context.context->time());

    context.context->timeInc(1);
    context.regfile->clk = 1;
    context.regfile->eval();
    context.trace->dump(context.context->time());

    context.context->timeInc(1); // so what we don't clash with other transaction
    context.regfile->write = 0;
} 

void check_data(Context context, uint16_t expected, uint8_t reg_num){
    context.regfile->read_reg_num = reg_num;
    context.regfile->eval();
    context.trace->dump(context.context->time());

    if(context.regfile->output_one != expected){
        std::cout << "did not pass test case!" << std::endl;
    }

    context.context->timeInc(1);
}

int main(int argc, char **argv) {
  VerilatedContext *context = init();
  VRegfile *dut = new VRegfile(context);

  // Create the waveform for the top level module
  VerilatedVcdC *trace = new VerilatedVcdC;
  dut->trace(trace, /*levels=*/5);
  trace->open("regfile-waveform.vcd");

  Context test_context {context, dut, trace};

  for(int i = 0;i<8; ++i){
      one_write_transaction(test_context, /*in=*/i, /*reg_num=*/i);
      check_data(test_context, /*expected=*/i, /*reg_num=*/i);
  }
  one_write_transaction(test_context, /*in=*/100, /*reg_num=*/7);


  delete dut;
  delete trace;
  std::cout << "done testing regfile!" << std::endl;
  return 0;
}

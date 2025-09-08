verilator := verilator
rtl_src := $(wildcard rtl/*.sv)
top_level_testbench  := testbench/rtl/main.cpp

all: test

obj_dir/VTop: $(rtl_src) testbench/rtl/main.cpp
	$(verilator) -cc $(rtl_src)  testbench/rtl/main.cpp  --top-module Top --trace  --exe
	make -C obj_dir -j -f VTop.mk

obj_dir/VArithmeticLogicUnit: rtl/ArithmeticLogicUnit.sv testbench/unit/alu.cpp
	$(verilator) -cc rtl/ArithmeticLogicUnit.sv  testbench/unit/alu.cpp  --trace  --exe
	make -C obj_dir -j -f VArithmeticLogicUnit.mk

obj_dir/VMemory: rtl/Memory.sv testbench/unit/memory.cpp 
	$(verilator) -cc rtl/Memory testbench/unit/memory.cpp --trace --exe
	make -C obj_dir -j -f VMemory.mk

obj_dir/VRegfile: rtl/Regfile.sv testbench/unit/regfile.cpp
	$(verilator) -cc rtl/Regfile.sv  testbench/unit/regfile.cpp  --trace  --exe -Irtl
	make -C obj_dir -j -f VRegfile.mk

.PHONY: test 
test: obj_dir/VTop obj_dir/VArithmeticLogicUnit obj_dir/VRegfile obj_dir/VMemory
	./obj_dir/VTop
	./obj_dir/VArithmeticLogicUnit
	./obj_dir/VRegfile
	./obj_dir/VMemory

.PHONY: debug
debug:
	echo $(rtl_src)

.PHONY: lint 
lint: 
	$(verilator) --lint-only -Wall $(rtl_src) --top-module Top

.PHONY: clean
clean:
	rm -r obj_dir
	rm *.vcd

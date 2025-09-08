verilator := verilator
rtl_src := $(wildcard rtl/*.sv)
top_level_testbench  := testbench/rtl/main.cpp

all: lint

obj_dir/Vtop: $(rtl_src) testbench/rtl/main.cpp
	$(verilator) -cc $(rtl_src)  testbench/rtl/main.cpp  --top-module top --trace  --exe
	make -C obj_dir -j -f Vtop.mk

obj_dir/Valu: rtl/alu.sv testbench/unit/alu.cpp
	$(verilator) -cc rtl/alu.sv  testbench/unit/alu.cpp  --trace  --exe
	make -C obj_dir -j -f Valu.mk

.PHONY: test 
test: obj_dir/Vtop obj_dir/Valu
	./obj_dir/Vtop
	./obj_dir/Valu

.PHONY: debug
debug:
	echo $(rtl_src)

.PHONY: lint 
lint: 
	$(verilator) --lint-only $(rtl_src) --top-module top

.PHONY: clean
clean:
	rm -r obj_dir
	rm *.vcd

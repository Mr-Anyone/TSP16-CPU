verilator := verilator
rtl_src := $(wildcard rtl/*.sv)
top_level_testbench  := testbench/rtl/main.cpp

all: lint

obj_dir/VTop: $(rtl_src) testbench/rtl/main.cpp
	$(verilator) -cc $(rtl_src)  testbench/rtl/main.cpp  --top-module Top --trace  --exe
	make -C obj_dir -j -f VTop.mk

obj_dir/Valu: rtl/alu.sv testbench/unit/alu.cpp
	$(verilator) -cc rtl/alu.sv  testbench/unit/alu.cpp  --trace  --exe
	make -C obj_dir -j -f Valu.mk

obj_dir/Vregfile: rtl/regfile.sv testbench/unit/regfile.cpp
	$(verilator) -cc rtl/regfile.sv  testbench/unit/regfile.cpp  --trace  --exe
	make -C obj_dir -j -f Vregfile.mk

.PHONY: test 
test: obj_dir/VTop obj_dir/Valu obj_dir/Vregfile
	./obj_dir/VTop
	./obj_dir/Valu
	./obj_dir/Vregfile

.PHONY: debug
debug:
	echo $(rtl_src)

.PHONY: lint 
lint: 
	$(verilator) --lint-only $(rtl_src) --top-module Top

.PHONY: clean
clean:
	rm -r obj_dir
	rm *.vcd

default: simulate

PYTHON ?= python3
CORNER = min
TOP = top
TOOLCHAIN_PREFIX ?= riscv32-unknown-elf-

COUNTER_HDL = \
	examples/counter/top.v \
	examples/counter/gl/counter.v

ALU_HDL = \
	examples/alu/top.v \
	examples/alu/gl/alu.v

PICORV32_HDL = \
	examples/picorv32/top.v \
	examples/picorv32/gl/picorv32.v

CELL_LIBRARY = \
	cell_library/primitives.v \
	cell_library/sky130_fd_sc_hd.v

examples/alu/alu.vvp: $(ALU_HDL) $(CELL_LIBRARY)
	iverilog -o $@ -gspecify -ginterconnect -s ${TOP} $^ -T${CORNER} -D USE_POWER_PINS

examples/alu/alu.vcd: examples/alu/alu.vvp
	vvp $^ -sdf-verbose

check_alu: examples/alu/alu.vcd
	python3 verify.py examples/alu/alu.vcd examples/alu/sdf/alu.sdf top.alu_inst ${CORNER} verbose

examples/counter/counter.vvp: $(COUNTER_HDL) $(CELL_LIBRARY)
	iverilog -o $@ -gspecify -ginterconnect -s ${TOP} $^ -T${CORNER} -D USE_POWER_PINS

examples/counter/counter.vcd: examples/counter/counter.vvp
	vvp $^ -sdf-verbose

check_counter: examples/counter/counter.vcd
	python3 verify.py examples/counter/counter.vcd examples/counter/sdf/counter.sdf top.counter_inst ${CORNER} verbose

examples/picorv32/picorv32.vvp: $(PICORV32_HDL) $(CELL_LIBRARY)
	iverilog -o $@ -gspecify -ginterconnect -s ${TOP} $^ -T${CORNER} -D USE_POWER_PINS

examples/picorv32/sw/start.o: picorv32/sw/start.S
	$(TOOLCHAIN_PREFIX)gcc -c -mabi=ilp32 -march=rv32i -o $@ $<

examples/picorv32/sw/program.elf: picorv32/sw/start.o picorv32/sw/sections.lds
	$(TOOLCHAIN_PREFIX)gcc -o $@ -Os -mabi=ilp32 -march=rv32i \
	-ffreestanding -nostartfiles -nostdlib -nodefaultlibs  \
	-Wl,-T,picorv32/sw/sections.lds \
	picorv32/sw/start.o

examples/picorv32/sw/program.bin: picorv32/sw/program.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@

examples/picorv32/sw/program.hex: picorv32/sw/program.bin
	$(PYTHON) picorv32/sw/makehex.py $< 256 > $@

examples/picorv32/picorv32.vcd: examples/picorv32/picorv32.vvp examples/picorv32/sw/program.hex
	vvp $^ #-sdf-verbose

check_picorv32: examples/picorv32/picorv32.vcd
	python3 verify.py examples/picorv32/picorv32.vcd examples/picorv32/sdf/picorv32.sdf top.picorv32_inst ${CORNER}

clean:
	cd examples/alu/; rm -f *.vvp *.vcd
	cd examples/counter/; rm -f *.vvp *.vcd
	cd examples/picorv32/; rm -f *.vvp *.vcd

.PHONY: clean check_alu check_counter check_picorv32

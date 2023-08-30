default: simulate

CORNER = min

TOP = top

COUNTER_EXAMPLE = \
	counter_example/top.v \
	counter_example/gl/counter_example.v \

ALU_EXAMPLE = \
	alu_example/top.v \
	alu_example/gl/alu_example.v \

CELL_LIBRARY = \
	cell_library/primitives.v \
	cell_library/sky130_fd_sc_hd.v

alu_example.vvp: $(ALU_EXAMPLE) $(CELL_LIBRARY)
	iverilog -o $@ -gspecify -ginterconnect -s ${TOP} $^ -T${CORNER} -D USE_POWER_PINS  # -D FUNCTIONAL

alu_example.vcd: alu_example.vvp
	vvp $^ -sdf-verbose

check_alu_example: alu_example.vcd
	python3 verify.py alu_example.vcd alu_example/sdf/alu_example.sdf top.alu_example_inst ${CORNER}

counter_example.vvp: $(COUNTER_EXAMPLE) $(CELL_LIBRARY)
	iverilog -o $@ -gspecify -ginterconnect -s ${TOP} $^ -T${CORNER} -D USE_POWER_PINS  # -D FUNCTIONAL

counter_example.vcd: counter_example.vvp
	vvp $^ -sdf-verbose

check_counter_example: counter_example.vcd
	python3 verify.py counter_example.vcd counter_example/sdf/counter_example.sdf top.counter_example_inst ${CORNER}

clean:
	rm -f *.vvp *.vcd

.PHONY: clean check_alu_example check_counter_example

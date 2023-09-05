# SDF INTERCONNECT Tests for Icarus Verilog

This repository contains tests to verify the accuracy of the SDF INTERCONNECT implementation in Icarus Verilog.

The designs were processed via OpenLane to get the gate level representation and the corresponding SDF file. The cells required for the simulation were extracted from the PDK and placed under `cell_library/`.

First, the designs are simulated and the waveforms are generated. The Python script `verify.py` reads the resulting `.vcd` waveforms. By using the `(INTERCONNECT ...)` statements from the SDF file, the interconnect signal transition delays are compared with the specified delays in the SDF file. 

1. `examples/alu`

Implements a simple combinatorial ALU that can add, subtract, bitwise-AND as well as compare two 4-bit values.

2. `examples/counter`

The second design is an 8-bit counter that can be reset asynchronously via RESET, loaded with a new value via LOAD and VALUE and counts upon a rising edge of CLK.

3. `examples/picorv32`

This example simulates a RISC-V CPU that writes `Hello World!` to a memory location which is printed by the simulator.

# Setup

You will need to install a recent version of Icarus Verilog with SDF INTERCONNECT support.

Secondly, you will need Python 3 and the `pyDigitalWaveTools` package which you can install via:

    > pip3 install pyDigitalWaveTools

# Run the Tests

The design will be simulated and the resulting waveform will be checked. You will get a simulation summary containing statistics about successfully simulated interconnection delays.

To run the test for `alu`, execute the make target:

	> make check_alu

To run the test for `counter`, execute the make target:

	> make check_counter

To run the test for `picorv32`, execute the make target:

	> make check_picorv32

And be patient ;)
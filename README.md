# SDF INTERCONNECT Tests for Icarus Verilog

This repository contains tests to verify the accuracy of the SDF INTERCONNECT function on Icarus Verilog.

Two designs were processed via OpenLane to get the gate level representation and the SDF file. The first design `alu_example` is a simple combinatorial design, the second design `counter_example` is a 8-bit counter and uses a clock.

The cells required for the simulation were extracted from the PDK and placed under `cell_library/`.

First, the designs are simulated. A Python script was written to read the resulting waveforms in the `.vcd` file. Using the `(INTERCONNECT ...)` statements from the SDF file it will verify that the signals transition according to the specified delays. 

# Setup

You will need to install a version if Icarus Verilog with SDF INTERCONNECT support (if not yet merged).

Secondly, you will need Python 3 and the `pyDigitalWaveTools` package which you can install via:

    > pip3 install pyDigitalWaveTools

# Run the Tests

The design will be simulated and the resulting waveform will be checked. You will get a simulation summary containing statistics about successfully simulated interconnection delays.

To run the test for `alu_example`, execute the make target:

	> make check_alu_example

To run the test for `counter_example`, execute the make target:

	> make check_counter_example
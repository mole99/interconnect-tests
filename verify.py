#!/usr/bin/env python3
# SPDX-License-Identifier: Apache-2.0

import json
import sys
import re
from pyDigitalWaveTools.vcd.parser import VcdParser

# This function extracts one bit from
# an array of vector values
def extract_bit(data, port_bit):
    new_data = []
    for (time, value) in data:
        # Try to access the bit directly
        try:
            bit = value[-port_bit-1]
            if bit != 'b':
                new_data.append((time, bit))
                continue
        except:
            pass

        # Else get the highest bit
        bit = value[1] 
        
        # If 1 or 0, set to 0
        if bit == '1' or bit == '0':
            bit = '0'

        new_data.append((time, bit))

    data = new_data
    
    # Remove value pairs with no changes
    new_data = []
    
    cur_val = None
    for (time, value) in data:                
        if cur_val == None:
            cur_val = value
            new_data.append((time, value))
        else:
            if cur_val != value:
                new_data.append((time, value))
                cur_val = value

    return new_data

def main():
    verbose = None

    if len(sys.argv) == 5:
        vcd_filename = sys.argv[1]
        sdf_filename = sys.argv[2]
        module_instance = sys.argv[3]
        corner = sys.argv[4]
    elif len(sys.argv) == 6:
        vcd_filename = sys.argv[1]
        sdf_filename = sys.argv[2]
        module_instance = sys.argv[3]
        corner = sys.argv[4]
        verbose = sys.argv[5]
    else:
        print('Usage: verify.py vcd_filename sdf_filename module_instance corner [verbose]')
        print('Example: verify.py out.vcd design.sdf top.mod.a typ verbose')
        sys.exit(-1)

    with open(vcd_filename) as vcd_file:
        vcd = VcdParser()
        vcd.parse(vcd_file)

    num_interconnect = 0
    num_correct = 0
    max_sim_time = vcd.now
    conversion = None
    corners = {'min': 0, 'typ': 1, 'max': 2}

    if not corner in corners:
        print('Choose corner to be min, typ or max.')

    corner_index = corners[corner]

    with open(sdf_filename) as sdf_file:
        for line in sdf_file:        
            timescale = re.findall(r'\(TIMESCALE (.*)\)', line)
            
            if timescale:
                print('SDF timescale: {}'.format(timescale[0]))
                print('VCD timescale: {}'.format(vcd.timescale))
                
                units = {'1s':1,'1ms':1e3,'1us':1e6,'1ns':1e9,'1ps':1e12}
                
                if not timescale[0] in units:
                    print('Error: Unknown time scale in SDF file')
                
                if not vcd.timescale in units:
                    print('Error: Unknown time scale in VCD file')
                
                # Get time unit of vcd and time unit of SDF, calculate conversion ratio
                conversion = int(units[vcd.timescale.replace(' ', '')] / units[timescale[0].replace(' ', '')])
                print('Conversion ratio: {}'.format(conversion))
            
            interconnect = re.findall(r'\(INTERCONNECT (.*) (.*) \((.*):(.*):(.*)\) \((.*):(.*):(.*)\)\)', line)
            
            if interconnect:
                num_interconnect += 1
                
                interconnect = interconnect[0]
                port1 = interconnect[0]
                port2 = interconnect[1]
                delay_rising = (interconnect[2], interconnect[3], interconnect[4])
                delay_falling = (interconnect[5], interconnect[6], interconnect[7])
                
                if not conversion:
                    print('Error: Could not determine units for SDF and VCD')
                
                # Choose and convert the delay
                delay_rising = int(float(delay_rising[corner_index])*conversion)
                delay_falling = int(float(delay_falling[corner_index])*conversion)
                
                # Get the scope of the instanciated module
                cur_scope = vcd.scope
                for part in module_instance.split('.'):
                    cur_scope = cur_scope.children[part]
                
                # Check if port1 is a vector
                bitindex = re.findall(r'(.*)\[(.*)\]', port1)
                port1_bit = None
                if bitindex:
                    bitindex = bitindex[0]
                    port1 = bitindex[0]
                    port1_bit = int(bitindex[1])
                
                # Get scope for port1
                port1_scope = cur_scope
                for part in port1.split('.'):
                    port1_scope = port1_scope.children[part]
                
                port1_name = port1 if port1_bit == None else port1 + f'[{port1_bit}]'
                
                # Check if port2 is a vector
                bitindex = re.findall(r'(.*)\[(.*)\]', port2)
                port2_bit = None
                if bitindex:
                    bitindex = bitindex[0]
                    port2 = bitindex[0]
                    port2_bit = int(bitindex[1])
                
                # Get scope for port2
                port2_scope = cur_scope
                for part in port2.split('.'):
                    port2_scope = port2_scope.children[part]
                
                port2_name = port2 if port2_bit == None else port2 + f'[{port2_bit}]'
                
                # Get the time, value pairs for both ports
                data1 = port1_scope.vcdId if isinstance(port1_scope.vcdId, list) else port1_scope.data
                data2 = port2_scope.vcdId if isinstance(port2_scope.vcdId, list) else port2_scope.data
                
                # If port1 is a vector, get the correct bit
                if port1_bit != None:
                    data1 = extract_bit(data1, port1_bit)

                # If port2 is a vector, get the correct bit
                if port2_bit != None:
                    data2 = extract_bit(data2, port2_bit)

                # Build up the expected data array, based on the data from port1
                # and the SDF statement for port1 -> port2
                expected_data = []
                for (time, value) in data1:
                    if time > 0:
                        # Rising edge
                        if (last_value == '0' and value == 'x' or
                            last_value == '0' and value == 'z' or
                            last_value == '0' and value == '1' or
                            last_value == 'x' and value == '1' or
                            last_value == 'z' and value == '1' ): 
                            next_time = time + delay_rising
                            if next_time <= max_sim_time:
                                expected_data.append((next_time, value))

                        # Falling edge
                        if (last_value == '1' and value == 'x' or
                        last_value == '1' and value == 'z' or
                        last_value == '1' and value == '0' or
                        last_value == 'x' and value == '0' or
                        last_value == 'z' and value == '0' ): 
                            next_time = time + delay_falling
                            if next_time <= max_sim_time:
                                expected_data.append((next_time, value))
                        
                        # No change, why is this even in the vcd data?
                        if (last_value == '0' and value == '0'): # No edge
                            #continue
                            expected_data.append((time, value))
                            
                        if (last_value == '1' and value == '1'): # No edge
                            #continue
                            expected_data.append((time, value))
                            
                    # Time = 0
                    else:
                        first_value2 = data2[0][1]

                        # Not initialized, we expect no change
                        # Init value has propagated through, we expect no change
                        if value == first_value2:
                            expected_data.append((time, value))
                        # Init value takes time to propagate
                        else:
                            expected_data.append((time, 'x'))
                            if (value == '1'): # Rising edge
                                next_time = time + delay_rising
                                if next_time <= max_sim_time:
                                    expected_data.append((next_time, value))
                            
                            if (value == '0'): # Falling edge
                                next_time = time + delay_falling
                                if next_time <= max_sim_time:
                                    expected_data.append((next_time, value))
                    last_value = value

                # Compare the time-value pairs
                correct = True
                errors = []
                
                # First check for right length
                if (len(data2) != len(expected_data)):
                    correct = False
                    errors.append('Not the same amount of time-value pairs')
                else:
                    # Now check the time, value pairs
                    for ((time, value), (exp_time, exp_value))  in zip(data2, expected_data):
                        if (time != exp_time or value != exp_value):
                            correct = False
                
                # Append debug information
                if correct == False:
                    errors.append('Port 1:')
                    
                    for (time, value)  in data1:
                        errors.append('{:<10} : {:<10}'.format(time, value))

                    errors.append('Port 2:')
                    
                    for (time, value)  in data2:
                        errors.append('{:<10} : {:<10}'.format(time, value))

                    errors.append('Expected:')

                    for (exp_time, exp_value)  in expected_data:
                        errors.append('{:<10} : {:<10}'.format(exp_time, exp_value))
                
                # All time, value pairs match!
                if correct:
                    num_correct += 1
                    if verbose:
                        print('[✅] Interconnect {:<10} -> {:<10} with trise = {} ps, tfall = {} ps'.format(port1_name, port2_name, delay_rising, delay_falling))
                # Something was wrong
                else:
                    print('[❌] Interconnect {:<10} -> {:<10} with trise = {} ps, tfall = {} ps'.format(port1_name, port2_name, delay_rising, delay_falling))
                    for error in errors:
                        print(error)

    print('\n\n')

    # Print a short summary
    print('╔═══════════════════════════════════════════╗')
    print('║           Simulation Summary              ║')
    print('╠═══════════════════════════════════════════╣')
    print('║ VCD File: {:<31} ║'.format(vcd_filename))
    print('║ SDF File: {:<31} ║'.format(sdf_filename if not '/' in sdf_filename else sdf_filename.rsplit('/', 1)[1]))
    print('║ Instance: {:<31} ║'.format(module_instance))
    print('╠═══════════════════════════════════════════╣')
    print('║  Number of Interconnects: {:<5}           ║'.format(num_interconnect))
    print('║  ✅ Number of Successes:  {:<5}           ║'.format(num_correct))
    print('║  ❌ Number of Failures:   {:<5}           ║'.format(num_interconnect-num_correct))
    print('║  Success Ratio            {:<6.2f} %        ║'.format(float(num_correct)/num_interconnect*100))
    print('╚═══════════════════════════════════════════╝')

if __name__ == "__main__":
    main()

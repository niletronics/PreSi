// =======================================================================
//   Department of Electrical and Computer Engineering
//   Portland State University
//
//   Course name:  ECE 510 - Pre-Silicon Validation
//   Term & Year:  Spring 2015
//   Instructor :  Tareque Ahmad
//
//   Project:      Hardware implementation of PDP8 
//                 Instruction Set Architecture (ISA) level simulator
//
//   Filename:     fetch_stimuli_gen.sv
//   Description:  checker for Fetch and Decode Unit for the PDP-8 (DUT).
//   Created by:   Neeti Verma
//   Date:         June 4, 2015
// =======================================================================
`include "pdp8_pkg.sv"
import pdp8_pkg::*;

module fetch_stimuli_gen
 (
	input	ifu_rd_req,
	input	[`DATA_WIDTH -1:0]	num_stimuli,
	
	output	logic	stall=0,
	output	logic	[`ADDR_WIDTH-1:0]	generated_data,
	output	logic	[`ADDR_WIDTH-1:0]	PC_value
 );
 
 parameter CYCLE_TO_LATCH_FIRST_DATA = 2;
 
 
 initial
	begin
		repeat (num_stimuli)
		begin
			@(posedge ifu_rd_req);
			generated_data = 12'o7000;
		//			int_generated_data = ({$random} % 8'hff);
			$display ("\n@ %0d ns Starting test sequence number %0d with address %h\n", $time, generated_data);
		end
	end
endmodule
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

module fetch_chkr
 (
	input	clk,
	input	[`DATA_WIDTH -1:0]	num_stimuli,
	output	[`ADDR_WIDTH-1:0]	generated_rd_addr
 );
 
 parameter CYCLE_TO_LATCH_FIRST_DATA = 2;
 reg	[`ADDR_WIDTH-1:0]	int_rd_addr;
 
 always @(negedge clk)
	begin
		for (int_num_stimuli = 0; int_num_stimuli < num_stimuli; int_num_stimuli = int_num_stimuli + 1)
			begin
				int_rd_addr = ({$random} % 8'hff);
				$display ("\n@ %0d ns Starting test sequence number %0d with address %h\n", $time,int_num_stimuli,generated_rd_addr);
			end
	end
endmodule
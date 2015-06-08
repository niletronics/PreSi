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

module fetch_stimuli_gen #(parameter num_stimuli=1)
 (
	input	ifu_rd_req,
	//input	[`DATA_WIDTH -1:0]	num_stimuli,
	
	output	bit	stall,
	output	bit	[`ADDR_WIDTH-1:0]	generated_data,
	output	bit	[`ADDR_WIDTH-1:0]	PC_value
 );
 
 parameter CYCLE_TO_LATCH_FIRST_DATA = 2;
 reg	exit_code = 1'b0;
 int	int_PC_value;
 
 
 
 initial
	begin
		repeat (num_stimuli)
		begin
			@(posedge ifu_rd_req);
			generated_data = $urandom_range(0,2**12);
			$display ("\n @%m: @%d \nGenerate Data : %o", $time, generated_data);
			
			int_PC_value++;
			if (int_PC_value == 128 && exit_code == 1'b0)
			begin
				int_PC_value = 129;
				exit_code = 1'b1;
				
			end
			else if (int_PC_value == 4096 && exit_code == 1'b1)
				int_PC_value = 128;
			else
				PC_value = int_PC_value;
		end
				$finish;
	end
endmodule
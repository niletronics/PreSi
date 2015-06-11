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
//   Filename:     exe_initiator.sv
//   Description:  Inititor For execute unit
//   Created by:   Nilesh Dattani
//   Date:         June 06, 2015
//
//   Copyright:    Tareque Ahmad
// =======================================================================


`include "pdp8_pkg.sv"
import pdp8_pkg::*;

module exe_initiator #(parameter num_stimuli=10, parameter verbose=1, parameter debug=0)
						( 
						input wire clk,
						input wire reset_n,
						output logic [`ADDR_WIDTH-1:0]base_addr,
						output pdp_mem_opcode_s pdp_mem_opcode,
						output pdp_op7_opcode_s pdp_op7_opcode,
						input stall,
						input [`ADDR_WIDTH-1:0]PC_value
						);
						
assign base_addr = `START_ADDRESS;

parameter TRUE = 1'b1;
parameter FALSE = 1'b0;

int i;



bit		[5:0]				int_mem_opcode = 6'b1;
bit 	[`DATA_WIDTH-1:0]	int_mem_opcode_addr = 9'b0;
bit 	[21:0]				int_pdp_op7_opcode = 1;
bit		[5:0]				new_int_mem_opcode;
bit 	[`DATA_WIDTH-1:0] 	new_mem_opcode_addr;
//bit [21:0]new_pdp_op7_opcode;
pdp_op7_opcode_s new_pdp_op7_opcode;



initial begin
forever begin
	@(posedge clk);
	pdp_mem_opcode = {new_int_mem_opcode,new_mem_opcode_addr};
	pdp_op7_opcode = new_pdp_op7_opcode;
end
end

initial begin
	{new_int_mem_opcode,new_mem_opcode_addr} = 0;
	new_pdp_op7_opcode=0;
	new_pdp_op7_opcode.CLA_CLL  = TRUE;	
	@(negedge stall);

 repeat (num_stimuli)	begin
			randcase
				1 : begin
				{new_pdp_op7_opcode,new_int_mem_opcode} ={22'b0,int_mem_opcode << $urandom_range(0,5)};
				new_mem_opcode_addr = $urandom_range(0,2**12);
				if(debug) begin
					$display("%m:pdp_mem_opcode=%p",pdp_mem_opcode);
					$display("%m : new_int_mem_opcode = %0b,new_mem_opcode_addr=%0o int_mem_opcode=%0b",new_int_mem_opcode, new_mem_opcode_addr,int_mem_opcode);
				end
				@(negedge stall);
				end
		
				2: begin	
				{new_int_mem_opcode, new_pdp_op7_opcode} = {6'b0,int_pdp_op7_opcode << $urandom_range(0,21)};
				if(debug) begin
				$display("%m : new_pdp_op7_opcode = %0b, int_pdp_op7_opcode=%0b",new_pdp_op7_opcode, int_pdp_op7_opcode);
				end
				@(negedge stall);
		end
		endcase
		end 
repeat(10)@(posedge clk);
$finish;
end





						
endmodule
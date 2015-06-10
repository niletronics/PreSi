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


parameter TRUE = 1'b1;
parameter FALSE = 1'b0;
bit debug;

module exe_initiator( 	input wire clk,
						input wire reset_n,
						output logic [`ADDR_WIDTH-1:0]base_addr,
						output pdp_mem_opcode_s pdp_mem_opcode,
						output pdp_op7_opcode_s pdp_op7_opcode,
						input stall,
						input [`ADDR_WIDTH-1:0]PC_value);
						
assign base_addr = `START_ADDRESS;




class stimulus;
	int opcode_number;	
task memcase;
input integer instruction;
pdp_mem_opcode = 0;
unique case(instruction)
	`AND : pdp_mem_opcode.AND = TRUE;
	`TAD : pdp_mem_opcode.TAD = TRUE;
	`ISZ : pdp_mem_opcode.ISZ = TRUE;
	`DCA : pdp_mem_opcode.DCA = TRUE;
	`JMS : pdp_mem_opcode.JMS = TRUE;
	`JMP : pdp_mem_opcode.JMP = TRUE;
endcase	
endtask

task op7case;
input [11:0] instruction;
pdp_op7_opcode = 0;
unique case(instruction)
	
	`NOP     : pdp_op7_opcode.NOP	   = TRUE; 
	`IAC     : pdp_op7_opcode.IAC     = TRUE;
	`RAL     : pdp_op7_opcode.RAL     = TRUE;
	`RTL     : pdp_op7_opcode.RTL     = TRUE;
	`RAR     : pdp_op7_opcode.RAR     = TRUE;
	`RTR     : pdp_op7_opcode.RTR     = TRUE;
	`CML     : pdp_op7_opcode.CML     = TRUE;
	`CMA     : pdp_op7_opcode.CMA     = TRUE;
	`CIA     : pdp_op7_opcode.CIA     = TRUE;
	`CLL     : pdp_op7_opcode.CLL     = TRUE;
	`CLA1    : pdp_op7_opcode.CLA1    = TRUE;
	`CLA_CLL : pdp_op7_opcode.CLA_CLL = TRUE;
	`HLT     : pdp_op7_opcode.HLT     = TRUE;
	`OSR     : pdp_op7_opcode.OSR     = TRUE;
	`SKP     : pdp_op7_opcode.SKP     = TRUE;
	`SNL     : pdp_op7_opcode.SNL     = TRUE;
	`SZL     : pdp_op7_opcode.SZL     = TRUE;
	`SZA     : pdp_op7_opcode.SZA     = TRUE;
	`SNA     : pdp_op7_opcode.SNA     = TRUE;
	`SMA     : pdp_op7_opcode.SMA     = TRUE;
    `SPA     : pdp_op7_opcode.SPA     = TRUE;
    `CLA2    : pdp_op7_opcode.CLA2    = TRUE;
endcase
endtask
	
endclass

class stimulus_randomized;
endclass



initial begin
pdp_mem_opcode = 0;
pdp_op7_opcode=0;
@(negedge stall);
pdp_op7_opcode.CLA_CLL = TRUE;
@(negedge stall);
pdp_mem_opcode = 0;
pdp_op7_opcode=0;
pdp_mem_opcode.AND = TRUE;
@(negedge stall);
pdp_mem_opcode = 0;
pdp_op7_opcode=0;
pdp_op7_opcode.NOP = TRUE;
@(negedge stall);
pdp_mem_opcode = 0;
pdp_op7_opcode=0;
pdp_op7_opcode.CLA1 = TRUE;
@(negedge stall);
pdp_mem_opcode = 0;
pdp_op7_opcode=0;
pdp_mem_opcode.TAD = TRUE;
@(negedge stall);
pdp_mem_opcode = 0;
pdp_op7_opcode=0;
pdp_mem_opcode.AND = TRUE;
@(negedge stall);
pdp_mem_opcode = 0;
pdp_op7_opcode=0;
pdp_mem_opcode.ISZ  = TRUE;
@(negedge stall);
pdp_mem_opcode = 0;
pdp_op7_opcode=0;
pdp_mem_opcode.ISZ  = TRUE;
@(negedge stall);
pdp_mem_opcode = 0;
pdp_op7_opcode=0;
pdp_mem_opcode.JMS  = TRUE;
@(posedge clk);
pdp_mem_opcode = 0;
pdp_op7_opcode=0;
repeat(5)@(posedge clk);


$finish;



end



						
endmodule
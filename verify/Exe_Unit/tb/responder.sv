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
//   Filename:     responder.sv
//   Description:  TBD
//   Created by:   Tareque Ahmad
//   Date:         May 08, 2015
//
//   Copyright:    Tareque Ahmad 
// =======================================================================

`include "pdp8_pkg.sv"
import pdp8_pkg::*;

module responder #(parameter verbose=1)
  (
   // Global input
   input clk,

   input                    ifu_rd_req,
   input  [`ADDR_WIDTH-1:0] ifu_rd_addr,
   output [`DATA_WIDTH-1:0] ifu_rd_data,

   input                    exec_rd_req,
   input  [`ADDR_WIDTH-1:0] exec_rd_addr,
   output bit [`DATA_WIDTH-1:0] exec_rd_data,

   input                    exec_wr_req,
   input  [`ADDR_WIDTH-1:0] exec_wr_addr,
   input  [`DATA_WIDTH-1:0] exec_wr_data

   );


   reg [`DATA_WIDTH-1:0] int_ifu_rd_data;
   reg [`DATA_WIDTH-1:0] int_exec_rd_data;
   reg [11:0] PDP_memory [0:4095];

   // Fill up the memory with known consecutive data
 
initial begin
	forever begin
		@(posedge exec_rd_req);
		randcase
			4: begin exec_rd_data = $urandom_range(0,2**12); end
			1: begin exec_rd_data = 0; end
		endcase
		if(verbose) $display("Data Fed : %0o",exec_rd_data);
	end
end


endmodule // memory_pdp

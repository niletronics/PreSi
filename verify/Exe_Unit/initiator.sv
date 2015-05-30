`include "pdp8_pkg.sv"
import pdp8_pkg::*;

module initiator(
				input wire clk,
				input wire reset_n,
				output logic  [`ADDR_WIDTH-1:0] base_addr,
				output pdp_mem_opcode_s pdp_mem_opcode,
				output pdp_op7_opcode_s pdp_op7_opcode,
				output logic stall,
				input  [`ADDR_WIDTH-1:0] PC_value					
				);
				
assign base_addr = `START_ADDRESS;



					
					
					
					
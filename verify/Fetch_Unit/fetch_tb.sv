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
//   Filename:     fetch_tb.sv
//   Description:  test bench for Fetch and Decode Unit for the PDP-8 (DUT).
//   Created by:   Neeti Verma
//   Date:         May 25, 2015
// =======================================================================

`include "pdp8_pkg.sv"
import pdp8_pkg::*;

module testbench;
  wire clk;
  wire reset_n, stall, ifu_rd_req;
  wire [`ADDR_WIDTH-1:0] PC_value;             
  wire  [`ADDR_WIDTH-1:0] ifu_rd_addr;
  wire [`DATA_WIDTH-1:0] ifu_rd_data;
  wire [`ADDR_WIDTH-1:0] base_addr = `START_ADDRESS;
  pdp_mem_opcode_s pdp_mem_opcode;
  pdp_op7_opcode_s pdp_op7_opcode;
  
  
  clkgen_driver clk_module ( .clk, .reset_n);
  fetch_stimuli_gen SG ( .ifu_rd_req, .num_stimuli, .stall, .generated_data, .PC_value);
  fetch_chkr CHKR (.clk, .reset_n, .stall, .PC_value, .ifu_rd_req, .ifu_rd_addr, .ifu_rd_data, .base_addr, .pdp_mem_opcode, .pdp_op7_opcode);
  instr_decode DUT (.clk, .stall, .PC_value, .ifu_rd_req, .ifu_rd_addr, .ifu_rd_data, .base_addr, .pdp_mem_opcode, .pdp_op7_opcode);
   );

endmodule

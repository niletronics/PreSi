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
//   Filename:     instr_exec.sv
//   Description:  TBD
//   Created by:   Tareque Ahmad
//   Date:         May 03, 2015
//
//   Copyright:    Tareque Ahmad 
// =======================================================================

`include "pdp8_pkg.sv"
import pdp8_pkg::*;

module instr_exec_tb();
   
    // From clkgen_driver module
   wire clk,                              // Free running clock
   wire reset_n,                          // Active low reset signal

   // From Inititor module
   wire [`ADDR_WIDTH-1:0] base_addr,      // Address for first instruction
   pdp_mem_opcode_s pdp_mem_opcode,  // Decoded signals for memory instructions
   pdp_op7_opcode_s pdp_op7_opcode,  // Decoded signals for op7 instructions

   // To Initiator module
   wire               stall,         // Signal to stall Initiator
   wire [`ADDR_WIDTH-1:0] PC_value,      // Current value of Program Counter

   // To responder module
   wire                    exec_wr_req,  // Write request to memory
   wire  [`ADDR_WIDTH-1:0] exec_wr_addr, // Write address 
   wire  [`DATA_WIDTH-1:0] exec_wr_data, // Write data to memory
   wire                    exec_rd_req,  // Read request to memory
   wire  [`ADDR_WIDTH-1:0] exec_rd_addr, // Read address
   wire 				   ifu_rd_req,	  // Not to be used
   wire  [`ADDR_WIDTH-1:0] ifu_rd_addr,   // Not to be used
   wire  [`DATA_WIDTH-1:0] ifu_rd_data,   // Not to be used
   
   // From responder module
   wire   [`DATA_WIDTH-1:0] exec_rd_data  // Read data returned by memory

   //---------------------ClockGen_Drive Instantiation-------------//
      clkgen_driver #(
      .CLOCK_PERIOD(10),
      .RESET_DURATION(500)) clkgen_exe (
      .clk     (clk),
      .reset_n (reset_n));
	//---------------------DUT Instantiation-----------------------//
	instr_exec	DUT(
   // From clkgen_driver module
   .clk,                              // Free running clock
   .reset_n,                          // Active low reset signal

   // From Initiator
   .base_addr,      // Address for first instruction
   .pdp_mem_opcode,  // Decoded signals for memory instructions
   .pdp_op7_opcode,  // Decoded signals for op7 instructions

   // To Initiator module
   .stall,         // Signal to stall decoder
   .PC_value,      // Current value of Program Counter

   // To responder module
   .exec_wr_req,  // Write request to memory
   .exec_wr_addr, // Write address 
   .exec_wr_data, // Write data to memory
   .exec_rd_req,  // Read request to memory
   .exec_rd_addr, // Read address

   // From responder module
   .exec_rd_data  // Read data returned by responder
   );
    //------------------Responder/Memory Instantiation-------------//
    memory_pdp	exe_memory_pdp(
   //------From ClockGen_Driver------------
	.clk,
	//--------------------Not to be driven------------------//
	.ifu_rd_req,
	.ifu_rd_addr,
	.ifu_rd_data,
	//---------------To be used as memory--------------------//
	//read signals
	.exec_rd_req,
	.exec_rd_addr,
	.exec_rd_data,
	//write signals
	.exec_wr_req,
	.exec_wr_addr,
	.exec_wr_data   
   );
	//-------------------Initiator Instantiation-------------------//
	exe_initiator  initiator_exe(
	.base_addr,
	.pdp_mem_opcode,
	.pdp_op7_opcode,
	.stall,
	PC_value
	);
   //---------------------Checker Instantiation--------------------//
	checker_exe ckr(
	.clk,
	.reset_n,
	.base_addr,
	.pdp_mem_opcode,
	.pdp_op7_opcode,
	.stall,
	.PC_value,
	.exec_wr_req,
	.exec_wr_addr,
	.exec_wr_data,
	.exec_rd_req, 
	.exec_rd_addr,
	.ifu_rd_req,	
    .ifu_rd_addr, 
    .ifu_rd_data,
	.exec_rd_data
	);


	  
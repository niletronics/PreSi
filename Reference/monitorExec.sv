
import pdp8_pkg::*;
`include "pdp8_pkg.sv"
module instr_exec_checker
  (// From clkgen_driver module
   input clk,                              // Free running clock
   input reset_n,                          // Active low reset signal

   // From instr_decode module
   input [`ADDR_WIDTH-1:0] base_addr,      // Address for first instruction
   input pdp_mem_opcode_s pdp_mem_opcode,  // Decoded signals for memory instructions
   input pdp_op7_opcode_s pdp_op7_opcode,  // Decoded signals for op7 instructions

   // To instr_decode module
   input                   stall,         // Signal to stall instruction decoder
   input [`ADDR_WIDTH-1:0] PC_value,      // Current value of Program Counter

   // To memory_pdp module
   input                    exec_wr_req,  // Write request to memory
   input  [`ADDR_WIDTH-1:0] exec_wr_addr, // Write address 
   input  [`DATA_WIDTH-1:0] exec_wr_data, // Write data to memory
   input                    exec_rd_req,  // Read request to memory
   input  [`ADDR_WIDTH-1:0] exec_rd_addr, // Read address

   // From memory_pdp module
   input   [`DATA_WIDTH-1:0] exec_rd_data  // Read data returned by memory
   );
   
   reg                     new_mem_opcode; // Signal to detect a new memory instruction
   reg                     new_op7_opcode; // Signal to detect a new op7 instruction
   reg  [`ADDR_WIDTH-1:0] int_exec_wr_addr;
   reg  [`ADDR_WIDTH-1:0] int_exec_rd_addr;
   reg [`ADDR_WIDTH-1:0]   int_PC_value ;
   
   assign  int_PC_value =PC_value;
   assign int_exec_rd_addr = exec_rd_addr;
   assign int_exec_wr_addr = exec_wr_addr;
    pdp_mem_opcode_s int_pdp_mem_opcode;  // Decoded signals for memory instructions
    pdp_op7_opcode_s int_pdp_op7_opcode; 
   assign int_pdp_mem_opcode = pdp_mem_opcode;
   assign int_pdp_op7_opcode = pdp_op7_opcode;
   assign new_mem_opcode = (pdp_mem_opcode.AND ||
                            pdp_mem_opcode.TAD ||
                            pdp_mem_opcode.ISZ ||
                            pdp_mem_opcode.DCA ||
                            pdp_mem_opcode.JMS ||
                            pdp_mem_opcode.JMP);

   assign new_op7_opcode = (pdp_op7_opcode.NOP ||
                            pdp_op7_opcode.IAC ||
                            pdp_op7_opcode.RAL ||
                            pdp_op7_opcode.RTL ||
                            pdp_op7_opcode.RAR ||
                            pdp_op7_opcode.RTR ||
                            pdp_op7_opcode.CML ||
                            pdp_op7_opcode.CMA ||
                            pdp_op7_opcode.CIA ||
                            pdp_op7_opcode.CLL ||
                            pdp_op7_opcode.CLA1 ||
                            pdp_op7_opcode.CLA_CLL ||
                            pdp_op7_opcode.HLT ||
                            pdp_op7_opcode.OSR ||
                            pdp_op7_opcode.SKP ||
                            pdp_op7_opcode.SNL ||
                            pdp_op7_opcode.SZL ||
                            pdp_op7_opcode.SZA ||
                            pdp_op7_opcode.SNA ||
                            pdp_op7_opcode.SMA ||
                            pdp_op7_opcode.SPA ||
                            pdp_op7_opcode.CLA2);
   
  
   
   always @ (posedge new_mem_opcode or posedge new_op7_opcode)begin
   
     if(pdp_mem_opcode.AND)begin
      repeat (4) begin @(posedge clk); end
       if(int_exec_rd_addr !== int_pdp_mem_opcode.mem_inst_addr)begin
         $display(" @%0dns Read protocol to memory from Execution unit after seeing MEM instruction AND not followed ",$time);
      end
    end
    else if(pdp_mem_opcode.TAD) begin
        repeat (4) begin @(posedge clk); end
        if(int_exec_rd_addr !== int_pdp_mem_opcode.mem_inst_addr)begin
       $display(" Execution of TAD is failed ");
        end
      end
    else if(pdp_mem_opcode.ISZ ) begin
        repeat (4) begin @(posedge clk); end
        if((int_exec_rd_addr !== int_pdp_mem_opcode.mem_inst_addr) &&(int_exec_wr_addr !== int_pdp_mem_opcode.mem_inst_addr))begin
       $display(" Execution of ISZ is failed ");
        end
      end
    else if(pdp_mem_opcode.DCA) begin
        repeat (2) begin @ (posedge clk); end
        if(int_exec_wr_addr !== int_pdp_mem_opcode.mem_inst_addr) begin  
          $display(" Execution of DCA is failed ");
            end
end
   else if(pdp_mem_opcode.JMP) begin
     repeat (2) begin @ (posedge clk); end
         if(int_PC_value !== int_pdp_mem_opcode.mem_inst_addr) begin
           $display(" Execution of DCA is failed ");
         end

  end
end
 endmodule    
       
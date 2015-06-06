
import pdp8_pkg::*;
`include "pdp8_pkg.sv"
module instr_exec_stub
  (
   // From clkgen_driver module
   input clk,                              // Free running clock
                   

   // From instr_decode module
   input [`ADDR_WIDTH-1:0] base_addr,      // Address for first instruction
   input pdp_mem_opcode_s pdp_mem_opcode,  // Decoded signals for memory instructions
   input pdp_op7_opcode_s pdp_op7_opcode,  // Decoded signals for op7 instructions

   // To instr_decode module
   output                   stall,         // Signal to stall instruction decoder
   output [`ADDR_WIDTH-1:0] PC_value      // Current value of Program Counter

    );

   reg                   int_stall; // Internal signal to control stall
   reg [3:0]             delay;
   reg                   new_mem_opcode; // Signal to detect a new memory instruction
   reg                   new_op7_opcode; // Signal to detect a new op7 instruction
   reg   [`ADDR_WIDTH-1:0] int_PC_value;

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
      
      
      // Execution Stub which behaves exactly same as the neighbouring module i.e Instr_decode                      
     always @(posedge clk)   begin                  
                            
        if (new_mem_opcode || new_op7_opcode) begin
             int_stall  <= 1;
        if(pdp_op7_opcode.CLA_CLL)begin
             repeat (3) begin @ (posedge clk); end 
             int_stall<=0;
             int_PC_value =  ({$random} % 12'b111111111111);end
        else if (pdp_mem_opcode.TAD || pdp_mem_opcode.AND)begin
             repeat (5) begin @ (posedge clk); end
              int_stall <=0;
              int_PC_value =  ({$random} % 12'b111111111111); end
        else if (pdp_mem_opcode.ISZ)begin
             repeat (6) begin @ (posedge clk); end
              int_stall <= 0;
              int_PC_value =  ({$random} % 12'b111111111111); end
        else if (pdp_mem_opcode.DCA)begin
             repeat (4) begin @ (posedge clk); end      
               int_stall <= 0;
               int_PC_value =  ({$random} % 12'b111111111111);end
        else if (pdp_mem_opcode.JMS)begin
             repeat (4) begin @ (posedge clk); end      
               int_stall <= 0;
               int_PC_value =  ({$random} % 12'b111111111111);end     
        else if (pdp_mem_opcode.JMP)begin   
             repeat (3) begin @ (posedge clk); end      
               int_stall <= 0;
               int_PC_value =  ({$random} % 12'b111111111111);end    
        else begin
             repeat (3) begin @ (posedge clk); end      
               int_stall <= 0;
               int_PC_value =  ({$random} % 12'b111111111111);end  // delay timing based stall generation if elseif else structure end                  
       end
       else begin
         int_stall <=0;
       end  // new opcode if else structure begin end
       end// always proedural end
       
       assign stall = int_stall ;
       assign PC_value = int_PC_value ;
       
     endmodule
       
       

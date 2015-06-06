
import pdp8_pkg::*;
`include "pdp8_pkg.sv"
module exec_chkr
                                          // From clkgen_driver module
  ( input clk,                              // Free running clock
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
   input   [`DATA_WIDTH-1:0] exec_rd_data,  // Read data returned by memory
   logic  [`DATA_WIDTH:0]   intAcc, 
   logic           intLink,
   state current_state
   );
   
   
   
   reg                     new_mem_opcode; // Signal to detect a new memory instruction
   reg                     new_op7_opcode; // Signal to detect a new op7 instruction
   reg  [`DATA_WIDTH:0]    intAcc_checker; 
   reg                     intLink_checker;   
   reg [`ADDR_WIDTH-1:0]   PC_value_checker;
   reg  [`DATA_WIDTH-1:0]  int_write_data;
   reg  [`ADDR_WIDTH-1:0] int_exec_wr_addr;
   reg  [`ADDR_WIDTH-1:0] int_exec_rd_addr;
   reg  [`ADDR_WIDTH-1:0]   int_PC_value;
   reg  [`DATA_WIDTH-1:0]  int_exec_wr_data;
   
    pdp_mem_opcode_s int_pdp_mem_opcode;  // Decoded signals for memory instructions
   pdp_op7_opcode_s int_pdp_op7_opcode; 
    //PC_value_checker = PC_value;
    //int_PC_value = PC_value;
    assign int_exec_wr_data = exec_wr_data;
   assign int_exec_rd_addr = exec_rd_addr;
   assign int_exec_wr_addr = exec_wr_addr;
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
      
      
      //FUNCTIONALITY CHECK OF EXECUTION UNIT FOR MEMORY OPCODES: checker source 
   
   always @ (posedge new_mem_opcode or posedge new_op7_opcode)begin
   
     if(pdp_mem_opcode.AND)begin                          //Functional Check for AND instruction
       intAcc_checker <= intAcc;
      repeat (5) begin @(posedge clk); end
       intAcc_checker = intAcc_checker & exec_rd_data;
       comparision();
      end
      
      
    else if(pdp_mem_opcode.TAD) begin                     //Functional check for TAD instruction
        intAcc_checker <= intAcc;
        intLink_checker <= intLink;
        repeat (4) begin @(posedge clk); end
        intAcc_checker <= intAcc_checker + exec_rd_data;
        if(intAcc_checker[`DATA_WIDTH]) begin
        intLink_checker <= ~intLink_checker;
        comparision();end
        end
      
    else if (pdp_mem_opcode.ISZ ) begin                           // Functional check for ISZ
        repeat (5) begin @(posedge clk); end 
        if((int_exec_rd_addr !== int_pdp_mem_opcode.mem_inst_addr) &&(int_exec_wr_addr !== int_pdp_mem_opcode.mem_inst_addr))begin
       $display("@ %0d  Execution of ISZ is failed ",$time);
        end
      end
      
      
/*     else if(pdp_mem_opcode.DCA) begin                            //Functional check for DCA instruction
      if(current_state == DCA)begin
          intAcc_checker <= intAcc;
        repeat (2) begin @ (posedge clk); end
           comparision();
            end
          end
   else if(pdp_mem_opcode.JMS) begin                            //Functional check for JMS not successfully implemented instead JMS effect on outputs of Execution verified correctly.
          intAcc_checker <=intAcc;
          PC_value_checker <=PC_value;
   repeat (1) begin @(posedge clk); end  
     
          comparision();
         end
   else if(pdp_mem_opcode.JMP) begin                           // Functional check for JUMP
           if(current_state == UNSTALL)begin
          PC_value_checker <= PC_value;
          comparision();
        end
 end  */      
 else if (pdp_op7_opcode.CLA_CLL) begin                      //Functional check for Clear link & Accumulator.
          intAcc_checker <= intAcc;
          intLink_checker <= intLink;
   repeat (1) begin @(posedge clk); end
          intAcc_checker = 0;
          intLink_checker =0;
          comparision();
    end
  end
     
     

 task comparision ;
   begin
   
  if(pdp_mem_opcode.AND)begin
    if(intAcc_checker !== intAcc)begin
      $display(" @ %0d ns Execution of AND instruction failed  Accumulator_checker: %o Accumulator value in Execution unit: %o ",$time,intAcc_checker,intAcc);end 
end
  if(pdp_mem_opcode.TAD) begin
    if((intAcc_checker !== intAcc) || (intLink_checker !== intLink)) begin
      $display("@ %0d ns Execution of TAD instruction failed  Accumulator_checker: %o Accumulator value in Execution unit: %o & Link_checker :%b Link value in Execution unit : %b",$time,intAcc_checker,intAcc,intLink_checker,intLink);  end
  end
     end
    if(pdp_mem_opcode.DCA) begin
      if((intAcc_checker !== exec_wr_data) || (intAcc !== 0)) begin
      $display (" @ %0d nsExecution of DCA instruction failed Accumulator_checker  %o value of Accumulator deposited on exec_wr_data value %o of Accumulator after depositing: %o",$time,intAcc_checker,exec_wr_data,intAcc); end
  end

   if(pdp_mem_opcode.JMS) begin
     if(PC_value_checker !== int_exec_wr_data)begin
     // $display ("  @ %0d Execution of JMS instruction failed Program counter value %o and write data on memory %o",$time,PC_value_checker ,int_exec_wr_data);
   end
 end
   if(pdp_mem_opcode.JMP) begin
   if(PC_value_checker !== pdp_mem_opcode.mem_inst_addr) begin
     $display (" @ %0d nsExecution of JMP instruction failed PC_value_checker: %o pdp_mem_instr_addr: %o ",$time,PC_value_checker,pdp_mem_opcode.mem_inst_addr); end       
  end
  if(pdp_op7_opcode.CLA_CLL) begin
    if(intAcc_checker == intAcc || intLink_checker == intLink)begin
      $display(" @ %0d ns Execution of clear accumulator and clear link instruction failed intAccumulator_checker %o Accumulator value in DUT %o Link_checker %b Link in DUT %b ",$time,intAcc_checker,intAcc,intLink_checker,intLink); end
    end


  endtask
  
         
 endmodule    
       

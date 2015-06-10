
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
   reg  [`DATA_WIDTH:0]    	chkr_ac; 
   reg						chkr_link;   
   bit [`ADDR_WIDTH-1:0]	chkr_PC = `START_ADDRESS;
   bit [`ADDR_WIDTH-1:0]	chkr_tempPC = `START_ADDRESS;
   reg  [`DATA_WIDTH-1:0]	int_write_data;
   reg  [`ADDR_WIDTH-1:0]	int_exec_wr_addr;
   reg  [`ADDR_WIDTH-1:0]	int_exec_rd_addr,chkr_rd_addr, chkr_wr_addr;
   reg  [`ADDR_WIDTH-1:0]	int_PC_value;
   reg  [`DATA_WIDTH-1:0]	int_exec_wr_data, chkr_rd_data, chkr_wr_data;
   bit 						chkr_rd_req, chkr_wr_req;
   bit 						debug=1;
   
    pdp_mem_opcode_s int_pdp_mem_opcode;  // Decoded signals for memory instructions
   pdp_op7_opcode_s int_pdp_op7_opcode; 
    //chkr_PC = PC_value;
    //int_PC_value = PC_value;
/*     assign int_exec_wr_data = exec_wr_data;
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
 */      
      
      //FUNCTIONALITY CHECK OF EXECUTION UNIT FOR MEMORY OPCODES: checker source 
   // Will check for IDLE and Branch to stall transition manually by assertion
   // Starting from stall to get constant clock cycle count
   // Rule exec_rd_req should be high only for one clock cycle
   // Rule to check for PC_value
   
always @ (posedge clk)	begin

	wait(instr_exec.current_state === BRANCH && instr_exec.stall);
	chkr_PC 		<= instr_exec.PC_value + 1'b1;
	chkr_tempPC		<= chkr_PC;	
	chkr_ac			<= instr_exec.intAcc;
	case(1'b1) 
	pdp_mem_opcode.AND : begin
								@(posedge clk);				//MEM_RD_REQ
								chkr_rd_req <= 1'b1;
								chkr_rd_addr <= pdp_mem_opcode.mem_inst_addr;
								@(posedge clk);				// DATA_RCVD
								compare(chkr_rd_req, exec_rd_req,"Read Request","AND");
								compare(chkr_rd_addr, exec_rd_addr,"Read Address","AND");
								chkr_rd_req <=1'b0;
								chkr_rd_data <= exec_rd_data;
								@(posedge clk); 			// AND_ACC_MEM
								compare(chkr_rd_req, exec_rd_req,"Read Request","AND");
								chkr_ac <= chkr_ac && chkr_rd_data;
								@(posedge clk);				// UNSTALL
								compare(chkr_link,instr_exec.intLink,"LinkBit","AND");
								compare(chkr_ac,instr_exec.intAcc,"Accumulator","AND");	
								chkr_wr_req		<= 0;														
						end
						
	pdp_mem_opcode.TAD : begin					
								@(posedge clk);				//MEM_RD_REQ
								chkr_rd_req <= 1'b1;
								chkr_rd_addr <= pdp_mem_opcode.mem_inst_addr;
								@(posedge clk);				// DATA_RCVD
								compare(chkr_rd_req, exec_rd_req,"Read Request","TAD");
								compare(chkr_rd_addr, exec_rd_addr,"Read Address","TAD");
								chkr_rd_data <= exec_rd_data;
								chkr_rd_req <=1'b0;
								@(posedge clk); 			// ADD_ACC_MEM
								compare(chkr_rd_req, exec_rd_req, "Read Request","TAD");
								{chkr_link,chkr_ac}<={chkr_link,chkr_ac} + chkr_rd_data;
								@(posedge clk);				// UNSTALL
								compare(chkr_link,instr_exec.intLink, "LinkBit","TAD");
								compare(chkr_ac,instr_exec.intAcc, "Accumulator","TAD");
								chkr_wr_req		<= 0;
							end
	
	pdp_mem_opcode.ISZ : begin
								@(posedge clk);				//MEM_RD_REQ
								chkr_rd_req <= 1'b1;
								chkr_rd_addr <= pdp_mem_opcode.mem_inst_addr;
								@(posedge clk);				// DATA_RCVD
								compare(chkr_rd_req, exec_rd_req,"Read Request","ISZ");
								compare(chkr_rd_addr, exec_rd_addr,"Read Address","ISZ");
								chkr_rd_data <= exec_rd_data;
								chkr_rd_req <=1'b0;
								@(posedge clk); 			// ISZ_WR_REQ
								compare(chkr_rd_req, exec_rd_req, "Read Request","ISZ");
								chkr_wr_req <= 1'b1;
								chkr_wr_addr <= pdp_mem_opcode.mem_inst_addr;
								chkr_wr_data <= exec_wr_data+1'b1;
								chkr_tempPC <= chkr_PC;
								@(posedge clk);				// ISZ_UPDT_PC
								compare(chkr_wr_req, exec_wr_req,"Write Request","ISZ");
								compare(chkr_link,instr_exec.intLink, "LinkBit","ISZ");
								compare(chkr_ac,instr_exec.intAcc, "Accumulator","ISZ");
								if(chkr_rd_data == 0)chkr_PC <= chkr_tempPC + 1'b1;
								@(posedge clk);				// UNSTALL
								compare(chkr_PC, PC_value,"PC_value","ISZ");
								chkr_wr_req		<= 0;
							end
	
	pdp_mem_opcode.DCA : begin
							@(posedge clk);					// DCA
							chkr_wr_req  <= 1;
							chkr_wr_addr <= pdp_mem_opcode.mem_inst_addr;
							chkr_wr_data <= PC_value;							
							@(posedge clk);					//CLA
							compare(chkr_wr_req, exec_wr_req,"Write Request","DCA");
							compare(chkr_wr_addr, exec_wr_addr,"Write Address","DCA");
							compare(chkr_wr_data, exec_wr_data,"Write Data","DCA");
							chkr_ac <=1'b0;
							chkr_link <=1'b0;							
							@(posedge clk);					// UNSTALL
							compare(chkr_link,instr_exec.intLink, "LinkBit","DCA");
							compare(chkr_ac,instr_exec.intAcc, "Accumulator","DCA");
							chkr_wr_req		<= 0;
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","DCA");							
						end
						
	pdp_mem_opcode.JMS : begin
							@(posedge clk);					// JMS_WR_REQ
							chkr_wr_req  <= 1;
							chkr_wr_addr <= pdp_mem_opcode.mem_inst_addr;
							chkr_wr_data <= chkr_ac;							
							@(posedge clk);					//JMS_UPDT_PC
							compare(chkr_wr_req, exec_wr_req,"Write Request","DCA");
							compare(chkr_wr_addr, exec_wr_addr,"Write Address","DCA");
							compare(chkr_wr_data, exec_wr_data,"Write Data","DCA");
							chkr_PC      <= pdp_mem_opcode.mem_inst_addr+1;							
							@(posedge clk);					// UNSTALL
							chkr_wr_req		<= 0;
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","JMS");
						end
						
	
	
						
	endcase 
	
		
	
   
     /* if(pdp_mem_opcode.AND)begin                          //Functional Check for AND instruction
		//PC value should increase
		@(posedge clk);
		chkr_rd_req <= 1'b1;
		@(posedge clk);
		compare(chkr_rd_req, exec_rd_req, "Read Request");
		@(posedge clk);
		compare(chkr_rd_req, exec_rd_req, "Read Request one cycle later");
		@(posedge clk);
		compare(chkr_rd_req, exec_rd_req, "Read Request two cycle later");
		chkr_ac <= intAcc;
		repeat (5) begin @(posedge clk); end
		chkr_ac = chkr_ac & exec_rd_data;
		comparision();
      end */
      
      
    if(pdp_mem_opcode.TAD) begin                     //Functional check for TAD instruction
        chkr_ac <= intAcc;
        chkr_link <= intLink;
        repeat (4) begin @(posedge clk); end
        chkr_ac <= chkr_ac + exec_rd_data;
        if(chkr_ac[`DATA_WIDTH]) begin
        chkr_link <= ~chkr_link;
        comparision();end
        end
      
    else if (pdp_mem_opcode.ISZ) begin                           // Functional check for ISZ
        repeat (5) begin @(posedge clk); end 
        if((int_exec_rd_addr !== int_pdp_mem_opcode.mem_inst_addr) &&(int_exec_wr_addr !== int_pdp_mem_opcode.mem_inst_addr))begin
		$display("@ %0d  Execution of ISZ is failed ",$time);
        end
      end
      
      
/*     else if(pdp_mem_opcode.DCA) begin                            //Functional check for DCA instruction
      if(current_state == DCA)begin
          chkr_ac <= intAcc;
        repeat (2) begin @ (posedge clk); end
           comparision();
            end
          end
   else if(pdp_mem_opcode.JMS) begin                            //Functional check for JMS not successfully implemented instead JMS effect on outputs of Execution verified correctly.
          chkr_ac <=intAcc;
          chkr_PC <=PC_value;
   repeat (1) begin @(posedge clk); end  
     
          comparision();
         end
   else if(pdp_mem_opcode.JMP) begin                           // Functional check for JUMP
           if(current_state == UNSTALL)begin
          chkr_PC <= PC_value;
          comparision();
        end
 end  */      
 else if (pdp_op7_opcode.CLA_CLL) begin                      //Functional check for Clear link & Accumulator.
          chkr_ac <= intAcc;
          chkr_link <= intLink;
   repeat (1) begin @(posedge clk); end
          chkr_ac = 0;
          chkr_link =0;
          comparision();
    end
  end
     
     

 task comparision ;
   begin
   
  if(pdp_mem_opcode.AND)begin
    if(chkr_ac !== intAcc)begin
      $display(" @ %0d ns Execution of AND instruction failed  Accumulator_checker: %o Accumulator value in Execution unit: %o ",$time,chkr_ac,intAcc);end 
end
  if(pdp_mem_opcode.TAD) begin
    if((chkr_ac !== intAcc) || (chkr_link !== intLink)) begin
      $display("@ %0d ns Execution of TAD instruction failed  Accumulator_checker: %o Accumulator value in Execution unit: %o & Link_checker :%b Link value in Execution unit : %b",$time,chkr_ac,intAcc,chkr_link,intLink);  end
  end
     end
    if(pdp_mem_opcode.DCA) begin
      if((chkr_ac !== exec_wr_data) || (intAcc !== 0)) begin
      $display (" @ %0d nsExecution of DCA instruction failed Accumulator_checker  %o value of Accumulator deposited on exec_wr_data value %o of Accumulator after depositing: %o",$time,chkr_ac,exec_wr_data,intAcc); end
  end

   if(pdp_mem_opcode.JMS) begin
     if(chkr_PC !== int_exec_wr_data)begin
     // $display ("  @ %0d Execution of JMS instruction failed Program counter value %o and write data on memory %o",$time,chkr_PC ,int_exec_wr_data);
   end
 end
   if(pdp_mem_opcode.JMP) begin
   if(chkr_PC !== pdp_mem_opcode.mem_inst_addr) begin
     $display (" @ %0d nsExecution of JMP instruction failed chkr_PC: %o pdp_mem_instr_addr: %o ",$time,chkr_PC,pdp_mem_opcode.mem_inst_addr); end       
  end
  if(pdp_op7_opcode.CLA_CLL) begin
    if(chkr_ac == intAcc || chkr_link == intLink)begin
      $display(" @ %0d ns Execution of clear accumulator and clear link instruction failed intAccumulator_checker %o Accumulator value in DUT %o Link_checker %b Link in DUT %b ",$time,chkr_ac,intAcc,chkr_link,intLink); end
    end
  endtask

task compare(input logic[11:0] chkr_value, input logic[11:0] dut_value, input string field, input string opcode_name);
	begin
		match_a:assert(chkr_value === dut_value) begin if(debug) $display("%m_%0t:MATCHED\t%0s\tOpcode = %0s\tDUT Value = %0o\tChecker Value = %0o and DUT FSM State = %s",$time,field,opcode_name,dut_value,chkr_value, instr_exec.current_state); end
		else $error("%m_%0t: NOT MATCHED\t%0s\tOpcode = %0s\tDUT Value = %0o\tChecker Value = %0o and DUT FSM State = %s",$time,field,opcode_name,dut_value,chkr_value, instr_exec.current_state); 
	end
endtask

  
         
 endmodule    
       

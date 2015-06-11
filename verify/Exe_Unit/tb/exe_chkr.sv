
 import pdp8_pkg::*;
`include "pdp8_pkg.sv"
module exec_chkr #(parameter verbose=1, parameter debug = 0)                          // From clkgen_driver module
  (input clk,                             // Free running clock
   input reset_n,                          // Active low reset signal
   // From instr_decode module
   input [`ADDR_WIDTH-1:0] base_addr,      // Address for first instruction
   input pdp_mem_opcode_s pdp_mem_opcode,  // Decoded signals for memory instructions
   input pdp_op7_opcode_s pdp_op7_opcode,  // Decoded signals for op7 instructions
   // To instr_decode module
   input                   stall,          // Signal to stall instruction decoder
   input [`ADDR_WIDTH-1:0] PC_value,       // Current value of Program Counter
   // To memory_pdp module
   input                    exec_wr_req,   // Write request to memory
   input  [`ADDR_WIDTH-1:0] exec_wr_addr,  // Write address 
   input  [`DATA_WIDTH-1:0] exec_wr_data,  // Write data to memory
   input                    exec_rd_req,   // Read request to memory
   input  [`ADDR_WIDTH-1:0] exec_rd_addr,  // Read address
   // From memory_pdp module
   input   [`DATA_WIDTH-1:0] exec_rd_data  // Read data returned by memory
   );

   bit  [`DATA_WIDTH:0]   	chkr_ac; 
   bit						chkr_link;   
   bit [`ADDR_WIDTH-1:0]	chkr_PC = `START_ADDRESS;
   bit [`ADDR_WIDTH-1:0]	chkr_tempPC = `START_ADDRESS;
   bit [`ADDR_WIDTH-1:0]	chkr_rd_addr, chkr_wr_addr;
   bit [`DATA_WIDTH-1:0]	chkr_rd_data, chkr_wr_data;
   bit 						chkr_rd_req, chkr_wr_req;
   reg						chkr_tempLink;
   int						testcount;
   int						passcount;
   int						failcount;
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
	chkr_tempLink	<= instr_exec.tempLink;
	chkr_link		<= instr_exec.intLink;
	unique case(1'b1) 
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
								compare(chkr_rd_data, exec_rd_data,"Read Data","AND");
								chkr_ac <= chkr_ac & chkr_rd_data;
								@(posedge clk);				// UNSTALL
								compare(chkr_link,instr_exec.intLink,"LinkBit","AND");
								compare(chkr_ac,instr_exec.intAcc,"Accumulator","AND");	
								chkr_wr_req		<= 0;
								@(posedge clk);
								if(debug)compare(chkr_wr_req, exec_wr_req,"Write Request","AND");
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
								chkr_tempLink <= instr_exec.intLink;
								@(posedge clk); 			// ADD_ACC_MEM
								compare(chkr_rd_req, exec_rd_req, "Read Request","TAD");
								compare(chkr_rd_data, exec_rd_data,"Read Data","TAD");
								chkr_ac <= chkr_ac + chkr_rd_data;
								if(chkr_ac[`DATA_WIDTH]) chkr_link <= ~chkr_tempLink;
								@(posedge clk);				// UNSTALL
								compare(chkr_ac,instr_exec.intAcc, "Accumulator","TAD");
								if(debug)$display("%m: %0d <= %0d + %0d expected = %d checker = %d",instr_exec.intAcc, instr_exec.tempAcc, instr_exec.int_exec_rd_data, instr_exec.tempAcc + instr_exec.int_exec_rd_data, {chkr_link,chkr_ac});
								//compare(chkr_link,instr_exec.intLink, "LinkBit","TAD");
								chkr_wr_req		<= 0;
								@(posedge clk);
								compare(chkr_PC, PC_value,"PC_value","TAD");		//Right Place to check for PC Value
								compare(chkr_wr_req, exec_wr_req,"Write Request","TAD");
								compare(chkr_link,instr_exec.intLink, "LinkBit","TAD");
								
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
								compare(chkr_rd_data, exec_rd_data,"Read Data","ISZ");
								chkr_wr_req <= 1'b1;
								chkr_wr_addr <= pdp_mem_opcode.mem_inst_addr;
								chkr_wr_data <= exec_rd_data+1'b1;
								chkr_tempPC <= chkr_PC;
								@(posedge clk);				// ISZ_UPDT_PC
								compare(chkr_wr_req, exec_wr_req,"Write Request","ISZ");
								compare(chkr_wr_addr, exec_wr_addr,"Write Address","ISZ");
								compare(chkr_wr_data, exec_wr_data,"Write Data","ISZ");
								compare(chkr_link,instr_exec.intLink, "LinkBit","ISZ");
								compare(chkr_ac,instr_exec.intAcc, "Accumulator","ISZ");
								if(chkr_rd_data == 0)chkr_tempPC <= chkr_tempPC + 1'b1;
								@(posedge clk);				// UNSTALL
								chkr_PC <= chkr_tempPC;
								chkr_wr_req		<= 0;
								@(posedge clk);				
								compare(chkr_PC, PC_value,"PC_value","ISZ");		//Right Place to check for PC Value
							end
				
	pdp_mem_opcode.DCA : begin
							@(posedge clk);					// DCA
							chkr_wr_req  <= 1;
							chkr_wr_addr <= pdp_mem_opcode.mem_inst_addr;
							chkr_wr_data <= chkr_ac;							
							@(posedge clk);					//CLA
							compare(chkr_wr_req, exec_wr_req,"Write Request","DCA");
							compare(chkr_wr_addr, exec_wr_addr,"Write Address","DCA");
							compare(chkr_wr_data, exec_wr_data,"Write Data","DCA");
							chkr_ac <=1'b0;
							@(posedge clk);					// UNSTALL
							compare(chkr_link,instr_exec.intLink, "LinkBit","DCA");
							compare(chkr_ac,instr_exec.intAcc, "Accumulator","DCA");
							chkr_wr_req		<= 0;
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","DCA");	
							compare(chkr_wr_req, exec_wr_req,"Write Request","DCA");
						end
						
	pdp_mem_opcode.JMS : begin
							@(posedge clk);					// JMS_WR_REQ
							chkr_wr_req  	<= 1;
							chkr_wr_addr 	<= pdp_mem_opcode.mem_inst_addr;
							chkr_wr_data 	<= chkr_PC;							
							@(posedge clk);					//JMS_UPDT_PC
							compare(chkr_wr_req, exec_wr_req,"Write Request","JMS");
							compare(chkr_wr_addr, exec_wr_addr,"Write Address","JMS");
							compare(chkr_wr_data, exec_wr_data,"Write Data","JMS");
							chkr_tempPC			<= pdp_mem_opcode.mem_inst_addr+1;							
							@(posedge clk);				// UNSTALL
							chkr_PC <= chkr_tempPC;
							chkr_wr_req		<= 0;
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","JMS");
						end
	
	pdp_mem_opcode.JMP : begin
							@(posedge clk);		//JMP
							chkr_tempPC <= pdp_mem_opcode.mem_inst_addr;
							@(posedge clk);				// UNSTALL
							chkr_PC <= chkr_tempPC;
							chkr_wr_req		<= 0;
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","JMP");
						end
	
	pdp_op7_opcode.CLA_CLL : begin							
							@(posedge clk);		//CLA_CLL
							chkr_ac <= '0;
							chkr_link <= '0;
							@(posedge clk);				// UNSTALL
							chkr_wr_req		<= '0;
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","CLA_CLL");
							end
	
	pdp_op7_opcode.NOP : begin
							@(posedge clk);		//CLA_CLL
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","NOP");
						end
	 	
	pdp_op7_opcode.IAC : begin
							@(posedge clk);		//CLA_CLL
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","IAC"); 
						end					
	
	pdp_op7_opcode.RAL : begin
							@(posedge clk);		//CLA_CLL
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","RAL");
						end					
	
	pdp_op7_opcode.RTL : begin
							@(posedge clk);		//CLA_CLL
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","RTL");
						end					
	
	pdp_op7_opcode.RAR : begin
							@(posedge clk);		//CLA_CLL
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","RAR"); 
						end					
	
	pdp_op7_opcode.RTR : begin
							@(posedge clk);		//CLA_CLL
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","RTR");
						end					
	
	pdp_op7_opcode.CML : begin
							@(posedge clk);		//CLA_CLL
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","CML"); 
						end					
	
	pdp_op7_opcode.CMA : begin
							@(posedge clk);		//CLA_CLL
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","CMA"); 
						end					
	
	pdp_op7_opcode.CIA : begin
							@(posedge clk);		//CLA_CLL
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","CIA"); 
						end					
	
	pdp_op7_opcode.CLL : begin
							@(posedge clk);		//CLA_CLL
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","CLL"); 
						end					
	
	pdp_op7_opcode.CLA1: begin
							@(posedge clk);		//CLA_CLL
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","CLA1"); 
						end					
	
	pdp_op7_opcode.HLT  : begin
							@(posedge clk);		//NOP
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","HLT"); 
						end				
	
	pdp_op7_opcode.OSR  : begin
							@(posedge clk);		//NOP
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","OSR"); 
						end					
	
	pdp_op7_opcode.SKP  : begin
							@(posedge clk);		//NOP
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","SKP");
						end					
	
	pdp_op7_opcode.SNL  : begin
							@(posedge clk);		//NOP
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","SNL"); end					
	
	pdp_op7_opcode.SZL  : begin
							@(posedge clk);		//NOP
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","SZL"); end					
	
	pdp_op7_opcode.SZA  : begin
							@(posedge clk);		//NOP
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","SZA"); 
						end
	
	pdp_op7_opcode.SNA  : begin
							@(posedge clk);		//NOP
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","SNA"); 
						end					
	
	pdp_op7_opcode.SMA  : begin
							@(posedge clk);		//NOP
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","SMA"); 
						end
	
	pdp_op7_opcode.SPA  : begin
							@(posedge clk);		//NOP
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","SPA"); 
						end					
	
	pdp_op7_opcode.CLA2 : begin
							@(posedge clk);		//NOP
							@(posedge clk);		// UNSTALL
							@(posedge clk);
							compare(chkr_PC, PC_value,"PC_value","CLA2");
						end
					
	endcase   
end

task compare(input logic[11:0] chkr_value, input logic[11:0] dut_value, input string field, input string opcode_name);
	begin
		testcount++;
		match_a:assert(chkr_value === dut_value) begin passcount++; if(verbose) $display("%m_%0t:     MATCHED\tOpcode = %8s\t%10s\tDUT = %o\tChkr = %o\tState(DUT) = %0s",$time,opcode_name,field,dut_value,chkr_value, instr_exec.current_state); end
		else begin
		failcount++;
		$fatal(0,"%m_%0t: NOT-MATCHED\tOpcode = %8s\t%10s\tDUT = %o\tChkr = %o\tState(DUT) = %s",$time,opcode_name,field,dut_value,chkr_value, instr_exec.current_state); 
		end
	end
endtask

final begin
$display("\t|\t***********************\tTesting Completed\t*********************\t|");
$display("\t|\t-----------------------\t Tests Executed\t:%8d\t--------\t|", testcount);
$display("\t|\t-----------------------\t Tests Passed  \t:%8d\t--------\t|", passcount);
$display("\t|\t-----------------------\t Tests Failed  \t:%8d\t--------\t|", failcount);
$display("\t|\t***********************\tOverall Test Result = %5s \t*************\t|", failcount==0?"PASSED":"FAILED");
end
endmodule    
       

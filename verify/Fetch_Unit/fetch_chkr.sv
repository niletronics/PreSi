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
//   Filename:     fetch_chkr.sv
//   Description:  checker for Fetch and Decode Unit for the PDP-8 (DUT).
//   Created by:   Neeti Verma
//   Date:         May 25, 2015
// =======================================================================

`include "pdp8_pkg.sv"
import pdp8_pkg::*;

module fetch_chkr
  (
   // Global inputs
   input clk,
   input reset_n,

   // To Execution unit
   input stall,
   intput [`ADDR_WIDTH-1:0] PC_value,

   // From memory unit
   input                    ifu_rd_req,
   input  [`ADDR_WIDTH-1:0] ifu_rd_addr,

   // To memory unit
   input [`DATA_WIDTH-1:0] ifu_rd_data,

   // From Execution unit (decode struct)
   input [`ADDR_WIDTH-1:0] base_addr,
   input pdp_mem_opcode_s pdp_mem_opcode,
   input pdp_op7_opcode_s pdp_op7_opcode
   );
   
   parameter	LOW = 1'b0,
				HIGH = 1'b1;
			
   reg [2:0] counter
   reg [`ADDR_WIDTH-1:0] chkr_base_addr; // Latched value of base address
   
   reg                   chkr_rd_req;    // internal signal to drive read request to memory for instr fetch
   reg [`ADDR_WIDTH-1:0] chkr_rd_addr;   // internal register to latch PC from EU used as memory address for next instr fetch
   
   reg [`DATA_WIDTH-1:0] chkr_rd_data;   // Internal register to latch data from memory

   pdp_mem_opcode_s chkr_pdp_mem_opcode; // Internal struct to drive outut to Execution unit
   pdp_op7_opcode_s chkr_pdp_op7_opcode; // Internal struct to drive outut to Execution unit

   
   task display_func
   end task
  
   always @(posedge clk)
	begin
		if (reset_n == LOW)				//IDLE STATE
			counter = 3'b000;
			chkr_base_addr = `START_ADDRESS;
			if (base_addr != chkr_base_addr)
				$display ("\n@ %0d ns ERROR: In IDLE STATE, \nthe base_addr signal is and chkr_base_addr is %h", $time, base_addr, chkr_base_addr);
			// Clear all internal registers and flags
            chkr_rd_req				= 0;
			chkr_rd_addr			= 0;
            chkr_rd_data			= 0;
            chkr_pdp_mem_opcode		= '{0,0,0,0,0,0,9'bz};
            chkr_pdp_op7_opcode		= '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
		else if (reset_n == HIGH)
			counter = counter+1;
	end
	
	always @(negedge clk)
	begin
		case (counter)
		3'b001:		begin					//READY STATE
						chkr_rd_addr	= chkr_base_addr		
					end
					
		3'b010:		begin					//SEND_REQ STATE
						chkr_pdp_mem_opcode = '{0,0,0,0,0,0,9'bz};
						chkr_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
						chkr_rd_req = 1;
						if (ifu_rd_req != chkr_rd_req)
							$display ("\n@ %0d ns ERROR: In SEND_REQ STATE, \nthe ifu_rd_req signal is and chkr_rd_req is %h", $time, ifu_rd_req, chkr_rd_req);
					end
					
		3'b011:		begin					//DATA_RCVD STATE
						chkr_rd_req = 0;
						if (ifu_rd_req != chkr_rd_req)
							$display ("\n@ %0d ns ERROR: In SEND_REQ STATE, \nthe ifu_rd_req signal is and chkr_rd_req is %h", $time, ifu_rd_req, chkr_rd_req);
						chkr_rd_data = ifu_rd_data;
					end
					
		3'b100:		begin					// INSTN_DEC STATE
						if (chkr_rd_data[`DATA_WIDTH-1:`DATA_WIDTH-3] < 6)
						begin
							case (chkr_rd_data[`DATA_WIDTH-1:`DATA_WIDTH-3])
								`AND:		chkr_pdp_mem_opcode	= '{1,0,0,0,0,0,chkr_rd_data[8:0]};
								`TAD:		chkr_pdp_mem_opcode	= '{0,1,0,0,0,0,chkr_rd_data[8:0]};
								`ISZ:		chkr_pdp_mem_opcode	= '{0,0,1,0,0,0,chkr_rd_data[8:0]};
								`DCA:		chkr_pdp_mem_opcode	= '{0,0,0,1,0,0,chkr_rd_data[8:0]};
								`JMS:		chkr_pdp_mem_opcode	= '{0,0,0,0,1,0,chkr_rd_data[8:0]};
								`JMP:		chkr_pdp_mem_opcode	= '{0,0,0,0,0,1,chkr_rd_data[8:0]};
								default:	chkr_pdp_mem_opcode	= '{0,0,0,0,0,0,9'bz};
							endcase
							if (pdp_mem_opcode != chkr_pdp_mem_opcode)
								$display ("\n@ %0d ns ERROR: In SEND_REQ STATE, \nthe pdp_mem_opcode signal is and chkr_pdp_mem_opcode is %h", $time, pdp_mem_opcode, chkr_pdp_mem_opcode);
						end
						else if (chkr_rd_data[`DATA_WIDTH-1:`DATA_WIDTH-3] == 7)
						begin
							case (chkr_rd_data)
								`NOP    : chkr_pdp_op7_opcode = '{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
								`IAC    : chkr_pdp_op7_opcode = '{0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
								`RAL    : chkr_pdp_op7_opcode = '{0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
								`RTL    : chkr_pdp_op7_opcode = '{0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
								`RAR    : chkr_pdp_op7_opcode = '{0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
								`RTR    : chkr_pdp_op7_opcode = '{0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
								`CML    : chkr_pdp_op7_opcode = '{0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
								`CMA    : chkr_pdp_op7_opcode = '{0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
								`CIA    : chkr_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0};
								`CLL    : chkr_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0};
								`CLA1   : chkr_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0};
								`CLA_CLL: chkr_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0};
								`HLT    : chkr_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0};
								`OSR    : chkr_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0};
								`SKP    : chkr_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0};
								`SNL    : chkr_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0};
								`SZL    : chkr_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0};
								`SZA    : chkr_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0};
								`SNA    : chkr_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0};
								`SMA    : chkr_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0};
								`SPA    : chkr_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0};
								`CLA2   : chkr_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1};
								default : chkr_pdp_op7_opcode = '{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}; //NOP
							endcase
							if (pdp_op7_opcode != chkr_pdp_op7_opcode)
								$display ("\n@ %0d ns ERROR: In SEND_REQ STATE, \nthe pdp_op7_opcode signal is and chkr_pdp_op7_opcode is %h", $time, pdp_op7_opcode, chkr_pdp_op7_opcode);
						end
						else
						begin
							chkr_pdp_mem_opcode = '{0,0,0,0,0,0,9'bz};
							chkr_pdp_op7_opcode = '{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}; // NOP
						end
					end
					
		3'b101:		begin					//STALL STATE
						if (stall == HIGH)
							counter = 3'b100;
						else
						begin
							chkr_rd_addr = PC_value;
							if (ifu_rd_addr != chkr_rd_addr)
								$display ("\n@ %0d ns ERROR: In STALL STATE, \nthe ifu_rd_addr signal is and chkr_rd_addr is %h", $time, ifu_rd_addr, chkr_rd_addr);
							if (PC_value != chkr_base_addr)
								counter = 3'b001;
						end
					end
					
		3'b110:		begin					//DONE STATE
						chkr_pdp_mem_opcode = '{0,0,0,0,0,0,9'bz};
						chkr_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
						if (~reset_n)
							counter = 3'b000;
						else
							counter = 3'b101;
					end
		endcase			
	end
endmodule
	

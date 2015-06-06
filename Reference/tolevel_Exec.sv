
`include "pdp8_pkg.sv"
import pdp8_pkg::*;

module unit_Exec_toplevel_TB();
  
  // Global inputs
   wire clk;
   wire reset_n;

   // From Execution unit
   wire stall;
   wire [`ADDR_WIDTH-1:0] PC_value;

   // To memory unit
   wire                    ifu_rd_req;
   wire  [`ADDR_WIDTH-1:0] ifu_rd_addr;

   // From memory unit
   wire [`DATA_WIDTH-1:0] ifu_rd_data;

   // To Execution unit (decode struct)
   wire [`ADDR_WIDTH-1:0] base_addr;
   pdp_mem_opcode_s pdp_mem_opcode;
   pdp_op7_opcode_s pdp_op7_opcode;

  wire                   exec_rd_req;
  wire  [`ADDR_WIDTH-1:0] exec_rd_addr;
  wire [`DATA_WIDTH-1:0] exec_rd_data;

  wire                    exec_wr_req;
  wire  [`ADDR_WIDTH-1:0] exec_wr_addr;
  wire  [`DATA_WIDTH-1:0] exec_wr_data;
   
bind instr_exec:Execution instr_exec_checker Check(
 .clk(clk),                              
 .reset_n(reset_n),                          
  .base_addr (base_addr),      
   .pdp_mem_opcode (pdp_mem_opcode),  
    .pdp_op7_opcode(pdp_op7_opcode), 
    .stall(stall),        
    .PC_value(PC_value),    
   .exec_wr_req (exec_wr_req),  
    .exec_wr_addr (exec_wr_addr), 
   .exec_wr_data(exec_wr_data), 
   .exec_rd_req (exec_rd_req), 
    .exec_rd_addr(exec_rd_addr),  
   .exec_rd_data( exec_rd_data), 
   .intAcc (intAcc), 
   .intLink(intLink),
   .current_state(current_state)
   );
   
bind instr_exec:Execution coverage_Exec cg(.clk(clk),.current_state(current_state));   // Functional Checker which access the internal signals to check functionality

clkgen_driver clockgenerator(.*);
Memory_STUB_Exec memorySTUB(.*);
instr_decode_STUB IFD_stub(.*);
instr_exec Execution(.*);
endmodule





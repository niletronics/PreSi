`include "pdp8_pkg.sv"
import pdp8_pkg::*;

module unit_IFDtoplevel_TB();
  
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
  
bind instr_decode:IFD coverage cg(.clk(clk),.current_state(current_state),.int_rd_data(int_rd_data) ,.pdp_mem_opcode(pdp_mem_opcode),.pdp_op7_opcode(pdp_op7_opcode));
clkgen_driver clockgenerator(.*);
Memory_STUB memory(.*);
instr_decode IFD(.*);
instr_exec_stub ExecSTUB(.*);
Unit_IFD_checker IFDchecker(.*);
Unit_IFD_Monitor IFDMonitor(.*);
assertion_ip_decoder Assertions(.*);
endmodule





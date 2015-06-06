`include "pdp8_pkg.sv"
import pdp8_pkg::*;
module Unit_IFD_Monitor(
  
  input clk,
   input reset_n,
  // From Execution unit
   input stall,
   input [`ADDR_WIDTH-1:0] PC_value,

   // To memory unit
   input                    ifu_rd_req,
   input  [`ADDR_WIDTH-1:0] ifu_rd_addr,
   // From memory unit
   input [`DATA_WIDTH-1:0] ifu_rd_data,

   // To Execution unit (decode struct)
   input [`ADDR_WIDTH-1:0] base_addr,
   input pdp_mem_opcode_s pdp_mem_opcode,
   input pdp_op7_opcode_s pdp_op7_opcode
  );
  reg  [`ADDR_WIDTH-1:0] int_ifu_rd_addr;
  reg  [`ADDR_WIDTH-1:0] int_PC_value;
  assign int_ifu_rd_addr = ifu_rd_addr;
  assign int_PC_value = PC_value;

  bit check_condtn3 ;

  
  
  
//Monitoring Signal protocols
  // read request followed by read adress
    
    //Read address match with PC_value 
        always @ (int_ifu_rd_addr) begin
        repeat(1) begin @(posedge clk) ; end
        if(int_PC_value !== int_ifu_rd_addr)begin
          $display(" Address sent by Program counter %o doesn't match with IFU unit read address to memory_pdp %o @ %0d ns ",int_PC_value,int_ifu_rd_addr,$time);end
        end
      
      
      
    endmodule
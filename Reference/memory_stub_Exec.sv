`include "pdp8_pkg.sv"
import pdp8_pkg::*;


module Memory_STUB_Exec (
  
  
  input                   exec_rd_req,
  input [`ADDR_WIDTH-1:0] exec_rd_addr,
  output [`DATA_WIDTH-1:0] exec_rd_data,

  input                  exec_wr_req,
  input  [`ADDR_WIDTH-1:0] exec_wr_addr,
  input [`DATA_WIDTH-1:0] exec_wr_data
);

  reg [`DATA_WIDTH-1:0] int_exec_rd_data;

  
  
   always_ff @(posedge exec_rd_req) begin
     
     if(exec_rd_req) begin
     //repeat(4096) begin  
int_exec_rd_data = ({$random} % 12'b111111111111);
$display(" generate_data: %o",exec_rd_data);
//end
end
end
assign  exec_rd_data = int_exec_rd_data;
endmodule

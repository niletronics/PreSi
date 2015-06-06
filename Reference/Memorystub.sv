import pdp8_pkg::*;
`include "pdp8_pkg.sv"
module Memory_STUB(
  
  input clk,
   // To memory unit
   input                    ifu_rd_req,
   input  [`ADDR_WIDTH-1:0] ifu_rd_addr,

   // From memory unit
   output [`DATA_WIDTH-1:0] ifu_rd_data);
   
   reg[`DATA_WIDTH-1:0] int_ifu_rd_data;
 
 
 
 
 
 
   always_ff @(posedge ifu_rd_req) begin
     
     if(ifu_rd_req) begin
     
int_ifu_rd_data = ({$random});
$display(" generate_data: %o",int_ifu_rd_data);

end
end
assign ifu_rd_data = int_ifu_rd_data;
endmodule
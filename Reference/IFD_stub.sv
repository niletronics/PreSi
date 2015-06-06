import pdp8_pkg::*;
`include "pdp8_pkg.sv"

module instr_decode_STUB(

input clk,
input reset_n,
   input stall,
   input [`ADDR_WIDTH-1:0] PC_value,

   output [`ADDR_WIDTH-1:0] base_addr,
   output pdp_mem_opcode_s pdp_mem_opcode,
   output pdp_op7_opcode_s pdp_op7_opcode
   
   );
  // reg [`ADDR_WIDTH-1:0] int_base_addr;
   pdp_mem_opcode_s int_pdp_mem_opcode;
   pdp_op7_opcode_s int_pdp_op7_opcode;
   reg  i;
   reg [2:0] gen_mem_opcode;
   reg [4:0] gen_op7_opcode;
   reg [`ADDR_WIDTH-1:0] int_base_addr;
   reg [`ADDR_WIDTH-1:0] int_PC_value ;
   
   assign  int_PC_value = PC_value ;
always @(posedge reset_n) begin
       
       int_base_addr = `START_ADDRESS;
       int_pdp_mem_opcode <= '{0,0,0,0,0,0,9'bz};
       int_pdp_op7_opcode <= '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

   end
   
     
     always@ ( PC_value && !stall ) begin
       i=({$random});
        gen_mem_opcode=({$random});
        gen_op7_opcode=({$random});
        
      if (int_PC_value == `START_ADDRESS) begin
        repeat (4) begin @(posedge clk);end
         int_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0};
              end
    
else  begin           
          
        int_pdp_mem_opcode <= '{0,0,0,0,0,0,9'bz};
        int_pdp_op7_opcode <= '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
        repeat (3) begin @(posedge clk);end
        
       if(i==1)begin
         $display( "randomization between mem and Op7  : %d",i);
         int_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
         case (gen_mem_opcode) 
            0 : int_pdp_mem_opcode = '{1,0,0,0,0,0,({$random} % 9'hff)};
            1 : int_pdp_mem_opcode = '{0,1,0,0,0,0,({$random} % 9'hff)};
            2 : int_pdp_mem_opcode = '{0,0,1,0,0,0,({$random} % 9'hff)};
            3 : int_pdp_mem_opcode = '{0,0,0,1,0,0,({$random} % 9'hff)};
            4 : int_pdp_mem_opcode = '{0,0,0,0,1,0,({$random} % 9'hff)};
            5 : int_pdp_mem_opcode = '{0,0,0,0,0,1,({$random} % 9'hff)};
            6 : int_pdp_mem_opcode =  '{0,1,0,0,0,0,({$random} % 9'hff)};
            7 : int_pdp_mem_opcode = '{0,0,1,0,0,0,({$random} % 9'hff)};
         endcase
         $display(" generated mem opcode  : %d",gen_mem_opcode);
       end
     else begin
          int_pdp_mem_opcode = '{0,0,0,0,0,0, 9'bz};
        $display( "randomization between mem and Op7  : %d",i);
       case(gen_op7_opcode)
         0:int_pdp_op7_opcode = '{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
         1:int_pdp_op7_opcode = '{0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
         2:int_pdp_op7_opcode = '{0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
         3:int_pdp_op7_opcode = '{0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
         4:int_pdp_op7_opcode = '{0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
         5:int_pdp_op7_opcode = '{0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
         6:int_pdp_op7_opcode = '{0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
         7:int_pdp_op7_opcode = '{0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
         8:int_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0};
         9:int_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0};
        10:int_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0};
        11:int_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0};
        12:int_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0};
        13:int_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0};
        14:int_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0};
        15:int_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0};
        16:int_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0};
        17:int_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0};
        18:int_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0};
        19:int_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0};
        20:int_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0};
        21:int_pdp_op7_opcode = '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1};
 default : int_pdp_op7_opcode = '{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
     endcase
     $display(" generated Op7 opcode  : %d",gen_op7_opcode);
   end
 end
 end

 
 
 
 
assign base_addr = int_base_addr;
assign pdp_mem_opcode = int_pdp_mem_opcode;
assign pdp_op7_opcode = int_pdp_op7_opcode;
endmodule
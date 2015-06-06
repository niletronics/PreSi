`include "pdp8_pkg.sv"
import pdp8_pkg::*;

module assertion_ip_decoder (
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
  reg a1,a2,a3,a4,a5,a6,a7,a8,a9;
  reg [`ADDR_WIDTH-1:0] int_base_addr;
  reg                 int_ifu_rd_req;
  reg [`ADDR_WIDTH-1:0] int_ifu_rd_addr;
   // From memory unit
  reg [`DATA_WIDTH-1:0] int_ifu_rd_data;
  reg  [`ADDR_WIDTH-1:0] int_PC_value;
   // To Execution unit (decode struct)
    pdp_mem_opcode_s int_pdp_mem_opcode;
    pdp_op7_opcode_s int_pdp_op7_opcode;
  
  assign int_base_addr = base_addr;
  assign int_ifu_rd_req = ifu_rd_req;
  assign int_ifu_rd_addr = ifu_rd_addr;
  assign int_ifu_rd_data = ifu_rd_data;
  assign int_pdp_mem_opcode = pdp_mem_opcode ;
  assign int_pdp_op7_opcode = pdp_op7_opcode;
  assign int_PC_value = PC_value;
  
  //Latch ADDRESS assertions
  
  
  
  always @(posedge reset_n) begin
    repeat(1) @(posedge clk) begin
      
      if( int_base_addr == `START_ADDRESS) begin
        a1=0;//$display("@%0dns Latch_Address assertion passed",$time);end
      end
      else begin
        a1=1;//$display ("@%0dns Latch_Address assertion  failed",$time);end
        end
      end
        printassertionchecks();
      end
  
//INITIALIZATION of outputs
  always @(posedge reset_n) begin
    repeat(1) @(posedge clk ) begin
      
    if( (int_ifu_rd_req == 0) && (int_ifu_rd_addr == 0) && (int_pdp_mem_opcode === '{0,0,0,0,0,0,9'bz}) && (int_pdp_op7_opcode == '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}))begin
      a2=0;//$display("@%0dns Initialization of OUTPUTS: assertion passed",$time);end
    end
    else begin
     a2=1;//$display("@%0dns Initialization of OUTPUTS: assertion failed",$time);end
   end
   end 
   printassertionchecks();
 end
 
 //after reset_n is asserted read address to memory should be START ADDRESS or base ADDRESS WITHIN TWO CLOCK CYCLES
 
 always @(posedge reset_n) begin
   repeat(2) @(posedge clk) begin
     if( int_ifu_rd_addr == `START_ADDRESS) begin
    a3=0; // $display(" @%0dns START_ADDRESS is latched to read_address signal to memory at start of fetching: assertion passed",$time);end
  end
   else begin
    a3=1;// $display(" @%0dns START_ADDRESS is latched to read_address signal to memory at start of fetching: assertion failed",$time);end
  end
  end
  printassertionchecks();
 end
 
 //read request should be asserted high for minimum one clock cycle
 
 always @ (posedge int_ifu_rd_req) begin
   repeat(1) @(posedge clk) begin
     if ( int_ifu_rd_req ==0) begin
       $display("@%0dns Read Request duration :Assertion failed",$time);end
     end
     printassertionchecks();
   end
   
   //After read request asserted to memory read data from memory should be valid 
   
   always @(posedge int_ifu_rd_req) begin
   repeat(1) @(posedge clk or negedge clk) begin
     if ( int_ifu_rd_data === 12'bz || int_ifu_rd_data === 12'bx) begin
      a4=1; //$display("@%0dns read request is asserted to memory read data from memory is valid:assertion passed",$time);end
    end
     else begin
      a4=0;// $display("@%0dns read request is asserted to memory read data from memory is valid:assertion fail",$time);end
    end
     end
     printassertionchecks();
   end


  
// decode should be done within 1 clock cycle after data is latched
  always@(PC_value) begin
    if(int_PC_value == int_base_addr) begin
      if( (int_pdp_mem_opcode !== '{0,0,0,0,0,0,9'bz}) &&
                   (int_pdp_op7_opcode !== '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}))begin
          $display("@%0dns MEMOPCODES & OP7OPCODES Initialized after PC_value matched base address: assert failed",$time);end    
end
end


task printassertionchecks;
  begin
    if (a1) $display ("@%0dns Latch_Address assertion  failed",$time);
      if(a2) $display("@%0dns Initialization of OUTPUTS: assertion failed",$time);
        if(a3) $display(" @%0dns START_ADDRESS is latched to read_address signal to memory at start of fetching: assertion failed",$time);
          if(a4) $display("@%0dns read request is asserted to memory read data from memory is valid:assertion fail",$time);
          if(a5) $display("@%0dns read address is latched to the pgm counter for low stall: assertion failed",$time);  
          end
        endtask
  endmodule
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
  
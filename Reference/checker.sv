import pdp8_pkg::*;
`include "pdp8_pkg.sv"


 module Unit_IFD_checker(
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
  
  
  
  
// BASIC FUNCTIONALITY CHECK OF THE DECODE UNIT 
  always @ (ifu_rd_data) begin
    
    case( ifu_rd_data[11:9] )
      3'b000:begin
           if(ifu_rd_req)begin
           repeat (3) begin @ (posedge clk); end 
       if(pdp_mem_opcode != '{1,0,0,0,0,0,ifu_rd_data[8:0]})begin
         $display(" Error in Decode oF AND Instruction checker %b  DUT %b readrequest ",ifu_rd_data,pdp_mem_opcode.mem_inst_addr );end
      end
    end
      3'b001: begin
      
       if(ifu_rd_req)begin
           repeat (3) begin @ (posedge clk); end 
      if(pdp_mem_opcode != '{0,1,0,0,0,0,ifu_rd_data[8:0]}) begin
        $display ("opcode value :%b ",ifu_rd_data[11:9]);
          $display(" Error in Decode oF TAD checker %b  DUT %b @ %0d ns",ifu_rd_data,pdp_mem_opcode.mem_inst_addr,$time );end
      end
    end
      3'b010:if(ifu_rd_req)begin
           repeat (3) begin @ (posedge clk); end 
          if(pdp_mem_opcode != '{0,0,1,0,0,0,ifu_rd_data[8:0]}) begin
          $display(" Error in Decode oF ISZ checker %b  DUT %b ",ifu_rd_data,pdp_mem_opcode.mem_inst_addr );end
      end
      3'b011:
         if(ifu_rd_req)begin
           repeat (3) begin @ (posedge clk); end 
       if(pdp_mem_opcode != '{0,0,0,1,0,0,ifu_rd_data[8:0]}) begin
          $display(" Error in Decode oF DCA checker %b  DUT %b  @ %0d ns ",ifu_rd_data,pdp_mem_opcode.mem_inst_addr,$time );end
        end
       3'b100: if(ifu_rd_req)begin
           repeat (3) begin @ (posedge clk); end 
       if(pdp_mem_opcode != '{0,0,0,0,1,0,ifu_rd_data[8:0]}) begin
          $display(" Error in Decode oF JMS checker %b  DUT %b ",ifu_rd_data,pdp_mem_opcode.mem_inst_addr );end  
     end
       3'b101:if(ifu_rd_req)begin
           repeat (3) begin @ (posedge clk); end 
       if(pdp_mem_opcode != '{0,0,0,0,0,1,ifu_rd_data[8:0]}) begin
          $display(" Error in Decode oF JMP checker %b  DUT %b ",ifu_rd_data,pdp_mem_opcode.mem_inst_addr );end
        end      
       3'b111:begin
          if(ifu_rd_req)begin
           repeat (3) begin @ (posedge clk); end 
          case(ifu_rd_data)
            12'o7000 :
             if(pdp_op7_opcode != '{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})begin
                $display("Error in deocde of NOP opcode");end
              
             12'o7001:
             if(pdp_op7_opcode != '{0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})begin
                $display("Error in deocde of IAC opcode");end
                
             12'o7004:
             if(pdp_op7_opcode != '{0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})begin
                $display("Error in deocde of RAL opcode");end
                
             12'o7006:
             if(pdp_op7_opcode != '{0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})begin
                $display("Error in deocde of RTL opcode");end
             
             12'o7010:
             if(pdp_op7_opcode != '{0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})begin
                $display("Error in deocde of RAR opcode");end
             
             12'o7012:
             if(pdp_op7_opcode != '{0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})begin
                $display("Error in deocde of RTR opcode");end
                
             12'o7020:
             if(pdp_op7_opcode != '{0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})begin
                $display("Error in deocde of CML opcode");end
                
             12'o7040: 
             if(pdp_op7_opcode != '{0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0})begin
                $display("Error in deocde of CMA opcode");end
                
             12'o7041: 
             if(pdp_op7_opcode != '{0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0})begin
                $display("Error in deocde of CIA opcode");end
                
             12'o7100: 
             if(pdp_op7_opcode != '{0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0})begin
                $display("Error in deocde of CLL opcode");end
            
             12'o7200: 
             if(pdp_op7_opcode != '{0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0})begin
                $display("Error in deocde of CLA1 opcode");end
              
             12'o7300: 
             if(pdp_op7_opcode != '{0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0})begin
                $display("Error in deocde of CLA_CLL opcode");end          
             
             12'o7402: 
             if(pdp_op7_opcode != '{0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0})begin
                $display("Error in deocde of HLT opcode");end
             
             12'o7404: 
             if(pdp_op7_opcode != '{0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0})begin
                $display("Error in deocde of OSR opcode");end
             
             12'o7410: 
             if(pdp_op7_opcode != '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0})begin
                $display("Error in deocde of SKP opcode");end
                
              12'o7420: 
             if(pdp_op7_opcode != '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0})begin
                $display("Error in deocde of SNL opcode");end
                
              12'o7430: 
             if(pdp_op7_opcode != '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0})begin
                $display("Error in deocde of SZL opcode");end
                
              12'o7440: 
             if(pdp_op7_opcode != '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0})begin
                $display("Error in deocde of SZA opcode");end 
                           
              12'o7450: 
             if(pdp_op7_opcode != '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0})begin
                $display("Error in deocde of SNA opcode");end 
                
              12'o7500: 
             if(pdp_op7_opcode != '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0})begin
                $display("Error in deocde of SMA opcode");end 
             
              12'o7510: 
             if(pdp_op7_opcode != '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0})begin
                $display("Error in deocde of SPA opcode");end 
             
              12'o7600: 
             if(pdp_op7_opcode != '{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1})begin
                $display("Error in deocde of CLA2 opcode");end 
              endcase//ending case of op7 opcodes
            end
            end   
            default: begin
            end
endcase
      end  
      
      
      
      
    //ASSERTIONS IP 
    
    endmodule
           
       

`include "pdp8_pkg.sv"
import pdp8_pkg::*;

//state current_state;

module coverage(
  input clk,
  state current_state,
  input [`DATA_WIDTH-1:0] int_rd_data,
  input pdp_mem_opcode_s pdp_mem_opcode,
   input pdp_op7_opcode_s pdp_op7_opcode
  );
   



covergroup coveragefsmanddata @ (posedge clk);
 type_option.merge_instances =0;
 option.per_instance =1;
  option.get_inst_coverage =1;
    //Readdata_IFD: coverpoint int_rd_data;
    FSM_state : coverpoint current_state;
    //MemOpcode_out: coverpoint pdp_mem_opcode;
    //OP7Opcode_out: coverpoint pdp_op7_opcode;
    endgroup
  
  coveragefsmanddata cg = new();

endmodule
  
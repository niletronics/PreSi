

`include "pdp8_pkg.sv"
import pdp8_pkg::*;

//state current_state;

module coverage_Exec(
  input clk,
  state current_state);
   



covergroup coveragefsm @ (posedge clk);
//  type_option.merge_instances =0;
 // option.per_instance =1;
  option.get_inst_coverage =1;
    //Readdata_IFD: coverpoint int_rd_data;
    FSM_state : coverpoint current_state;
    endgroup
  
  coveragefsm cg = new();

endmodule
  
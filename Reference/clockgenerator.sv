// =======================================================================
//   Department of Electrical and Computer Engineering
//   Portland State Unversity
//
//   Course name:  ECE 510 - Pre-Silicon Validation
//   Term & Year:  Spring 2014
//   Instructor :  Tareque Ahmad
//
//   Project:      Hardware implementation of PDP8 
//                 Instruction Set Architecture (ISA) level simulator
//
//   Filename:     clkgen_driver.sv
//   Description:  TBD
//   Created by:   Tareque Ahmad
//   Date:         May 03, 2014
//
//   Copyright:    Tareque Ahmad 
// =======================================================================

// Import the package
import pdp8_pkg::*;
`include "pdp8_pkg.sv"
// Define module
module clkgen_driver
  (
   output clk,
   output reset_n
   );

   // Define parameters
   parameter CLOCK_PERIOD = 10;
   parameter RESET_DURATION = 500;
   parameter RUN_TIME = 500000;

   // Define internal registers
   reg int_clk;
   reg int_reset_n;

   // Generate fixed frequency internal clock
   initial begin
      int_clk = 0;
      forever #(CLOCK_PERIOD/2) int_clk = ~int_clk;
   end

   // Generate one-time internal reset signal
   initial begin
      int_reset_n = 0;
      # RESET_DURATION int_reset_n = 1;
      # RUN_TIME
      $finish;
   end

   // Continuous assignment to output
   assign clk     = int_clk;
   assign reset_n = int_reset_n;

endmodule



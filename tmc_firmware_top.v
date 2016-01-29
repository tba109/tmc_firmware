//////////////////////////////////////////////////////////////////////////////////////
// Tyler Anderson Fri Jan 29 16:25:26 EST 2016
// tmc_firwmare_top.v
//
// Top-level Verilog HDL module for the Temperature Measurement and Control (TMC)
// electronics.
//
// Major modules:
//
// version_number: "Version Number"
//                 A custom Verilog HDL module which contains a verison number
//                 for the project. It is automatically updated with each compile.
//
// config_ind: Configuration indicator to say when the FPGA is configured. It just
//             flashes and LED
////////////////////////////////////////////////////////////////////////////////////   

`timescale 1ns / 100ps

module tmc_firmware_top
  (
   input R_CLK, // pin 27
   output LED1 // pin 132
   );

   // Configuraiton indicator
   config_ind CONFIG_IND0(.clk(R_CLK),.rst_n(1'b1),.blink_configed(LED1));
   
endmodule

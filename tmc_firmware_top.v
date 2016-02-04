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
   input  R_CLK, // pin 27
	  
   // The A temp board
   input  live_a, // pin 60
   input  miso_a, // pin 59
   output mosi_a, // pin 56
   output sclk_a, // pin 55
   output csan_a, // pin 47
   output csbn_a, // pin 46
   output cscn_a, // pin 43

   // The B temp board
   input  live_b, // pin 58
   input  miso_b, // pin 57
   output mosi_b, // pin 52
   output sclk_b, // pin 50
   output csan_b, // pin 45
   output csbn_b, // pin 44
   output cscn_b, // pin 39

   // The C temp board
   input  live_c, // pin 88
   input  miso_c, // pin 89
   output mosi_c, // pin 92
   output sclk_c, // pin 93
   output csan_c, // pin 99
   output csbn_c, // pin 101
   output cscn_c, // pin 105 
   
   // The D temp board
   input  live_d, // pin 90
   input  miso_d, // pin 91
   output mosi_d, // pin 96
   output sclk_d, // pin 98
   output csan_d, // pin 100
   output csbn_d, // pin 102
   output cscn_d, // pin 118

   // Serial port
   // Thu Feb  4 15:53:35 EST 2016
   // Ugh! Got me again. TXD in the FT2232 datasheet is the RXD of this board, and
   // vice versa. Here's the correct mapping:
   // RXD on FT232 is 81, so that's TXD
   // TXD on FT232 is 84, so that's RXD
   // CTS# on FT232 is 86, so that's RTS#
   // RTS# on FT232 is 79, so that's CTS#
   input  rxd, // pin 84
   output txd, // pin 81
   output rts_n, // pin 86
   input  cts_n, // pin 79
   
   output LED2, // pin 134
   output LED1  // pin 132
  
   );

   // The PLL
   wire   logic_clk;
   wire   logic_clk_rst_n;
   tmc_pll TMC_PLL0 
     (
      .areset(1'b0),
      .inclk0(R_CLK),
      .c0(logic_clk),
      .locked(logic_clk_rst_n)
      );
	   
   // Configuraiton indicator
   config_ind CONFIG_IND0(.clk(logic_clk),.rst_n(logic_clk_rst_n),.blink_configed(LED1));

   // The processor (most everything is in here)
   wire        qsys_miso;
   wire        qsys_mosi;
   wire        qsys_sclk;
   wire [11:0] qsys_csn;
   wire [7:0]  pio_in;
   wire [7:0]  pio_out;

   assign LED2 = pio_out[0];

   tmc_nios2 u0 (
		 .clk_clk(logic_clk), 
		 .reset_reset_n(logic_clk_rst_n),
		 .spi_0_external_MISO(qsys_miso),
		 .spi_0_external_MOSI(qsys_mosi),
		 .spi_0_external_SCLK(qsys_sclk),
		 .spi_0_external_SS_n(qsys_csn),
		 .uart_0_external_connection_rxd(rxd),
		 .uart_0_external_connection_txd(txd),
		 .uart_0_external_connection_cts_n(cts_n),
		 .uart_0_external_connection_rts_n(rts_n),
		 .pio_1_external_connection_export(pio_out),
		 .pio_0_external_connection_export(pio_in)
		 );

   
endmodule

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
   reg         qsys_miso;
   wire        qsys_mosi;
   wire        qsys_sclk;
   wire [11:0] qsys_csn;
   wire [7:0]  pio_in;
   wire [7:0]  pio_out;
   wire [7:0]  rx_fifo_data_in;
   wire        rx_fifo_wr_en;
   wire        rx_fifo_full;
   wire [7:0]  rx_fifo_data_out;
   wire        rx_fifo_rd_en;
   wire        rx_fifo_rd_en_p;
   wire        rx_fifo_empty;
   
   // Troubleshooting assignments
   assign LED2 = pio_out[7];

   // Temperature readout board A
   assign pio_in[0] = live_a;
   assign mosi_a = pio_out[0] ? qsys_mosi    : 1'bz;
   assign sclk_a = pio_out[0] ? qsys_sclk    : 1'bz;
   assign csan_a = pio_out[0] ? qsys_csn[0]  : 1'bz;
   assign csbn_a = pio_out[0] ? qsys_csn[1]  : 1'bz;
   assign cscn_a = pio_out[0] ? qsys_csn[2]  : 1'bz;
   
   // Temperature readout board B
   assign pio_in[1] = live_b;
   assign mosi_b = pio_out[1] ? qsys_mosi    : 1'bz;
   assign sclk_b = pio_out[1] ? qsys_sclk    : 1'bz;
   assign csan_b = pio_out[1] ? qsys_csn[3]  : 1'bz;
   assign csbn_b = pio_out[1] ? qsys_csn[4]  : 1'bz;
   assign cscn_b = pio_out[1] ? qsys_csn[5]  : 1'bz;
   
   // Temperature readout board C
   assign pio_in[2] = live_c;
   assign mosi_c = pio_out[2] ? qsys_mosi    : 1'bz;
   assign sclk_c = pio_out[2] ? qsys_sclk    : 1'bz;
   assign csan_c = pio_out[2] ? qsys_csn[6]  : 1'bz;
   assign csbn_c = pio_out[2] ? qsys_csn[7]  : 1'bz;
   assign cscn_c = pio_out[2] ? qsys_csn[8]  : 1'bz;
   
   // Temperature readout board D
   assign pio_in[3] = live_d;
   assign mosi_d = pio_out[3] ? qsys_mosi    : 1'bz;
   assign sclk_d = pio_out[3] ? qsys_sclk    : 1'bz;
   assign csan_d = pio_out[3] ? qsys_csn[9]  : 1'bz;
   assign csbn_d = pio_out[3] ? qsys_csn[10] : 1'bz;
   assign cscn_d = pio_out[3] ? qsys_csn[11] : 1'bz;
   
   // MISO input is shared between all boards. De-mux as follows:
   always@(*)
     case(qsys_csn)
       ~12'h001: qsys_miso <= miso_a;
       ~12'h002: qsys_miso <= miso_a;
       ~12'h004: qsys_miso <= miso_a;
       ~12'h008: qsys_miso <= miso_b;
       ~12'h010: qsys_miso <= miso_b;
       ~12'h020: qsys_miso <= miso_b;
       ~12'h040: qsys_miso <= miso_c;
       ~12'h080: qsys_miso <= miso_c;
       ~12'h100: qsys_miso <= miso_c;
       ~12'h200: qsys_miso <= miso_d;
       ~12'h400: qsys_miso <= miso_d;
       ~12'h800: qsys_miso <= miso_d;
       default:  qsys_miso <= 1'b0;
     endcase
   
   tmc_nios2 u0 (
		 .clk_clk(logic_clk), 
		 .reset_reset_n(logic_clk_rst_n),
		 .spi_0_external_MISO(qsys_miso),
		 .spi_0_external_MOSI(qsys_mosi),
		 .spi_0_external_SCLK(qsys_sclk),
		 .spi_0_external_SS_n(qsys_csn),
		 // .uart_0_external_connection_rxd(rxd), // handle receiving as a separate FIFO
		 .uart_0_external_connection_rxd(),
		 .uart_0_external_connection_txd(txd),
		 .uart_0_external_connection_cts_n(cts_n),
		 // .uart_0_external_connection_rts_n(rts_n), // handle receiving as a seaprate FIFO
		 .uart_0_external_connection_rts_n(),
		 .pio_1_external_connection_export(pio_out),
		 .pio_0_external_connection_export(pio_in),
		 .rx_fifo_read_external_connection_export(rx_fifo_rd_en),
		 .rx_char_external_connection_export(rx_fifo_data_out),
		 .rx_fifo_empty_external_connection_export(rx_fifo_empty)
		 );
   
   // Fri Feb 26 13:36:10 EST 2016
   // This is the RS232 receive logic with deep FIFO (the QSYS one wasn't deep enough and
   // we were overflowing)
   // Deserializer
   defparam RS232_DES0.P_CLK_FREQ_HZ = 50000000;
   defparam RS232_DES0.P_BAUD_RATE = 115200;
   rs232_des RS232_DES0
     (
      .clk(logic_clk),
      .rst_n(logic_clk_rst_n),
      .rx(rx),
      .rx_fifo_data(rx_fifo_data_in),
      .rx_fifo_wr_en(rx_fifo_wr_en),
      .rx_fifo_full(rx_fifo_full)
      );
   
   posedge_detector PEDGE_0
     (
      .clk(logic_clk),
      .rst_n(logic_clk_rst_n),
      .a(rx_fifo_rd_en),
      .y(rx_fifo_rd_en_p)
      );
   
   fifo_1024_8 FIFO_1024_8_0
     (
      .clock(logic_clk),
      .data(rx_fifo_data_in),
      .rdreq(rx_fifo_rd_en),
      .wrreq(rx_fifo_wr_en),
      .empty(rx_fifo_empty),
      .full(rx_fifo_full),
      .q(rx_fifo_data_out)
      );
   
endmodule

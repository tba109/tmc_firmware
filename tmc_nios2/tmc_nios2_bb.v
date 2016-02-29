
module tmc_nios2 (
	clk_clk,
	pio_0_external_connection_export,
	pio_1_external_connection_export,
	reset_reset_n,
	rx_char_external_connection_export,
	rx_fifo_empty_external_connection_export,
	rx_fifo_read_external_connection_export,
	spi_0_external_MISO,
	spi_0_external_MOSI,
	spi_0_external_SCLK,
	spi_0_external_SS_n,
	uart_0_external_connection_rxd,
	uart_0_external_connection_txd,
	uart_0_external_connection_cts_n,
	uart_0_external_connection_rts_n,
	i2c_opencores_0_export_scl_pad_io,
	i2c_opencores_0_export_sda_pad_io);	

	input		clk_clk;
	input	[7:0]	pio_0_external_connection_export;
	output	[7:0]	pio_1_external_connection_export;
	input		reset_reset_n;
	input	[7:0]	rx_char_external_connection_export;
	input		rx_fifo_empty_external_connection_export;
	output		rx_fifo_read_external_connection_export;
	input		spi_0_external_MISO;
	output		spi_0_external_MOSI;
	output		spi_0_external_SCLK;
	output	[11:0]	spi_0_external_SS_n;
	input		uart_0_external_connection_rxd;
	output		uart_0_external_connection_txd;
	input		uart_0_external_connection_cts_n;
	output		uart_0_external_connection_rts_n;
	inout		i2c_opencores_0_export_scl_pad_io;
	inout		i2c_opencores_0_export_sda_pad_io;
endmodule

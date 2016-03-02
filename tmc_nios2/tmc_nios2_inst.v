	tmc_nios2 u0 (
		.clk_clk                                  (<connected-to-clk_clk>),                                  //                               clk.clk
		.i2c_opencores_0_export_scl_pad_io        (<connected-to-i2c_opencores_0_export_scl_pad_io>),        //            i2c_opencores_0_export.scl_pad_io
		.i2c_opencores_0_export_sda_pad_io        (<connected-to-i2c_opencores_0_export_sda_pad_io>),        //                                  .sda_pad_io
		.pio_0_external_connection_export         (<connected-to-pio_0_external_connection_export>),         //         pio_0_external_connection.export
		.pio_1_external_connection_export         (<connected-to-pio_1_external_connection_export>),         //         pio_1_external_connection.export
		.reset_reset_n                            (<connected-to-reset_reset_n>),                            //                             reset.reset_n
		.rx_char_external_connection_export       (<connected-to-rx_char_external_connection_export>),       //       rx_char_external_connection.export
		.rx_fifo_empty_external_connection_export (<connected-to-rx_fifo_empty_external_connection_export>), // rx_fifo_empty_external_connection.export
		.rx_fifo_read_external_connection_export  (<connected-to-rx_fifo_read_external_connection_export>),  //  rx_fifo_read_external_connection.export
		.spi_0_external_MISO                      (<connected-to-spi_0_external_MISO>),                      //                    spi_0_external.MISO
		.spi_0_external_MOSI                      (<connected-to-spi_0_external_MOSI>),                      //                                  .MOSI
		.spi_0_external_SCLK                      (<connected-to-spi_0_external_SCLK>),                      //                                  .SCLK
		.spi_0_external_SS_n                      (<connected-to-spi_0_external_SS_n>),                      //                                  .SS_n
		.uart_0_external_connection_rxd           (<connected-to-uart_0_external_connection_rxd>),           //        uart_0_external_connection.rxd
		.uart_0_external_connection_txd           (<connected-to-uart_0_external_connection_txd>),           //                                  .txd
		.uart_0_external_connection_cts_n         (<connected-to-uart_0_external_connection_cts_n>),         //                                  .cts_n
		.uart_0_external_connection_rts_n         (<connected-to-uart_0_external_connection_rts_n>)          //                                  .rts_n
	);


	component tmc_nios2 is
		port (
			clk_clk                                  : in    std_logic                     := 'X';             -- clk
			i2c_opencores_0_export_scl_pad_io        : inout std_logic                     := 'X';             -- scl_pad_io
			i2c_opencores_0_export_sda_pad_io        : inout std_logic                     := 'X';             -- sda_pad_io
			pio_0_external_connection_export         : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- export
			pio_1_external_connection_export         : out   std_logic_vector(7 downto 0);                     -- export
			reset_reset_n                            : in    std_logic                     := 'X';             -- reset_n
			rx_char_external_connection_export       : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- export
			rx_fifo_empty_external_connection_export : in    std_logic                     := 'X';             -- export
			rx_fifo_read_external_connection_export  : out   std_logic;                                        -- export
			spi_0_external_MISO                      : in    std_logic                     := 'X';             -- MISO
			spi_0_external_MOSI                      : out   std_logic;                                        -- MOSI
			spi_0_external_SCLK                      : out   std_logic;                                        -- SCLK
			spi_0_external_SS_n                      : out   std_logic_vector(11 downto 0);                    -- SS_n
			uart_0_external_connection_rxd           : in    std_logic                     := 'X';             -- rxd
			uart_0_external_connection_txd           : out   std_logic;                                        -- txd
			uart_0_external_connection_cts_n         : in    std_logic                     := 'X';             -- cts_n
			uart_0_external_connection_rts_n         : out   std_logic                                         -- rts_n
		);
	end component tmc_nios2;

	u0 : component tmc_nios2
		port map (
			clk_clk                                  => CONNECTED_TO_clk_clk,                                  --                               clk.clk
			i2c_opencores_0_export_scl_pad_io        => CONNECTED_TO_i2c_opencores_0_export_scl_pad_io,        --            i2c_opencores_0_export.scl_pad_io
			i2c_opencores_0_export_sda_pad_io        => CONNECTED_TO_i2c_opencores_0_export_sda_pad_io,        --                                  .sda_pad_io
			pio_0_external_connection_export         => CONNECTED_TO_pio_0_external_connection_export,         --         pio_0_external_connection.export
			pio_1_external_connection_export         => CONNECTED_TO_pio_1_external_connection_export,         --         pio_1_external_connection.export
			reset_reset_n                            => CONNECTED_TO_reset_reset_n,                            --                             reset.reset_n
			rx_char_external_connection_export       => CONNECTED_TO_rx_char_external_connection_export,       --       rx_char_external_connection.export
			rx_fifo_empty_external_connection_export => CONNECTED_TO_rx_fifo_empty_external_connection_export, -- rx_fifo_empty_external_connection.export
			rx_fifo_read_external_connection_export  => CONNECTED_TO_rx_fifo_read_external_connection_export,  --  rx_fifo_read_external_connection.export
			spi_0_external_MISO                      => CONNECTED_TO_spi_0_external_MISO,                      --                    spi_0_external.MISO
			spi_0_external_MOSI                      => CONNECTED_TO_spi_0_external_MOSI,                      --                                  .MOSI
			spi_0_external_SCLK                      => CONNECTED_TO_spi_0_external_SCLK,                      --                                  .SCLK
			spi_0_external_SS_n                      => CONNECTED_TO_spi_0_external_SS_n,                      --                                  .SS_n
			uart_0_external_connection_rxd           => CONNECTED_TO_uart_0_external_connection_rxd,           --        uart_0_external_connection.rxd
			uart_0_external_connection_txd           => CONNECTED_TO_uart_0_external_connection_txd,           --                                  .txd
			uart_0_external_connection_cts_n         => CONNECTED_TO_uart_0_external_connection_cts_n,         --                                  .cts_n
			uart_0_external_connection_rts_n         => CONNECTED_TO_uart_0_external_connection_rts_n          --                                  .rts_n
		);


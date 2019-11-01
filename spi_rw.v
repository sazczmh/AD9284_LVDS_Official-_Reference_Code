`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Analog Devices Inc.
// Engineer: Michael Sink
// 
// Create Date:    17:27:52 02/08/2008 
// Design Name: 
// Module Name:    FIFO5_TX_NCO 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spi_rw
(
	//			------- SPI inputs -------
	//
	input I_sclk,						// Serial data clock
	input _I_csb,						// Chip select - active low
	input I_sdi,						// Serial data input
	//
	//			------- SPI outputs -------
	//
	output O_sdo,					// Serial data output
	output [7:0] O_reg3			// Registered output
	//
);

localparam integer SPI_ADDR_SIZE = 8;		// Size of SPI address
localparam integer SPI_DATA_SIZE = 8;		// Size of SPI data

wire [SPI_ADDR_SIZE - 1:0] spi_addr;		// Deserialized SPI address
wire [SPI_DATA_SIZE - 1:0] spi_din;			// Deserialized SPI input data
wire [SPI_DATA_SIZE - 1:0] spi_dout;		// Deserialized SPI output data

wire spi_sdo;			// SPI serial data output
wire spi_wen;			// SPI register write enable

// Instantiate tri-state output buffer for SDO.
OBUFT OBUFT_sdo
(
	.O(O_sdo),		// Buffer output (connect directly to top-level port)
	.I(spi_sdo), 	// Buffer input
	.T(_I_csb) 		// 3-state enable input
);

// Instantiate SPI port.
spi_port #
(
	.ADDR_SIZE(SPI_ADDR_SIZE)		// Address size ([1, 13] for current standard)
)
spi_port
(
	.I_sclk(I_sclk),					// Serial data clock
	._I_csb(_I_csb),					// Active low chip select
	.I_sdi(I_sdi),						// Serial data input
	.I_dout(spi_dout),				// Parallel data output (input to be encoded into O_sdo)
	.O_sdo(spi_sdo),					// Serial data output
	.O_wen(spi_wen),					// Write enable for parallel data input
	.O_addr(spi_addr),				// Decoded address
	.O_din(spi_din)					// Parallel data input (output decoded from I_sdi)
);

// Instantiate FPGA programming registers.
fpga_reg fpga_reg
(
	.I_clk(I_sclk),					// Master clock
	.I_enable(!_I_csb),				// Enable for memory access
	.I_wen(spi_wen),					// Register write enable
	.I_addr(spi_addr),				// Input read/write address
	.I_din(spi_din),					// Input data
	.O_dout(spi_dout),				// Output data
	.O_reg3(O_reg3)					// Registered output data
);

endmodule

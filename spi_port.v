`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Analog Devices Inc.
// Engineer: Michael Sink
// 
// Create Date:    17:54:34 06/05/2007 
// Design Name: 
// Module Name:    spi_port 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: This module implements a SPI port for use with ADI HSC SPI protocol.
// This version supports only 16-bit instruction phase, MSB transfers.
//
// Dependencies: spi_control.v, spi_decoder.v, spi_encoder.v
//
// Revision: 1.00
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spi_port #
(
	parameter integer ADDR_SIZE = 13		// Address size ([1, 13] for current standard)
)
(
	//
	//			------- Inputs -------
	//
	input I_sclk,								// Serial data clock
	input _I_csb,								// Active low chip select
	input I_sdi,								// Serial data input
	input [7:0] I_dout,						// Parallel data output (input to be encoded into O_sdo)
	//
	//			------- Outputs -------
	//
	output O_sdo,								// Serial data output
	output O_wen,								// Write enable for parallel data input
	output [ADDR_SIZE - 1:0] O_addr,		// Decoded address
	output [7:0] O_din						// Parallel data input (output decoded from I_sdi)
);

localparam integer DATA_SIZE = 8;	// Data size should always be byte-width

wire spi_rw;				// Read/write indicator (1 = read, 0 = write)
wire spi_astrobe;			// Address strobe to enable address decoding
wire spi_dstrobe;			// Data strobe to enable data decoding and encoding
wire spi_sync;				// Sync pulse to enable reads or writes from memory
wire spi_data_dec_en;	// Enable for decoding from I_sdi (serial) to O_din (parallel)
wire spi_data_enc_en;	// Enable for encoding from I_dout (parallel) to O_sdo (serial)

// MSBs of parallel data input from data decoder
wire [DATA_SIZE - 2:0] spi_din_msbs;

// Instantiate SPI FSM controller.
spi_control spi_ctl
(
	.I_sclk(I_sclk),				// Serial data clock
	._I_csb(_I_csb),				// Active low chip select
	.I_sdi(I_sdi),					// Serial data input
	.O_rw(spi_rw),					// Read/write indicator (1 = read, 0 = write)
	.O_astrobe(spi_astrobe),	// Address strobe to enable address decoding
	.O_dstrobe(spi_dstrobe),	// Data strobe to enable data decoding and encoding
	.O_sync(spi_sync)				// Sync pulse to enable reads or writes from memory
);

// Instantiate SPI address decoder.
spi_decoder #
(
	.DATA_SIZE(ADDR_SIZE)		// The size of the parallel output data.
)
spi_addr_decoder
(
	.I_sclk(I_sclk),				// Serial data clock
	.I_enable(spi_astrobe),		// Enable for the decoder
	.I_sdi(I_sdi),					// Serial data input
	.O_data(O_addr)				// Parallel output data
);

// Instantiate SPI input data decoder.
spi_decoder #
(
	.DATA_SIZE(DATA_SIZE - 1)		// The size of the parallel output data.
)
spi_data_decoder
(
	.I_sclk(I_sclk),					// Serial data clock
	.I_enable(spi_data_dec_en),	// Enable for the decoder
	.I_sdi(I_sdi),						// Serial data input
	.O_data(spi_din_msbs)			// Parallel output data
);

// Instantiate SPI output data encoder.
spi_encoder #
(
	.DATA_SIZE(DATA_SIZE)			// The size of the parallel input data.
)
spi_data_encoder
(
	.I_sclk(I_sclk),					// Serial data clock
	.I_enable(spi_data_enc_en),	// Enable for the decoder
	.I_latch(spi_sync),				// Latch for reading data into shift register
	.I_data(I_dout),					// Parallel input data
	.O_sdo(O_sdo)						// Serial data output
);

assign O_din = {spi_din_msbs, I_sdi};					// Assign parallel data input.

assign O_wen = spi_sync && !spi_rw;						// Assign write enable to memory.

assign spi_data_dec_en = spi_dstrobe && !spi_rw;	// Assign data decode enable.
assign spi_data_enc_en = spi_dstrobe && spi_rw;		// Assign data encode enable.

endmodule

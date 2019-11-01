`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Analog Devices Inc.
// Engineer: Michael Sink
// 
// Create Date:    13:11:57 05/31/2007 
// Design Name: 
// Module Name:    spi_decoder 
// Project Name: 
// Target Devices:
// Tool versions:
// Description: Decoder (de-serializer) for SPI data.
// This decoder assumes MSB first transfer.
//
// Dependencies: 
//
// Revision: 1.00
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spi_decoder #
(
	parameter DATA_SIZE = 8		// The size of the parallel output data.
)
(
	//
	//			------- Inputs -------
	//
	input I_sclk,									// Serial data clock
	input I_enable,								// Enable for the decoder
	input I_sdi,									// Serial data input
	//
	//			------- Outputs -------
	//
	output reg [DATA_SIZE - 1:0] O_data		// Parallel output data
);

// Shift up data and insert SDI on rising clock edge.
always @(posedge I_sclk)
	if (I_enable) O_data <= {O_data[DATA_SIZE - 2:0], I_sdi};

endmodule

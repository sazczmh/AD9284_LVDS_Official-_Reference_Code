`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Analog Devices Inc.
// Engineer: Michael Sink
// 
// Create Date:    14:59:11 05/31/2007 
// Design Name: 
// Module Name:    spi_encoder 
// Project Name: 
// Target Devices:
// Tool versions:
// Description: Encoder (serializer) for SPI data.
// This encoder assumes MSB first transfer.
//
// Dependencies: 
//
// Revision: 1.00
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spi_encoder #
(
	parameter DATA_SIZE = 8		// The size of the parallel input data.
)
(
	//
	//			------- Inputs -------
	//
	input I_sclk,								// Serial data clock
	input I_enable,							// Enable for the decoder
	input I_latch,								// Latch for reading data into shift register
	input [DATA_SIZE - 1:0] I_data,		// Parallel input data
	//
	//			------- Outputs -------
	//
	output O_sdo								// Serial data output
);

reg [DATA_SIZE - 1:0] shift_data;		// Shift register data
reg sdo_enable;								// SDO enable

//	Assign SDO, assuming MSB-first transfers.
assign O_sdo = sdo_enable ? shift_data[DATA_SIZE - 1] : 1'b0;

//	Latch shift register, then shift data to MSB.
//	**	This always block uses the negedge of the I_sclk because serial data out
// 	needs to be ready before the next I_sclk after a valid address has been received.
always @(negedge I_sclk)
	if (I_enable) begin
		if (I_latch) shift_data <= I_data;
		else			 shift_data <= {shift_data[DATA_SIZE - 2:0], 1'b0};
	end
	else shift_data <= 0;

// Synchronize enable for SDO with the negative edge of the clock.
always @(negedge I_sclk)
	sdo_enable <= I_enable;

endmodule

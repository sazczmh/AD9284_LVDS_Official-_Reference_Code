`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Analog Devices Inc.
// Engineer: Michael Sink
// 
// Create Date:    15:06:35 08/28/2007 
// Design Name: 
// Module Name:    reg 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Implements an 8-bit register with a reset and default value.
// This implementation is a read-write, single-port register.
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module reg_rw_sp #
(
	parameter DEFAULT_VALUE = 8'h00
)
(
	//
	//			------- Inputs -------
	//
	input I_clk,				// Master clock
	input I_enable,			// Enable for register access
	input I_wen,				// Register write enable
	input I_reset,				// Reset signal
	input [7:0] I_din,		// Input data
	//
	//			------- Outputs -------
	//
	output [7:0] O_dout		// Output data
);

reg [7:0] reg_value;			// Register value

// Continuously assign register output.
assign O_dout = reg_value;

// Set register on positive clock edge.
always @(posedge I_clk) begin
	if (I_reset)
		reg_value <= DEFAULT_VALUE;	// Set to default value on reset.
	else if (I_wen & I_enable)
		reg_value <= I_din;
end

endmodule

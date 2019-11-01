`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Analog Devices, Inc.
// Engineer: MS
// 
// Create Date:    07/07/2010 
// Design Name: 
// Module Name:    freq_counter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Implements a frequency counter module that counts clock cycles
// to determine a clock frequency.  The clock is counted in parallel to a
// reference counter.
//
// Dependencies: 
//
// Revision: 1.00
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module freq_counter 
(
	input I_clk,						// Input clock to count
	input I_ref_clk,					// Reference clock
	input I_reset,						// Counter reset
	output [31:0] O_freq_word,		// Frequency word
	output O_freq_set					// Frequency set indicator
);

// Internal reset
wire reset;
// Max count
wire max_count;
// Counter reset
reg count_reset;
// Reference and clock counter registers
reg [31:0] ref_count, clk_count;
// Frequency word register value
reg [31:0] freq_reg;

// Initial values
initial begin
	count_reset = 1'b1;
	freq_reg = 32'h0000_0000;
end

// Assign outputs.
assign O_freq_word = freq_reg * 32'h0000_03E8;
assign O_freq_set = count_reset;

// Assign counter reset.
assign max_count = (ref_count == 32'h0001_869F);

// Assign internal reset.
assign reset = I_reset | count_reset;

// Frequency word register
always @(posedge I_ref_clk) begin
	if (I_reset)
		freq_reg <= 32'h0000_0000;
	else if (max_count)
		freq_reg <= clk_count;
end

// Reference counter
always @(posedge I_ref_clk) begin
	if (reset)
		ref_count <= 32'h0000_0000;
	else
		ref_count <= ref_count + 1;
end

// Assign reset for reference counter.
always @(posedge I_ref_clk)
	count_reset <= max_count;

// Clock counter
always @(posedge I_clk or posedge reset) begin
	if (reset)
		clk_count <= 32'h0000_0000;
	else
		clk_count <= clk_count + 1;
end

endmodule

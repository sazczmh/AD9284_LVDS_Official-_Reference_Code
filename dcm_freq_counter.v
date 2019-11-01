`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    07/07/2010
// Design Name: 
// Module Name:    dcm_freq_counter 
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
module dcm_freq_counter #
(
	parameter integer REF_FREQ    = 100000000,	// Reference frequency (100MHz default)
	parameter integer LF_MODE_MIN =  10000000,	// Minimum frequency for "low frequency" mode
	parameter integer LF_MODE_MAX = 150050000,	// Maximum frequency for "low frequency" mode
	parameter integer HF_MODE_MIN = 149950000,	// Minimum frequency for "high frequency" mode
	parameter integer HF_MODE_MAX = 501000000		// Maximum frequency for "high frequency" mode
)
(
	input I_clk,						// Input clock to count
	input I_ref_clk,					// Reference clock
	input I_reset,						// Counter reset
	output [31:0] O_freq_word,		// Frequency word
	output O_freq_mode,				// Frequency mode (0 = low, 1 = high)
	output O_freq_or,					// Frequency out of range (0 = in range, 1 = out of range)
	output O_freq_set					// Frequency set indicator
);

wire [31:0] freq_word;
wire freq_set;

reg freq_mode_reg, freq_or_reg;
reg [31:0] freq_word_reg;
reg freq_set_reg;

// Assign outputs
assign O_freq_word = freq_word_reg;
assign O_freq_mode = freq_mode_reg;
assign O_freq_or = freq_or_reg;
assign O_freq_set = freq_set_reg;

// Instantiate frequency counter.
freq_counter 
 fc (
	.I_clk(I_clk),
	.I_ref_clk(I_ref_clk),
	.I_reset(I_reset),
	.O_freq_word(freq_word),
	.O_freq_set(freq_set)
);

// Assign frequency mode if word is outside transition band.
always @(posedge I_ref_clk) begin
	if (freq_word > LF_MODE_MAX)
		freq_mode_reg <= 1'b1;
	else if (freq_word < HF_MODE_MIN)
		freq_mode_reg <= 1'b0;
end

// Assign frequency out of range.
always @(posedge I_ref_clk) begin
	if ((freq_word < LF_MODE_MIN) || (freq_word > HF_MODE_MAX))
		freq_or_reg <= 1'b1;
	else
		freq_or_reg <= 1'b0;
end

always @(posedge I_ref_clk)
	freq_word_reg <= freq_word;

always @(posedge I_ref_clk)
	freq_set_reg <= freq_set;

endmodule

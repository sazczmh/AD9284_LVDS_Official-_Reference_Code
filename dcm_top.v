`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 		MKH
// 
// Create Date:   06/21/10
// Design Name: 
// Module Name:    
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
module dcm_top #
(
	parameter integer REF_FREQ    = 100000000,	// Reference frequency (100MHz default)
	parameter integer LF_MODE_MIN =  10000000,	// Minimum frequency for "low frequency" mode
	parameter integer LF_MODE_MAX = 150050000,	// Maximum frequency for "low frequency" mode
	parameter integer HF_MODE_MIN = 149950000,	// Minimum frequency for "high frequency" mode
	parameter integer HF_MODE_MAX = 501000000		// Maximum frequency for "high frequency" mode
)
(
	input I_clk_p,						// Input clock to count
	input I_clk_n,
	input I_ref_clk,					// Reference clock
	input I_reset,						// Reset
	input [15:0] I_phase_word,		// Phase shift word
	output O_clk,						// Output clock
	output O_clkdv,					// Divided output clock
	output O_dcm_reset,				// DCM reset
	output O_dcm_locked,				// DCM locked status
	output [31:0] O_freq_word,		// Frequency word
	output O_freq_mode,				// Frequency mode (0 = low, 1 = high)
	output O_freq_or,					// Frequency out of range (0 = in range, 1 = out of range)
	output O_dcm_psdone,				// DCM phase shift done
	output [3:0] O_ctrl_state		// DCM controller state
);

// Clock inputs/outputs
wire dcm_clk0, dcm_clkfb, dcm_clkin, dcm_clkdv;
// Locked status
wire dcm_locked;
// Reset
wire dcm_rst;
// Phase shifting
wire dcm_psdone, dcm_psclk;	//, dcm_psen, dcm_psincdec;
// Dynamic reconfiguration (DRP)
wire dcm_dclk, dcm_den, dcm_dwe, dcm_drdy;
wire [6:0] dcm_daddr;
wire [15:0] dcm_di, dcm_do;

// Frequency word
wire [31:0] freq_word;
// Frequency mode and out of range
wire freq_mode, freq_or;
// Frequency set indicator
wire freq_set;

// DCM controller state
wire [3:0] ctrl_state;

// Assign outputs.
assign O_clk = dcm_clkfb;
assign O_dcm_reset = dcm_rst;
assign O_dcm_locked = dcm_locked;
assign O_freq_word = freq_word;
assign O_freq_mode = freq_mode;
assign O_freq_or = freq_or;
assign O_dcm_psdone = dcm_psdone;
assign O_ctrl_state = ctrl_state;

// Assign CLKIN, convert LVDS to single-ended
IBUFGDS IB1 (.I(I_clk_p), .IB(I_clk_n), .O(dcm_clkin));
// Assign DCLK.
assign dcm_dclk = I_ref_clk;
// Assign PSCLK.
assign dcm_psclk = I_ref_clk;

// Instantiate DCM.
DCM_ADV # (
	.CLKDV_DIVIDE(4.0),
	.CLKOUT_PHASE_SHIFT("DIRECT"), 	// Specify phase shift mode of NONE, FIXED,
												// VARIABLE_POSITIVE, VARIABLE_CENTER or DIRECT
	.DFS_FREQUENCY_MODE("HIGH"),		// HIGH or LOW frequency mode for frequency synthesis
	.DLL_FREQUENCY_MODE("HIGH")		// LOW, HIGH, or HIGH_SER frequency mode for DLL
) DCM_clk (
	.CLK0(dcm_clk0),						// 0 degree DCM CLK output
	.DO(dcm_do),							// 16-bit data output for Dynamic Reconfiguration Port (DRP)
	.DRDY(dcm_drdy),						// Ready output signal from the DRP
	.LOCKED(dcm_locked),					// DCM LOCK status output
	.PSDONE(dcm_psdone),					// Dynamic phase adjust done output
	.CLKFB(dcm_clkfb),					// DCM clock feedback
	.CLKIN(dcm_clkin),					// Clock input (from IBUFG, BUFG or DCM)
	.CLKDV(dcm_clkdv),					// Divided clock output 
	.DADDR(dcm_daddr),					// 7-bit address for the DRP
	.DCLK(dcm_dclk),						// Clock for the DRP
	.DEN(dcm_den),							// Enable input for the DRP
	.DI(dcm_di),							// 16-bit data input for the DRP
	.DWE(dcm_dwe),							// Active high allows for writing configuration memory
	.PSCLK(dcm_psclk),					// Dynamic phase adjust clock input
	.PSEN(1'b0),							// Dynamic phase adjust enable input
	.PSINCDEC(1'b0),						// Dynamic phase adjust increment/decrement
	.RST(dcm_rst)							// DCM asynchronous reset input
);

// Instantiate clock buffer.
BUFG BUFG_clk1
(
	.O(dcm_clkfb),
	.I(dcm_clk0)
);

BUFG BUFG_clk2
(
	.O(O_clkdv),
	.I(dcm_clkdv)
);

// Instantiate DCM controller.
dcm_control dcm_ctrl
(
	.I_clk(dcm_dclk),
	.I_reset(I_reset),
	.I_dcm_locked(dcm_locked),
	.I_drdy(dcm_drdy),
	.I_do(dcm_do),
	.I_freq_mode(freq_mode),
	.I_freq_or(freq_or),
	.I_freq_set(freq_set),
	.I_phase_word(I_phase_word),
	.O_dcm_rst(dcm_rst),
	.O_den(dcm_den),
	.O_dwe(dcm_dwe),
	.O_daddr(dcm_daddr),
	.O_di(dcm_di),
	.O_state(ctrl_state)
);

// Instantiate DCM frequency counter.
dcm_freq_counter # (
	.REF_FREQ(REF_FREQ),
	.LF_MODE_MIN(LF_MODE_MIN),
	.LF_MODE_MAX(LF_MODE_MAX),
	.HF_MODE_MIN(HF_MODE_MIN),
	.HF_MODE_MAX(HF_MODE_MAX)
) dcm_fc (
	.I_clk(dcm_clkin), 
	.I_ref_clk(dcm_dclk), 
	.I_reset(I_reset), 
	.O_freq_word(freq_word),
	.O_freq_mode(freq_mode),
	.O_freq_or(freq_or),
	.O_freq_set(freq_set)
);

endmodule

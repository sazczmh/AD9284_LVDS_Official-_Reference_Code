`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:48:05 01/23/2009 
// Design Name: 
// Module Name:    dcm_control 
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
module dcm_control
(
	//
	//		------- Inputs -------
	//
	input I_clk,							// Clock
	input I_reset,							// Reset
	input I_dcm_locked,					// DCM locked status
	input I_drdy,							// Ready for DRP cycle (from DCM)
	input [15:0] I_do,					// DRP output data
	input I_freq_mode,					// Frequency mode
	input I_freq_or,						// Frequency out of range
	input I_freq_set,						// Frequency set indicator
	input [15:0] I_phase_word,			// Phase shift word
	//
	//		------- Outputs -------
	//
	output O_dcm_rst,						// DCM reset
	output O_den,							// DRP enable
	output O_dwe,							// DRP write enable
	output [6:0] O_daddr,				// DRP address
	output [15:0] O_di,					// DRP input data
	output [3:0] O_state					// DCM control state
);

localparam [3:0] S_RESET = 4'b0000,		// Reset
					  S_FMODE = 4'b0001,		// Frequency mode
					  S_RD_41 = 4'b0010,		// Read from address 0x41
					  S_RDY_1 = 4'b0011,		// Wait for ready
					  S_WR_41 = 4'b0100,		// Write to address 0x41
					  S_RDY_2 = 4'b0101,		// Wait for ready
					  S_RD_58 = 4'b0110,		// Read from address 0x58
					  S_RDY_3 = 4'b0111,		// Wait for ready
					  S_WR_58 = 4'b1000,		// Write to address 0x58
					  S_RDY_4 = 4'b1001,		// Wait for ready
					  S_RHOLD = 4'b1010,		// Hold DCM reset
					  S_PWORD = 4'b1011,		// Phase word
					  S_WR_55 = 4'b1100,		// Write to address 0x55
					  S_RDY_5 = 4'b1101,		// Wait for ready
					  S_WR_11 = 4'b1110,		// Write to address 0x11
					  S_RDY_6 = 4'b1111;		// Wait for ready

reg [3:0] state, next;		// State registers

reg drdy_reg;
reg [15:0] do_reg;

reg dcm_rst, den, dwe;
reg [6:0] daddr;
reg [15:0] di;

reg f_set, p_set;

reg freq_mode_reg;
reg [15:0] phase_word_reg;

wire f_write;
wire p_write;

// Assign outputs.
assign O_dcm_rst = dcm_rst;
assign O_den = den;
assign O_dwe = dwe;
assign O_daddr = daddr;
assign O_di = di;
assign O_state = state;

// Assign frequency mode write.
assign f_write = (freq_mode_reg ^ I_freq_mode) | (I_freq_set & ~I_dcm_locked);

// Assign phase word write.
assign p_write = (phase_word_reg != I_phase_word) & I_dcm_locked;

// DRP data ready register
always @(posedge I_clk)
	drdy_reg <= I_drdy;

// DRP output data register
always @(posedge I_clk)
	if (I_drdy)
		do_reg <= I_do;

// Frequency mode register
always @(posedge I_clk)
	if (f_set)
		freq_mode_reg <= I_freq_mode;

// Phase word register
always @(posedge I_clk) begin
	if (dcm_rst)
		phase_word_reg <= 16'h0000;
	else if (p_set)
		phase_word_reg <= I_phase_word;
end

//	State assignment
always @(posedge I_clk or posedge I_reset) begin
	if (I_reset)
		state <= S_RESET;
	else
		state <= next;
end

//	Register outputs on clock edge.
always @(posedge I_clk or posedge I_reset) begin
	if (I_reset) begin
		dcm_rst <= 1'b0;
		den <= 1'b0;
		dwe <= 1'b0;
		daddr <= 7'h00;
		di <= 16'h0000;
		f_set <= 1'b0;
		p_set <= 1'b0;
	end
	else begin
		dcm_rst <= 1'b0;
		den <= 1'b0;
		dwe <= 1'b0;
		daddr <= 7'h00;
		di <= 16'h0000;
		f_set <= 1'b0;
		p_set <= 1'b0;
		case (next)
			S_RESET, S_RDY_5, S_RDY_6: ;							// Use default outputs.
			S_RDY_1, S_RDY_2, S_RDY_3, S_RDY_4, S_RHOLD:		// Keep reset asserted.
				begin
					dcm_rst <= 1'b1;
				end
			S_FMODE:		// Assert f_set to set frequency mode.
				begin
					dcm_rst <= 1'b1;
					f_set <= 1'b1;
				end
			S_RD_41:		// Read DFS_FREQUENCY_MODE value from DADDR 0x41.
				begin
					dcm_rst <= 1'b1;
					den <= 1'b1;
					daddr <= 7'h41;
				end
			S_WR_41:		// Write DFS_FREQUENCY_MODE value to DADDR 0x41.
				begin
					dcm_rst <= 1'b1;
					den <= 1'b1;
					dwe <= 1'b1;
					daddr <= 7'h41;
					di <= {do_reg[15:6], freq_mode_reg, do_reg[4:0]};
				end
			S_RD_58:		// Read DLL_FREQUENCY_MODE value from DADDR 0x58.
				begin
					dcm_rst <= 1'b1;
					den <= 1'b1;
					daddr <= 7'h58;
				end
			S_WR_58:		// Write DLL_FREQUENCY_MODE value to DADDR 0x58.
				begin
					dcm_rst <= 1'b1;
					den <= 1'b1;
					dwe <= 1'b1;
					daddr <= 7'h58;
					di <= {do_reg[15:8], {2{freq_mode_reg}}, do_reg[5:0]};
				end
			S_PWORD:		// Assert p_set to set phase shift word.
				begin
					p_set <= 1'b1;
				end
			S_WR_55:		// Write phase shift word to DADDR 0x55.
				begin
					den <= 1'b1;
					dwe <= 1'b1;
					daddr <= 7'h55;
					di <= I_phase_word;
				end
			S_WR_11:		// Write anything to DADDR 0x11 to start the phase shift.
				begin
					den <= 1'b1;
					dwe <= 1'b1;
					daddr <= 7'h11;
				end
		endcase
	end
end

// State machine
always @(*) begin
	next = 4'hx;
	case (state)
		S_RESET:
			begin
				if (I_freq_or)
					next = S_RHOLD;	// Keep DCM in reset if frequency is out of range.
				else if (f_write)
					next = S_FMODE;	// Start frequency mode.
				else if (p_write)
					next = S_PWORD;	// Start phase shift word.
				else
					next = S_RESET;
			end
		S_FMODE: next = S_RD_41;
		S_RD_41: next = S_RDY_1;
		S_RDY_1:
			begin
				if (drdy_reg)
					next = S_WR_41;
				else
					next = S_RDY_1;
			end
		S_WR_41: next = S_RDY_2;
		S_RDY_2:
			begin
				if (drdy_reg)
					next = S_RD_58;
				else
					next = S_RDY_2;
			end
		S_RD_58: next = S_RDY_3;
		S_RDY_3:
			begin
				if (drdy_reg)
					next = S_WR_58;
				else
					next = S_RDY_3;
			end
		S_WR_58: next = S_RDY_4;
		S_RDY_4:
			begin
				if (drdy_reg)
					next = S_RESET;
				else
					next = S_RDY_4;
			end
		S_RHOLD:
			begin
				if (I_freq_or)
					next = S_RHOLD;	// Keep DCM in reset if frequency is out of range.
				else
					next = S_FMODE;	// Automatically start frequency mode.
			end
		S_PWORD: next = S_WR_55;
		S_WR_55: next = S_RDY_5;
		S_RDY_5:
			begin
				if (drdy_reg)
					next = S_WR_11;
				else
					next = S_RDY_5;
			end
		S_WR_11: next = S_RDY_6;
		S_RDY_6:
			begin
				if (drdy_reg)
					next = S_RESET;
				else
					next = S_RDY_6;
			end
	endcase
end

endmodule

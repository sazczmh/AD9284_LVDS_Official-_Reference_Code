`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Analog Devices Inc.
// Engineer: Michael Sink
// 
// Create Date:    16:56:13 06/05/2007 
// Design Name: 
// Module Name:    hal_spi_control 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: This module implements a FSM for controlling SPI writes and reads.
// This version supports only 16-bit instruction phase, MSB transfers.
//
// Dependencies: 
//
// Revision: 1.00
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spi_control
(
	//
	//			------- Inputs -------
	//
	input I_sclk,				// Serial data clock
	input _I_csb,				// Active low chip select
	input I_sdi,				// Serial data input
	//
	//			------- Outputs -------
	//
	output reg O_rw,			// Read/write indicator (1 = read, 0 = write)
	output reg O_astrobe,	// Address strobe to enable address decoding
	output reg O_dstrobe,	// Data strobe to enable data decoding and encoding
	output reg O_sync			// Sync pulse to enable reads or writes from memory
);

//Use one-hot state encoding for FPGA.
localparam [9:0] S_RESET = 10'b00_0000_0001,		//Reset state.
					  S_RINST = 10'b00_0000_0010,		//Read instruction state.
					  S_RADDR = 10'b00_0000_0100,		//Read address state.
					  S_RSYNC = 10'b00_0000_1000,		//Read sync state.
					  S_RDATA = 10'b00_0001_0000,		//Read data state.
					  S_WINST = 10'b00_0010_0000,		//Write instruction state.
					  S_WADDR = 10'b00_0100_0000,		//Write address state.
					  S_WDATA = 10'b00_1000_0000,		//Write data state.
					  S_WSYNC = 10'b01_0000_0000,		//Write sync state.
					  S_WPOST = 10'b10_0000_0000;		//Post write sync state.

reg [9:0] state, next;		// State registers
reg [4:0] sclk_count;		// Serial data clock count

//	State assignment
always @(posedge I_sclk or posedge _I_csb)
	if (_I_csb)	state <= S_RESET;
	else			state <= next;

//	Keep track of I_sclk cycle count.
always @(posedge I_sclk or posedge _I_csb)
	if (_I_csb)	sclk_count <= 5'h0;
	else			sclk_count <= (sclk_count < 5'h17) ? sclk_count + 1 : 5'h10;

//	Register outputs on I_sclk edge
always @(posedge I_sclk or posedge _I_csb) begin
	if (_I_csb) begin
		O_rw <= 1'b1;
		O_astrobe <= 1'b0;
		O_dstrobe <= 1'b0;
		O_sync <= 1'b0;
	end
	else begin
		case (next)
			S_RESET: begin
							O_rw <= 1'b1;
							O_astrobe <= 1'b0;
							O_dstrobe <= 1'b0;
							O_sync <= 1'b0;
						end
			S_RINST: begin
							O_rw <= 1'b1;
							O_astrobe <= 1'b0;
							O_dstrobe <= 1'b0;
							O_sync <= 1'b0;
						end
			S_RADDR: begin
							O_rw <= 1'b1;
							O_astrobe <= 1'b1;
							O_dstrobe <= 1'b0;
							O_sync <= 1'b0;
						end
			S_RSYNC: begin
							O_rw <= 1'b1;
							O_astrobe <= 1'b0;
							O_dstrobe <= 1'b1;
							O_sync <= 1'b1;
						end
			S_RDATA: begin
							O_rw <= 1'b1;
							O_astrobe <= 1'b0;
							O_dstrobe <= 1'b1;
							O_sync <= 1'b0;
						end
			S_WINST: begin
							O_rw <= 1'b0;
							O_astrobe <= 1'b0;
							O_dstrobe <= 1'b0;
							O_sync <= 1'b0;
						end
			S_WADDR: begin
							O_rw <= 1'b0;
							O_astrobe <= 1'b1;
							O_dstrobe <= 1'b0;
							O_sync <= 1'b0;
						end
			S_WDATA: begin
							O_rw <= 1'b0;
							O_astrobe <= 1'b0;
							O_dstrobe <= 1'b1;
							O_sync <= 1'b0;
						end
			S_WSYNC: begin
							O_rw <= 1'b0;
							O_astrobe <= 1'b0;
							O_dstrobe <= 1'b1;
							O_sync <= 1'b1;
						end
			S_WPOST: begin
							O_rw <= 1'b0;
							O_astrobe <= 1'b0;
							O_dstrobe <= 1'b1;
							O_sync <= 1'b0;
						end
		endcase
	end
end

//	State machine:
//	Monitor SCLK cycles to determine when to change states.
always @(state or I_sdi or sclk_count) begin
	case (state)
		S_RESET: begin
						//	Check first bit for read/write instruction indicator.
						if (I_sdi == 1'b1)
							next = S_RINST;
						else
							next = S_WINST;
					end
		S_RINST: begin
						if (sclk_count < 5'h02)
							next = S_RINST;
						else
							next = S_RADDR;
					end
		S_RADDR: begin
						if (sclk_count < 5'h0F)
							next = S_RADDR;
						else
							next = S_RSYNC;
					end
		S_RSYNC: next = S_RDATA;
		S_RDATA: begin
						if (sclk_count < 5'h17)
							next = S_RDATA;
						else
							next = S_RSYNC;
					end
		S_WINST: begin
						if (sclk_count < 5'h02)
							next = S_WINST;
						else
							next = S_WADDR;
					end
		S_WADDR: begin
						if (sclk_count < 5'h0F)
							next = S_WADDR;
						else
							next = S_WDATA;
					end
		S_WDATA: begin
						if (sclk_count < 5'h16)
							next = S_WDATA;
						else
							next = S_WSYNC;
					end
		S_WSYNC: next = S_WPOST;
		S_WPOST: next = S_WDATA;
	endcase
end

endmodule

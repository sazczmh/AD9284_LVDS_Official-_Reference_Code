`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		Analog Devices, Inc.
// Engineer: 		MKH
// 
// Create Date:   06-29-2010 
// Design Name: 
// Module Name:   Top.v
// Project Name:	
// Target Devices: 
// Tool versions: 11.4
// Description: 	Top level verilog module
//					
// Dependencies: 
//
// Revision 0.01 - File Created
// Revision: 
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module Top (din_p,		// input data
				din_n,
				dco_p, 		// clock input
				dco_n,
				clk100,		// 100 MHz clock for DCM DRP
			   mr,			// master reset, active LOW
				wen,			// write enable, active LOW
				rclk,			// read clock
				ren,			// read enable, active LOW
				rdy,			// data ready for USB controller
				dout);		// data output to USB			

input clk100;
input	mr, wen;
input ren, rclk;
input dco_p, dco_n;
input	[7:0] din_p, din_n; 

output rdy;
output [15:0] dout;  			

wire [63:0] wr_data;

//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
// Configure DCM depending on sample rate
//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
dcm_top U1 (.I_clk_p(dco_p),
				.I_clk_n(dco_n),
 				.I_ref_clk(clk100),
				.I_reset(~mr),
				.I_phase_word(16'h1F), 
				.O_clk(dco),						
				.O_clkdv(dclk),						
				.O_dcm_locked(locked));

//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
// Capture data
//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
capture U2 (.dco(dco), 
				.dclk(dclk),
				.din_p(din_p), 
				.din_n(din_n),
				.wr_data(wr_data));

//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
// Write to and read from FIFO
//-------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------
storage U3 (.rst(~mr), 
				.wen(~wen & locked),
				.din(wr_data), 
				.wrclk(dclk), 
				.rden(~ren), 
				.rclk(rclk),  
				.rdy(rdy), 
				.dout(dout));
					 
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		Analog Devices, Inc.
// Engineer: 		MKH
// 
// Create Date:   06-29-2010 
// Design Name: 
// Module Name:   storage.v 
// Project Name:	
// Target Devices: 
// Tool versions: 11.4
// Description: 	data storage, FIFO
//					
// Dependencies: 
//
// Revision 0.01 - File Created
// Revision: 
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module storage (rst, wen, din, wrclk, 
					 rden, rclk, rdy, dout);

input rst, wen, rclk;
input rden, wrclk;
input [63:0] din;

output rdy;
output reg [15:0] dout;

reg [11:0] wcnt;
reg [63:0] wren;

wire [63:0] d_out;
wire [127:0] rlsb;

assign rdy = 1'b1;

// buffer rclk
IBUFG B1 (.I(rclk), .O(rdclk));

// add delay to ensure DCM is settled
always @(posedge wrclk or posedge rst)
	if(rst)
		wcnt <= 12'b0;
	else if(wen & ~&wcnt)
		wcnt <= wcnt + 1;

// synchronize wen
always @(posedge wrclk or posedge rst)
	if(rst)
		wren <= 64'b0;
	else
		wren <= {64{&wcnt}};
	
// instantiate BRAMs
fifo16k_by_1 U[63:0] (.din(din), 
							 .wrclk(wrclk), 
							 .rdclk(rdclk), 
							 .wren(wren), 
							 .rden(rden), 
							 .rst(rst), 
							 .rlsb(rlsb),							 
							 .dout(d_out));
							 
// parse output data
always @(posedge rdclk)
	case(rlsb[1:0])
		2'b01: dout <= {d_out[63:48]};
		2'b10: dout <= {d_out[47:32]};
		2'b11: dout <= {d_out[31:16]};
		2'b00: dout <= {d_out[15:0]};
	endcase

endmodule

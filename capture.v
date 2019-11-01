`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		Analog Devices, Inc.
// Engineer: 		MKH
// 
// Create Date:   06-29-2010 
// Design Name: 
// Module Name:   capture.v 
// Project Name:	
// Target Devices: 
// Tool versions: 11.4
// Description: 	data capture
//					
// Dependencies: 
//
// Revision 0.01 - File Created
// Revision: 
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module capture (dco, din_p, din_n, wr_data, dclk);

input dco;
input dclk;             
input [7:0] din_p, din_n;

output reg [63:0] wr_data; 

wire [7:0] din_buf;
wire [7:0] dr, df;

reg [7:0] df1;
reg [15:0] data1, data2;
reg [15:0] data3, data4;

// input buffers for data
IBUFDS IBD[7:0] (.I(din_p), .IB(din_n), .O(din_buf)); // MSB-7, LSB-0

// latch data on both edges
IDDR #(.DDR_CLK_EDGE("SAME_EDGE_PIPELINED")) I[7:0] (
		 .D(din_buf), .C(dco), .Q1(dr), .Q2(df),
		 .CE(1'b1), .S(1'b0), .R(1'b0));

// swap word order
always @(posedge dco)
	df1 <= df;

// pipeline 16-bit words
always @(posedge dco)
	begin
		data1 <= {dr, df1};
		data2 <= data1;
		data3 <= data2;
		data4 <= data3;
	end

// register data
always @(posedge dclk)
	wr_data <= {data4, data3, data2, data1};

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		Analog Devices, Inc.
// Engineer: 		MKH
// 
// Create Date:   11-11-2009 
// Design Name: 
// Module Name:   Top 
// Project Name:	AD9284
// Target Devices: 
// Tool versions: 11.3
// Description: 	data storage, FIFO
//					
// Dependencies: 
//
// Revision 0.01 - File Created
// Revision: 
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module fifo64k_by_16 (rst, wen, din, wrclk,
							 rden, rdclk, data_out);

input wrclk;
input wen, rdclk;
input rden, rst;
input [15:0] din;

output [15:0] data_out;

reg [15:0] wren;

// synchronize wen
always @(posedge wrclk or posedge rst)
	if(rst)
		wren <= 1'b0;
	else
		wren <= {16{wen}};
	
// instantiate BRAMs
fifo64k_by_1 U[15:0] (.din(din), 
							 .wrclk(wrclk), 
							 .rdclk(rdclk), 
							 .wr_en(wren), 
							 .rd_en(rden), 
							 .rst(rst), 
							 .dout(data_out));

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		Analog Devices, Inc.
// Engineer: 		MKH
// 
// Create Date:   12-17-2008 
// Design Name: 
// Module Name:   usb_out.v 
// Project Name:	AD6657
// Target Devices: 
// Tool versions: 10.1.2
// Description: 	send data to USB controller
//					
// Dependencies: 
//
// Revision 0.01 - File Created
// Revision: 
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module usb_out (rdclk, data_out, dout);

input rdclk;
input [10:0] data_out;

output reg [15:0] dout;

// send data out to USB chip
always @(posedge rdclk)
	dout <= {data_out, 5'b0};

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 		Analog Devices, Inc.
// Engineer: 		MKH
// 
// Create Date:   06-29-2010 
// Design Name: 
// Module Name:    
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

module fifo16k_by_1 (rst, din, 
							wrclk, wren, 
							rdclk, rden,
							rlsb, dout);

input din, wrclk, wren;
input rdclk, rden, rst;

output [1:0] rlsb;
output reg dout;

wire dout1;

reg mem;
reg full;
reg [7:0] rgate; 
reg [13:0] wr_addr;
reg [15:0] rd_addr;

assign rlsb = rd_addr[1:0];

// generate write address
always @(posedge wrclk or posedge rst)
	if(rst)
		wr_addr <= 14'b0;
	else if(wren & ~&wr_addr) // do not write past max count
		wr_addr <= wr_addr + 1;

// generate full flag
always @(posedge wrclk)
	full <= &wr_addr;

// generate write enables to steer the data into the correct block of memory
always@(wren or full)
  case ({wren & ~full})
    1'b1: mem = 1'b1;
	 default: mem = 1'b0;
  endcase

// ignore first 256 rclk cycles
always @(posedge rdclk or posedge rst)
	if(rst)
		rgate <= 8'b0;
	else if(rden & ~&rgate)
		rgate <= rgate + 1;

// generate read address
always @(posedge rdclk or posedge rst)
	if(rst)
		rd_addr <= 16'b0;
	else if(rden & &rgate)     
		rd_addr <= rd_addr + 1;

// read data
always @(dout1)
	dout <= dout1;

// instantiate block memory
RAMB16 #(.WRITE_WIDTH_A(1), .READ_WIDTH_B(1)) 
RAMB16_U1 (.DOB(dout1), 
			  .ADDRA({1'b0, wr_addr[13:0]}), 
			  .ADDRB({1'b0, rd_addr[15:2]}), 
			  .CLKA(wrclk), .CLKB(rdclk), 
			  .DIA({31'b0, din}),
			  .ENA(1'b1), .ENB(1'b1), 
			  .SSRA(rst), .SSRB(rst), 
			  .WEA({4{mem}}), .WEB(4'b0));

endmodule

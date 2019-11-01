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

module fifo64k_by_1 (din, wrclk, rdclk, wr_en, 
							rd_en, rst, dout);

input din, wrclk, wr_en;
input rdclk, rd_en, rst;

output reg dout;

wire dout1, dout2, dout3, dout4;

reg full;
reg [1:0] rd_sel;
reg [3:0] mem; 
reg [15:0] wr_addr;
reg [15:0] rd_addr;

// generate write address
always @(posedge wrclk or posedge rst)
	if(rst)
		wr_addr <= 16'b0;
	else if(wr_en && ~&wr_addr) // do not write past max count
		wr_addr <= wr_addr + 1;

// generate full flag
always @(posedge wrclk)
	full <= &wr_addr;

// generate write enables to steer the data into the correct block of memory
always@(wr_en or full or wr_addr[15:14])
  case ({{wr_en & ~full}, wr_addr[15:14]})
    3'b100: mem = 4'b0001;
    3'b101: mem = 4'b0010;
	 3'b110: mem = 4'b0100;
	 3'b111: mem = 4'b1000;
	 default: mem = 4'b0000;
  endcase

// generate read address
always @(negedge rdclk or posedge rst)
	if(rst)
		rd_addr <= 16'b0;
	else if(rd_en)     
		rd_addr <= rd_addr + 1;

// generate read sel
// register is needed to match clock latency of the block memories
always @(negedge rdclk)
  rd_sel <= rd_addr[15:14];

// select read data from the correct block of memory
always @(dout1 or dout2 or dout3 or dout4 or rd_sel)
  case (rd_sel)
    2'b00: dout <= dout1;
	 2'b01: dout <= dout2;
	 2'b10: dout <= dout3;
	 2'b11: dout <= dout4;
  endcase

// instantiate 4 block memories
RAMB16 #(.WRITE_WIDTH_A(1), .READ_WIDTH_B(1)) 
RAMB16_U1 (.DOB(dout1), 
			  .ADDRA({1'b0, wr_addr[13:0]}), 
			  .ADDRB({1'b0, rd_addr[13:0]}), 
			  .CLKA(wrclk), .CLKB(rdclk), 
			  .DIA({31'b0, din}),
			  .ENA(1'b1), .ENB(1'b1), 
			  .SSRA(rst), .SSRB(rst), 
			  .WEA({4{mem[0]}}), .WEB(4'b0));

RAMB16 #(.WRITE_WIDTH_A(1), .READ_WIDTH_B(1)) 
RAMB16_U2 (.DOB(dout2), 
			  .ADDRA({1'b0, wr_addr[13:0]}), 
			  .ADDRB({1'b0, rd_addr[13:0]}), 
			  .CLKA(wrclk), .CLKB(rdclk), 
			  .DIA({31'b0, din}),
			  .ENA(1'b1), .ENB(1'b1), 
			  .SSRA(rst), .SSRB(rst), 
			  .WEA({4{mem[1]}}), .WEB(4'b0));

RAMB16 #(.WRITE_WIDTH_A(1), .READ_WIDTH_B(1)) 
RAMB16_U3 (.DOB(dout3), 
			  .ADDRA({1'b0, wr_addr[13:0]}), 
			  .ADDRB({1'b0, rd_addr[13:0]}), 
			  .CLKA(wrclk), .CLKB(rdclk), 
			  .DIA({31'b0, din}),  
			  .ENA(1'b1), .ENB(1'b1), 
			  .SSRA(rst), .SSRB(rst), 
			  .WEA({4{mem[2]}}), .WEB(4'b0));

RAMB16 #(.WRITE_WIDTH_A(1), .READ_WIDTH_B(1)) 
RAMB16_U4 (.DOB(dout4), 
			  .ADDRA({1'b0, wr_addr[13:0]}), 
			  .ADDRB({1'b0, rd_addr[13:0]}), 
			  .CLKA(wrclk), .CLKB(rdclk), 
			  .DIA({31'b0, din}),  
			  .ENA(1'b1), .ENB(1'b1), 
			  .SSRA(rst), .SSRB(rst), 
			  .WEA({4{mem[3]}}), .WEB(4'b0));

endmodule

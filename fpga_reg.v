`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Analog Devices Inc.
// Engineer: MH
// 
// Create Date:    15:30:43 08/04/2008 
// Design Name: 
// Module Name:    fpga_reg 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: This module implements FPGA memory.  The memory has built-in
// soft-reset bit and transfer bit that follows the current ADI SPI specification.
// Also, read-only registers can be implemented.
//
// Dependencies: reg_rw_sp.v, reg_r_sp.v
//
// Revision: 1.00
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

// ******* BEGIN control register addresses. (cr_*) *******

`define cr_CONFIG										8'h00
`define cr_DEVICEID									8'h01
`define cr_REVISION									8'h02

`define cr_REG_3										8'h03

// ******* END control register addresses. *******

// ******* BEGIN default register values. (dv_*) *******

`define dv_CONFIG										8'hAA
`define dv_DEVICEID									8'h01
`define dv_REVISION									8'h00

`define dv_REG_3										8'h00

// ******* END default register values. *******

module fpga_reg
(
	input I_clk,					// Master clock
	input I_enable,				// Enable for memory access
	input I_wen,					// Register write enable
	input [7:0] I_addr,			// Input read/write address
	input [7:0] I_din,			// Input data

	output reg [7:0] O_dout,	// Output data for SPI controller
	output reg [7:0] O_reg3		// Registered output data 	
);

localparam integer DATA_SIZE = 8;		// Data size
localparam integer ADDR_SIZE = 8;		// Address size

// ******* BEGIN register values. (rv_*) *******

wire [DATA_SIZE - 1:0] rv_REG_3;

// ******* END register values. *******

// ******* soft reset not used *******
wire soft_reset_bit = 1'b0;

// Assign data out (tri-state - high impedance if disabled).
always @(*) begin
	if (I_enable) begin
		case (I_addr)
			`cr_CONFIG:
				O_dout <= `dv_CONFIG;
			`cr_DEVICEID:
				O_dout <= `dv_DEVICEID;
			`cr_REVISION:
				O_dout <= `dv_REVISION;
			`cr_REG_3:
				O_dout <= rv_REG_3;
			default:
				O_dout <= 8'h00;
		endcase
	end
	else O_dout <= 8'h00;
end

// ******* BEGIN register instantiation *******

//	register 3
reg_rw_sp # (.DEFAULT_VALUE(`dv_REG_3)) REG_3
(
	.I_clk(I_clk), .I_enable(I_addr == `cr_REG_3), .I_wen(I_wen), 
	.I_reset(soft_reset_bit), .I_din(I_din), .O_dout(rv_REG_3)
);

// ******* END registers. *******

// ******* Register data bits when CSB returns high *******
always @(negedge I_enable)
	begin	
		O_reg3 <= rv_REG_3;
	end

endmodule

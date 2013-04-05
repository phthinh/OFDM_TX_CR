`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:03:02 04/04/2013 
// Design Name: 
// Module Name:    CR_Regs 
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
module CR_Regs(
	input 				CLK_I, RST_I,
	input [31:0] 		DAT_I,
	input [1:0]			ADR_I,
	input 				WE_I, STB_I, 
	output				ACK_O,
	
	input					VEC_LD,
	output [1:0]		STD,
	output [4095:0]	ALLOC_VEC
    );


wire 		 wr_ena;
wire		 ctr_sel;
wire		 vec_sel;
wire		 vec_clr;

assign 	 wr_ena 	= 	WE_I & STB_I;
assign	 ctr_sel = (ADR_I == 2'b00);
assign	 vec_sel = (ADR_I == 2'b01);
assign	 vec_clr = (ADR_I == 2'b10);

reg [1:0] 		STD;
reg [4095:0]	ALLOC_VEC;
reg [6:0] 		vec_cnt;
reg				vec_full;
always@(posedge CLK_I)
begin
	if(RST_I)											ALLOC_VEC	<= 4098'd0;		
//	else if(VEC_LD | (ctr_sel & wr_ena))		ALLOC_VEC	<= 4098'd0;
	else if(vec_sel & wr_ena & (ACK_O))			ALLOC_VEC	<= {ALLOC_VEC[4065:0], DAT_I};
end

always@(posedge CLK_I)
begin
	if(RST_I)											vec_cnt	<= 7'd0;		
	else if(VEC_LD)									vec_cnt	<= 7'd0;
	else if(vec_sel & wr_ena & (ACK_O))			vec_cnt	<= vec_cnt + 1'b1;
end

always@(posedge CLK_I)
begin
	if(RST_I)							STD	<= 2'd0;		
	else if(ctr_sel & wr_ena)		STD	<= DAT_I[1:0];
end

always@(*) 
begin
	case (STD)
      2'b00  :	vec_full = (vec_cnt == 7'd3);
		2'b01  : vec_full = (vec_cnt == 7'd15);
		2'b10  : vec_full = (vec_cnt == 7'd127);
		2'b11  : vec_full = 1'b1;
		default: vec_full = 1'b1;
	endcase
end

reg vec_wre;
always@(posedge CLK_I)
begin
	if(RST_I)							vec_wre	<= 1'b1;	
	else if(ctr_sel & wr_ena)		vec_wre <= 1'b1;	
	else if(VEC_LD)					vec_wre <= 1'b1;
	else if(vec_full)					vec_wre <= 1'b0;
end

assign ACK_O = (vec_sel)? vec_wre : 1'b1;
endmodule

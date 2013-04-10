`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:09:26 04/09/2013 
// Design Name: 
// Module Name:    SYM_Mod 
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
`define Q64n7 16'h8001
`define Q64n5 16'h9D3F
`define Q64n3 16'hC2BF
`define Q64n1 16'hEC40
`define Q64p1 16'h13C0
`define Q64p3 16'h3B41
`define Q64p5 16'h62C1
`define Q64p7 16'h7FFF

`define Q16n3 16'h8692
`define Q16n1 16'hD786
`define Q16p1 16'h287A
`define Q16p3 16'h796E

`define QPSKp 16'h5A82
`define QPSKn 16'hA57E

module SYM_Mod(
 	input 				CLK_I, RST_I,
	input [5:0] 		DAT_I,
	input 				CYC_I, WE_I, STB_I, 
	output				ACK_O,
	
	output reg [31:0]	DAT_O,
	output reg			CYC_O, STB_O,
	output				WE_O,
	input					ACK_I,

	input	 [1:0]		MOD
    );

reg [5:0]	idat_Q64;
reg [3:0]	idat_Q16;
reg [1:0]	idat_QPSK;
reg 			idat_BPSK;
reg			ival;	

wire 			out_halt, ena;

reg [15:0] 	datout_Re, datout_Im;

assign 	out_halt = STB_O & (~ACK_I);
assign 	ena 		= CYC_I & STB_I & WE_I;
assign 	ACK_O 	= ena &(~out_halt);

wire 		mod_q64_ena 	= (MOD == 2'b11);
wire 		mod_q16_ena 	= (MOD == 2'b10);
wire 		mod_qpsk_ena 	= (MOD == 2'b00);
wire 		mod_bpsk_ena 	= (MOD == 2'b01);
	
always @(posedge CLK_I) begin
	if(RST_I) 							idat_Q64 <= 6'b000000;
	else if(ACK_O & mod_q64_ena) 	idat_Q64 <= DAT_I;
end
always @(posedge CLK_I) begin
	if(RST_I) 							idat_Q16 <= 4'b0000;
	else if(ACK_O & mod_q64_ena) 	idat_Q16 <= DAT_I[3:0];
end
always @(posedge CLK_I) begin
	if(RST_I) 							idat_QPSK <= 2'b00;
	else if(ACK_O & mod_qpsk_ena) idat_QPSK <= DAT_I[1:0];
end
always @(posedge CLK_I) begin
	if(RST_I) 							idat_BPSK <= 1'b0;
	else if(ACK_O & mod_bpsk_ena) idat_BPSK <= DAT_I[0];
end

always @(posedge CLK_I) begin
	if(RST_I) 			ival <= 1'b0;
	else if(ena)		ival <= 1'b1;
	else					ival <= 1'b0;
end

always @(posedge CLK_I)
begin
	if(RST_I)	begin
		STB_O <= 1'b0;
		DAT_O <= 32'b0;
		end
	else if(ival & (~out_halt)) begin	
		DAT_O <= {datout_Im, datout_Re};	
		STB_O <= 1'b1;
		end	
	else if(~ival) begin	
		STB_O <= 1'b0;
		end
end

reg icyc;
always @(posedge CLK_I)
begin
	if(RST_I)		icyc <= 1'b0;		
	else				icyc <= CYC_I;	
end
always @(posedge CLK_I)
begin
	if(RST_I)		CYC_O	<= icyc;			
	else 				CYC_O	<= icyc;
end

assign WE_O = STB_O;

reg [15:0] Q64_Im, Q16_Im;
reg [15:0] Q64_Re, Q16_Re;
always @(*) begin
	case (idat_Q64[5:3])
      3'b111 :	Q64_Im = `Q64n7;
		3'b110 : Q64_Im = `Q64n5;
		3'b100 :	Q64_Im = `Q64n3;
		3'b101 : Q64_Im = `Q64n1;
		3'b001 : Q64_Im = `Q64p1;
		3'b000 : Q64_Im = `Q64p3;
		3'b010 : Q64_Im = `Q64p5;
		3'b011 : Q64_Im = `Q64p7;
		default: Q64_Im = 16'd0;
	endcase
end
always @(*) begin
	case (idat_Q64[2:0])
      3'b111 :	Q64_Re = `Q64n7;
		3'b110 : Q64_Re = `Q64n5;
		3'b100 :	Q64_Re = `Q64n3;
		3'b101 : Q64_Re = `Q64n1;
		3'b001 : Q64_Re = `Q64p1;
		3'b000 : Q64_Re = `Q64p3;
		3'b010 : Q64_Re = `Q64p5;
		3'b011 : Q64_Re = `Q64p7;
		default: Q64_Re = 16'd0;
	endcase
end

always @(*) begin
	case (idat_Q16[3:2])
      2'b11  :	Q16_Im = `Q16n3;
		2'b10  : Q16_Im = `Q16n1;
		2'b00  : Q16_Im = `Q16p1;
		2'b01  : Q16_Im = `Q16p3;
		default: Q16_Im = 16'd0;
	endcase
end
always @(*) begin
	case (idat_Q16[1:0])
      2'b11  :	Q16_Re = `Q16n3;
		2'b10  : Q16_Re = `Q16n1;
		2'b00  : Q16_Re = `Q16p1;
		2'b01  : Q16_Re = `Q16p3;
		default: Q16_Re = 16'd0;
	endcase
end

wire [15:0] QPSK_Re;
wire [15:0] QPSK_Im, BPSK_Im;
assign QPSK_Im = (idat_QPSK[1])? QPSKn : QPSKp;
assign QPSK_Re = (idat_QPSK[0])? QPSKn : QPSKp;

assign BPSK_Im = (idat_BPSK[0])?16'h8001:16'h7FFF;

always @(*) begin
	case (MOD)
      2'b11  :	datout_Im = Q64_Im;
		2'b10  : datout_Im = Q16_Im;
		2'b00  : datout_Im = QPSK_Im;
		2'b01  : datout_Im = BPSK_Im;
		default: datout_Im = 16'd0;
	endcase
end

always @(*) begin
	case (MOD)
      2'b11  :	datout_Re = Q64_Re;
		2'b10  : datout_Re = Q16_Re;
		2'b00  : datout_Re = QPSK_Re;
		2'b01  : datout_Re = 16'd0;
		default: datout_Re = 16'd0;
	endcase
end


endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:02:46 12/04/2012 
// Design Name: 
// Module Name:    Pilots_Insert 
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
module Pilots_Insert(
 	input 			CLK_I, RST_I,
	input [31:0] 	DAT_I,
	input 			CYC_I, WE_I, STB_I, 
	output			ACK_O,
	
	output reg [31:0]	DAT_O,
	output reg		CYC_O, STB_O,
	output			WE_O,
	input				ACK_I,

	input [1:0]		STD,		// style of standard 00:802.16; 01:802.16; 10:802.22
	input [4095:0] ALLOC_VEC,
	output			VEC_LD
    );
parameter P_P = 16'h7fff;	// +1 in Q1.15
parameter P_N = 16'h8001;	// -1 in Q1.15 
//reg [1:0] alloc_vec 	 [0:4096];   // signed bit of real part of pilots,
//initial $readmemh("./MY_SOURCES/Al_vec.txt", alloc_vec);

reg  [31:0]	idat;
wire [31:0]  odat;
reg			ival;	
wire 			out_halt, ena;
wire			datout_ack;


reg [10:0]	dat_cnt;
reg [10:0]	alloc_ptr;			// pointer of allocation vector
wire			pil_insert_ena;
wire			car_unactive;
wire			pil_N;				// insert negative pilot
wire			pil_P;				// insert positive pilot
wire [15:0] pil_Re;
wire [1:0]	cur_carrier;
reg			sym_end; 


assign 	out_halt  	= (STB_O)&(CYC_O) & (~ACK_I);
assign 	datout_ack	= STB_O&(CYC_O) & ACK_I;
assign 	ena 			= CYC_I & STB_I & WE_I;
assign 	ACK_O 		= ena & CYC_O & (~out_halt) & (~pil_insert_ena) & (~car_unactive);

always @(posedge CLK_I) begin
	if(RST_I) 			idat<= 2'b00;
	else if(ACK_O) 	idat <= DAT_I;
end
always @(posedge CLK_I) begin
	if(RST_I) 		ival <= 1'b0;
	else if(ena)	ival <= 1'b1;
	else				ival <= 1'b0;
end

always @(posedge CLK_I)
begin
	if(RST_I)											STB_O <= 1'b0;
	else if(ival|pil_insert_ena|car_unactive)	STB_O <= 1'b1;
	else if(~ival) 									STB_O <= 1'b0;
end

reg [1:0] icyc;
always @(posedge CLK_I)
begin
	if(RST_I)		icyc <= 2'b00;		
	else				icyc <= {icyc[0],CYC_I};	
end

always @(posedge CLK_I)
begin
	if(RST_I)										CYC_O	<= 1'b0;			
	else if (icyc[1] & CYC_I & (~CYC_O))	CYC_O	<= 1'b1;
	else if (sym_end & (~CYC_I))				CYC_O	<= 1'b0;
end
assign odat = (car_unactive)? 32'd0: (pil_insert_ena)? {16'd0, pil_Re} : DAT_I;
always @(posedge CLK_I)
begin
	if(RST_I)							DAT_O <= 32'b0;
	else if(ival & (~out_halt))	DAT_O <= odat;	
end
assign WE_O  = STB_O;	 

always@(posedge CLK_I)
begin
	if(RST_I)										dat_cnt	<= 11'd0;		
	else if(CYC_I & (~icyc[0]))				dat_cnt	<= 11'd0;
	else if(sym_end)								dat_cnt	<= 11'd0;
	else if(datout_ack)						   dat_cnt	<= dat_cnt + 1'b1;
end

reg vec_nd;
always@(*) begin
	   case (STD)
      2'b00  : begin
						vec_nd = (dat_cnt[5:0] == 11'd62);
					end
      2'b01  : begin
						vec_nd = (dat_cnt[7:0] == 11'd254);
					end
      2'b10  : begin
						vec_nd = (dat_cnt == 11'd2046);
					end
      2'b11  : begin
						vec_nd = 1'b0;
					end
      default: begin
						vec_nd = 1'b0;
					end
   endcase
end
assign VEC_LD = vec_nd|(CYC_I & (~icyc[0]));
always@(posedge CLK_I)
begin
	if(RST_I)		sym_end	<= 1'd0;		
	else 				sym_end  <= vec_nd;	
end
//assign VEC_LD = vec_ld;

reg [4095:0] alloc_reg;
always@(posedge CLK_I)
begin
	if(RST_I)							alloc_reg	<= 11'd0;		
	else if(CYC_I & (~icyc[0]))	alloc_reg	<= ALLOC_VEC;
	else if(vec_nd)					alloc_reg	<= ALLOC_VEC;
	else if(icyc[1] & (~CYC_O))	alloc_reg	<= {2'b00, alloc_reg[4095:2]};
	else if(datout_ack)				alloc_reg	<=	{2'b00, alloc_reg[4095:2]};;
end

wire [1:0] 	cur_alloc;
assign 		cur_alloc			= alloc_reg[1:0];
assign 		pil_Re 				= (pil_P)? P_P : P_N;
assign 		pil_P 				= (cur_alloc == 2'b01);
assign 		pil_N 				= (cur_alloc == 2'b11);
assign 		car_unactive   	= (cur_alloc == 2'b00);
assign 		pil_insert_ena 	=  pil_P|pil_N;

endmodule 

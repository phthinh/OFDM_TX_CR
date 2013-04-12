`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:19:08 12/19/2012 
// Design Name: 
// Module Name:    OFDM_TX_tb 
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
module OFDM_TX_tb(
    );
reg 				rst, clk;

reg  [31:0] 	cfg_dat_i;
reg	[1:0]	 	cfg_adr_i;
reg				cfg_we_i, cfg_stb_i;
wire				cfg_ack_o;
				
reg 				we_i, stb_i, cyc_i;
reg	[5:0] 	dat_in;
reg			 	ack_i;
wire 			 	ack_o;
wire 	[31:0] 	dat_out;
wire			 	we_o, stb_o, cyc_o;

OFDM_TX_CR UUT(
	.CLK_I(clk), .RST_I(rst),
	
	.CFG_DAT_I(cfg_dat_i),
	.CFG_ADR_I(cfg_adr_i),
	.CFG_WE_I (cfg_we_i),
	.CFG_STB_I(cfg_stb_i),
	.CFG_ACK_O(cfg_ack_o),
	
	.DAT_I(dat_in),
	.WE_I(we_i), 
	.STB_I(stb_i),
	.CYC_I(cyc_i),
	.ACK_O(ack_o),	
	.DAT_O(dat_out),
	.WE_O (we_o), 
	.STB_O(stb_o),
	.CYC_O(cyc_o),
	.ACK_I(ack_i)
    );

wire [31:0] DAT_Mod_dat_out 	= UUT.DAT_Mod_Ins.DAT_O;	
wire			DAT_Mod_we_o		= UUT.DAT_Mod_Ins.WE_O; 
wire			DAT_Mod_stb_o		= UUT.DAT_Mod_Ins.STB_O; 
wire			DAT_Mod_cyc_o		= UUT.DAT_Mod_Ins.CYC_O;
wire 			DAT_Mod_ack_o		= UUT.DAT_Mod_Ins.ACK_O;

wire [31:0] Pilots_Insert_dat_out	= UUT.Pilots_Insert_Ins.DAT_O;	
wire			Pilots_Insert_we_o		= UUT.Pilots_Insert_Ins.WE_O; 
wire			Pilots_Insert_stb_o		= UUT.Pilots_Insert_Ins.STB_O; 
wire			Pilots_Insert_cyc_o		= UUT.Pilots_Insert_Ins.CYC_O;
wire 			Pilots_Insert_ack_o		= UUT.Pilots_Insert_Ins.ACK_O;

wire [31:0] IFFT_Mod_dat_out 	= UUT.IFFT_Mod_Ins.DAT_O;	
wire			IFFT_Mod_we_o		= UUT.IFFT_Mod_Ins.WE_O; 
wire			IFFT_Mod_stb_o		= UUT.IFFT_Mod_Ins.STB_O; 
wire			IFFT_Mod_cyc_o		= UUT.IFFT_Mod_Ins.CYC_O;
wire 			IFFT_Mod_ack_o		= UUT.IFFT_Mod_Ins.ACK_O;

wire 			IFFT_Mod_ack_i		= UUT.IFFT_Mod_Ins.ACK_I;

parameter    NSAM  = 5*1440;
reg [5:0] 	 datin [NSAM - 1:0];
reg [31:0]	 alloc_vec[0:511];
reg [31:0]	 config_dat;

integer 	ii, dat_ptr, dat_off, lop_cnt;
integer  STD, MOD, NDS, LEN, NFRM, para_fin;	// parameter of current frame;
integer 	STD_vec [0:20];
integer 	MOD_vec [0:20];
integer  NDS_vec [0:20];
integer  LEN_vec [0:20];

integer  SYM_VEC_LEN, ALLOC_VEC_LEN;	// total length of data bit symbols and allocation words for transmission.

integer  alloc_wps;		// number of words of allocation vector in 1 symbols of current frame.
integer 	alloc_len;		// length of allocation vector in word of 32 bits for current frame = alloc_wps *NDS;
integer	alloc_ptr;		// current word of allocation vector of current frame.
integer	alloc_off;		// offset of allocation vector of current frame in total allocation vector.


initial 	begin
		rst 		= 1'b1;
		clk 		= 1'b0;	
		we_i		= 1'b0;
		stb_i		= 1'b0;
		cyc_i		= 1'b0;
		dat_in	= 6'd0;
		
		para_fin = $fopen("./MATLAB/OFDM_TX_bit_symbols_Len.txt","r");
			$fscanf(para_fin, "%d ", NFRM);
		for (ii = 0; ii<NFRM; ii=ii+1) begin
			$fscanf(para_fin, "%d ", STD_vec[ii]);
		end
		for (ii = 0; ii<NFRM; ii=ii+1) begin
			$fscanf(para_fin, "%d ", MOD_vec[ii]);
		end		
		for (ii = 0; ii<NFRM; ii=ii+1) begin
			$fscanf(para_fin, "%d ", NDS_vec[ii]);
		end
		for (ii = 0; ii<NFRM; ii=ii+1) begin
			$fscanf(para_fin, "%d ", LEN_vec[ii]);
		end
			$fscanf(para_fin, "%d ", SYM_VEC_LEN[ii]);
			$fscanf(para_fin, "%d ", ALLOC_VEC_LEN[ii]);
		$fclose(para_fin);

		$readmemh("./MATLAB/RTL_OFDM_TX_bit_symbols.txt", datin);
		$readmemh("./MATLAB/RTL_Al_vec.txt", alloc_vec);		
	
	#25rst		= 1'b0;
end

always #10 	clk 		= ~clk;

reg wr_datin, wr_frm_pp;	

reg 		wr_frm; 
reg 		cfg_done;
initial 	begin	

	cfg_dat_i	= 32'd0;
	cfg_adr_i  	= 2'b00;
	cfg_we_i		= 1'b1;
	cfg_stb_i	= 1'b0;

	wr_frm   	= 1'b0; 
	wr_datin 	= 1'b1;
	ack_i    	= 1'b1;
	lop_cnt  	= 0;
	alloc_ptr 	= 0;
	alloc_off	= 0;
	dat_ptr		= 0;
	dat_off		= 0;
	cfg_done  	= 1'b0;
	#600;
	forever begin
		@(posedge clk);				
		if (~(lop_cnt == NFRM)) begin
			dat_ptr		=0;
			alloc_ptr 	=0;
			STD = STD_vec[lop_cnt];
			MOD = MOD_vec[lop_cnt];
			NDS = NDS_vec[lop_cnt];
			LEN = LEN_vec[lop_cnt];
			case (STD)
				2'b00  : begin
								alloc_wps  	= 4;
								alloc_len  	= 4*NDS;
								config_dat 	= 32'd0;		
							end
				2'b01  : begin
								alloc_wps  	= 16;
								alloc_len 	= 16*NDS;
								config_dat 	= 32'd1;	
							end
				2'b10  : begin
								alloc_wps	= 128;
								alloc_len 	= 128*NDS;
								config_dat 	= 32'd2;	
							end
				2'b11  : begin
								alloc_len = 0;
								config_dat = 32'd3;	
							end
			default: 	begin
								alloc_len = 0;
								config_dat = 32'd3;	
							end
			endcase
			case (MOD)
				2'b00  	: config_dat[3:2]	= 2'b00;		
				2'b01  	: config_dat[3:2]	= 2'b01;	
				2'b10  	: config_dat[3:2] = 2'b10;								
				2'b11  	: config_dat[3:2] = 2'b11;								
			default		: config_dat[3:2]	= 2'b00;	
			endcase
			// configure the transmission in specified standard
			cfg_dat_i = config_dat;
			cfg_stb_i = 1'b1;
			@(posedge clk);
			cfg_dat_i = 32'd0;
			cfg_stb_i = 1'b0;
			alloc_ptr =0;
			
			//write allocation vector for first symbol.
			repeat(alloc_wps) begin				
				cfg_adr_i = 2'b01;			
				cfg_dat_i = alloc_vec[alloc_ptr + alloc_off];
				cfg_stb_i = 1'b1;						
				@(posedge clk);
				alloc_ptr = alloc_ptr + 1;	
			end
			cfg_done  = 1'b1;	
			
			// start frame 
			wr_frm   = 1'b1;
			dat_in 	<= datin[dat_ptr + dat_off];		

			//wait for frame 
			@(negedge cyc_o);	
			cfg_done		= 1'b0;
			dat_off 		= dat_off + LEN;
			alloc_off	= alloc_off + alloc_len;
			#1500;
			lop_cnt = lop_cnt +1;
		end
	end
end	

initial begin
	forever begin
		@(posedge clk);
		if (cfg_done & cfg_ack_o & (alloc_ptr == alloc_len)) begin
				cfg_adr_i = 2'b00;			
				cfg_dat_i = 32'd0;
				cfg_stb_i = 1'b0;		
			end
		else if (cfg_done & cfg_ack_o &(alloc_ptr<alloc_len)) begin
			cfg_adr_i = 2'b01;			
			cfg_dat_i = alloc_vec[alloc_ptr + alloc_off];
			cfg_stb_i = 1'b1;		
			alloc_ptr = alloc_ptr + 1;	
		end 
	end 
end
	
always @(posedge clk) begin	
	if(rst) 	begin
		dat_ptr <= 0;	
		dat_in <= datin[dat_ptr + dat_off];	
		wr_frm_pp <= 1'b0;
		end
	else if(wr_frm) begin
		cyc_i 	 <= 1'b1; 	
		wr_frm_pp <= wr_frm;
		
		if (~wr_datin) begin	
			stb_i		<= 1'b0;
			cyc_i		<= 1'b0;
			we_i 		<= 1'b0;
			end
		else if (~wr_frm_pp) begin
			wr_frm_pp <= wr_frm;
			dat_ptr 		<= dat_ptr+1;	
			stb_i		<= 1'b1;
			cyc_i		<= 1'b1;	
			we_i		<= 1'b1;	
			end
		else if ((dat_ptr == LEN)&(ack_o)) begin 
			we_i		<= 1'b0;
			stb_i		<= 1'b0;
			cyc_i		<= 1'b0;	
			wr_frm	<= 1'b0;
			end
		else if (ack_o) begin			
			dat_in 	<= datin[dat_ptr + dat_off];
			dat_ptr 		<= dat_ptr+1;	
			stb_i		<= 1'b1;
			cyc_i		<= 1'b1;
			we_i		<= 1'b1;	
			end	
		end			
	else begin
		wr_frm_pp <= wr_frm;
		we_i		<= 1'b0;
		stb_i		<= 1'b0;
		cyc_i		<= 1'b0;
		end	

end


integer datout_Re_fo, datout_Im_fo, datout_cnt, Pilots_datout_cnt;
integer Pilots_Insert_Re_fo, Pilots_Insert_Im_fo;
integer IFFT_Mod_Re_fo, IFFT_Mod_Im_fo;
initial begin
	datout_cnt = 0;	
	Pilots_datout_cnt = 0;
	datout_Re_fo = $fopen("./MATLAB/RTL_OFDM_TX_datout_Re.txt");		
	datout_Im_fo = $fopen("./MATLAB/RTL_OFDM_TX_datout_Im.txt");
	
	Pilots_Insert_Re_fo = $fopen("./MATLAB/RTL_OFDM_TX_Pilots_Insert_Re.txt");		
	Pilots_Insert_Im_fo = $fopen("./MATLAB/RTL_OFDM_TX_Pilots_Insert_Im.txt");
	
	IFFT_Mod_Re_fo = $fopen("./MATLAB/RTL_OFDM_TX_IFFT_Mod_Re.txt");		
	IFFT_Mod_Im_fo = $fopen("./MATLAB/RTL_OFDM_TX_IFFT_Mod_Im.txt");
	
	forever begin
		@(posedge clk);
		if ((we_o)&&(stb_o)&&(cyc_o)&&(ack_i)) begin
			$fwrite(datout_Re_fo,"%d ",$signed(dat_out[15:0]));
			$fwrite(datout_Im_fo,"%d ",$signed(dat_out[31:16]));
			datout_cnt = datout_cnt + 1;			
			end	
		if ((Pilots_Insert_we_o)&&(Pilots_Insert_stb_o)&&(Pilots_Insert_cyc_o)&&(IFFT_Mod_ack_o)) begin
			$fwrite(Pilots_Insert_Re_fo,"%d ",$signed(Pilots_Insert_dat_out[15:0]));
			$fwrite(Pilots_Insert_Im_fo,"%d ",$signed(Pilots_Insert_dat_out[31:16]));
			Pilots_datout_cnt = Pilots_datout_cnt + 1;			
			end
		if ((IFFT_Mod_we_o)&&(IFFT_Mod_stb_o)&&(IFFT_Mod_cyc_o)&&(IFFT_Mod_ack_i)) begin
			$fwrite(IFFT_Mod_Re_fo,"%d ",$signed(IFFT_Mod_dat_out[15:0]));
			$fwrite(IFFT_Mod_Im_fo,"%d ",$signed(IFFT_Mod_dat_out[31:16]));
			//datout_cnt = datout_cnt + 1;			
			end
	end
end

reg stop_chk;
initial  begin
	stop_chk = 1'b0;
	//#30000	stop_chk = 1'b1;
	forever begin
		@(posedge clk);				
		if (lop_cnt == NFRM) begin
			#100;
			stop_chk = 1'b1;
		end
	end
end
initial begin
	forever begin
	@(posedge clk);
	if (stop_chk)	begin
		$fclose(datout_Re_fo);
		$fclose(datout_Im_fo);
		
		$fclose(Pilots_Insert_Re_fo);
		$fclose(Pilots_Insert_Im_fo);
		
		$fclose(IFFT_Mod_Re_fo);
		$fclose(IFFT_Mod_Im_fo);
		$stop;
		end		
	end
end

endmodule

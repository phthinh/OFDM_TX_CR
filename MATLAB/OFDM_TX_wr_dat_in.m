clear all
close all

%dur  = 3.2e-6;  
STD_vec = [0  1 2 0];  % standard vector of transmited frames
MOD_vec = [0  1 2 3];  % standard vector of data modulation
NDS_vec = [16 4 2 4];  % number of symbols in each of transmited frames
NFRM = length(STD_vec);           % number of frame

%NS   = NDS*NFRM;    % number of symbols

NFFT_802_11 = 64;                   % Number of FFT points  IEEE-802-11
NC_802_11   = 48;                   % Number of subcarriers IEEE-802-11
CP_802_11   = (1/4)*NFFT_802_11;    % cyclic prefix length  IEEE-802-11
PRE_802_11  = 4;                    % preamble symbol = 1   IEEE-802-11


NFFT_802_16 = 256;                   % Number of FFT points  IEEE-802-16
NC_802_16   = 192;                  % Number of subcarriers IEEE-802-16
CP_802_16   = (1/8)*NFFT_802_16;    % cyclic prefix length  IEEE-802-16
PRE_802_16  = 2;                    % preamble symbol = 1   IEEE-802-16

NFFT_802_22 = 2048;                 % Number of FFT points  IEEE-802-22
NC_802_22   = 1440;                 % Number of subcarriers IEEE-802-22
CP_802_22   = (1/4)*NFFT_802_22;    % cyclic prefix length  IEEE-802-22
PRE_802_22  = 1;                    % preamble symbol = 1   IEEE-802-22


%NP   = 240;         % Number of pilots in symbol


% data in for TX ==========================================================
bit_symbols = [];
alloc_vec   = [];
alloc_reg   = [];
for frm = 1:NFRM,
    STD = STD_vec(frm);
    NDS = NDS_vec(frm);
    MOD = MOD_vec(frm);
    switch(STD)
        case 0
            NC      = NC_802_11;
            NFFT    = NFFT_802_11;
        case 1
            NC      = NC_802_16;
            NFFT    = NFFT_802_16;
        case 2
            NC      = NC_802_22; 
            NFFT    = NFFT_802_22;
    end
    switch(MOD)
        case 1
            bit_symbol_frm = round(1*rand(1, NDS*(NC)));            
        case 0
            bit_symbol_frm = round(3*rand(1, NDS*(NC)));
        case 2
            bit_symbol_frm = round(15*rand(1, NDS*(NC)));
        case 3
            bit_symbol_frm = round(63*rand(1, NDS*(NC)));
    end
         
    LEN_vec(frm) = NDS*NC;

    pilots_CR;
    switch(STD)
        case 0
            alloc_vec_frm = Al_vec_802_11;        
        case 1
            alloc_vec_frm = Al_vec_802_16; 
        case 2
            alloc_vec_frm = Al_vec_802_22; 
    end

    jj = 1;
    for nn = 0:NDS-1,
        for ii = NFFT:-16:16,
            alloc_reg_frm(jj) = alloc_vec_frm(ii + nn*NFFT)   *2^30 + ...
                                alloc_vec_frm(ii + nn*NFFT-1) *2^28 + ...
                                alloc_vec_frm(ii + nn*NFFT-2) *2^26 + ...
                                alloc_vec_frm(ii + nn*NFFT-3) *2^24 + ...
                                alloc_vec_frm(ii + nn*NFFT-4) *2^22 + ...
                                alloc_vec_frm(ii + nn*NFFT-5) *2^20 + ...
                                alloc_vec_frm(ii + nn*NFFT-6) *2^18 + ...
                                alloc_vec_frm(ii + nn*NFFT-7) *2^16 + ...
                                alloc_vec_frm(ii + nn*NFFT-8) *2^14 + ...
                                alloc_vec_frm(ii + nn*NFFT-9) *2^12 + ...
                                alloc_vec_frm(ii + nn*NFFT-10)*2^10 + ...
                                alloc_vec_frm(ii + nn*NFFT-11)*2^08 + ...
                                alloc_vec_frm(ii + nn*NFFT-12)*2^06 + ...
                                alloc_vec_frm(ii + nn*NFFT-13)*2^04 + ...
                                alloc_vec_frm(ii + nn*NFFT-14)*2^02 + ...
                                alloc_vec_frm(ii + nn*NFFT-15);
            jj=jj+1;
        end
    end
    bit_symbols = [bit_symbols bit_symbol_frm];
    alloc_vec   = [alloc_vec alloc_vec_frm];
    alloc_reg   = [alloc_reg alloc_reg_frm];
end

%write data to file =======================================================
fid = fopen('OFDM_TX_bit_symbols_Len.txt', 'w');
fprintf(fid, '%d ', NFRM);
fprintf(fid, '%d ', STD_vec);
fprintf(fid, '%d ', MOD_vec);
fprintf(fid, '%d ', NDS_vec);
fprintf(fid, '%d ', LEN_vec);
fprintf(fid, '%d ', length(bit_symbols));
fprintf(fid, '%d ', length(alloc_reg));
fclose(fid);

fid = fopen('OFDM_TX_bit_symbols.txt', 'w');
fprintf(fid, '%d ', bit_symbols);
fclose(fid);

fid = fopen('RTL_OFDM_TX_bit_symbols.txt', 'w');
fprintf(fid, '%x ', bit_symbols);
fclose(fid);

fid = fopen('Al_vec.txt', 'w');
fprintf(fid, '%d ', alloc_vec);
fclose(fid);

fid = fopen('RTL_Al_vec.txt', 'w');
fprintf(fid, '%8x ', alloc_reg);
fclose(fid);

%write Preamble ===========================================================
preamble_CR;   

preamble_nor = pre_802_11;
Preamble_rtl = preamble_nor .*(2^15);
Preamble_Re  = typecast(int16(real(Preamble_rtl)),'uint16');
Preamble_Im  = typecast(int16(imag(Preamble_rtl)),'uint16');
Pre = uint32(Preamble_Im) * (2^16) + uint32(Preamble_Re);
fid = fopen('../MY_SOURCES/Pre_802_11.txt', 'w');
fprintf(fid, '%8x ', Pre);
fclose(fid);

preamble_nor = pre_802_16;
Preamble_rtl = preamble_nor .*(2^15);
Preamble_Re  = typecast(int16(real(Preamble_rtl)),'uint16');
Preamble_Im  = typecast(int16(imag(Preamble_rtl)),'uint16');
Pre = uint32(Preamble_Im) * (2^16) + uint32(Preamble_Re);
fid = fopen('../MY_SOURCES/Pre_802_16.txt', 'w');
fprintf(fid, '%8x ', Pre);
fclose(fid);

preamble_nor = pre_802_22;
Preamble_rtl = preamble_nor .*(2^15);
Preamble_Re  = typecast(int16(real(Preamble_rtl)),'uint16');
Preamble_Im  = typecast(int16(imag(Preamble_rtl)),'uint16');
Pre = uint32(Preamble_Im) * (2^16) + uint32(Preamble_Re);
fid = fopen('../MY_SOURCES/Pre_802_22.txt', 'w');
fprintf(fid, '%8x ', Pre);
fclose(fid);

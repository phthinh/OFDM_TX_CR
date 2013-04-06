% this is used for test each standard
clear all
close all

%dur  = 3.2e-6;  
STD  = 2;
NFRM = 1;           % number of frame
NDS  = 2;           % Number of Data symbol per frame per standard
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
bit_symbols = round(3*rand(1, NDS*(NC)));
Len = NDS*NC;

%write data to file =======================================================
fid = fopen('OFDM_TX_bit_symbols_Len.txt', 'w');
fprintf(fid, '%d ', NFRM);
fprintf(fid, '%d ', NDS);
fprintf(fid, '%d ', STD);
fprintf(fid, '%d ', Len);
fclose(fid);

fid = fopen('OFDM_TX_bit_symbols.txt', 'w');
fprintf(fid, '%d ', bit_symbols);
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

pilots_CR;
switch(STD)
    case 0
        alloc_vec = Al_vec_802_11;        
    case 1
        alloc_vec = Al_vec_802_16; 
    case 2
        alloc_vec = Al_vec_802_22; 
end

jj = 1;
for nn = 0:NDS-1,
    for ii = NFFT:-16:16,
        alloc_reg(jj) = alloc_vec(ii + nn*NFFT)   *2^30 + ...
                        alloc_vec(ii + nn*NFFT-1) *2^28 + ...
                        alloc_vec(ii + nn*NFFT-2) *2^26 + ...
                        alloc_vec(ii + nn*NFFT-3) *2^24 + ...
                        alloc_vec(ii + nn*NFFT-4) *2^22 + ...
                        alloc_vec(ii + nn*NFFT-5) *2^20 + ...
                        alloc_vec(ii + nn*NFFT-6) *2^18 + ...
                        alloc_vec(ii + nn*NFFT-7) *2^16 + ...
                        alloc_vec(ii + nn*NFFT-8) *2^14 + ...
                        alloc_vec(ii + nn*NFFT-9) *2^12 + ...
                        alloc_vec(ii + nn*NFFT-10)*2^10 + ...
                        alloc_vec(ii + nn*NFFT-11)*2^08 + ...
                        alloc_vec(ii + nn*NFFT-12)*2^06 + ...
                        alloc_vec(ii + nn*NFFT-13)*2^04 + ...
                        alloc_vec(ii + nn*NFFT-14)*2^02 + ...
                        alloc_vec(ii + nn*NFFT-15);
        jj=jj+1;
    end
end

%alloc_vec = repmat(alloc_vec,1,NDS);
fid = fopen('Al_vec.txt', 'w');
fprintf(fid, '%d ', alloc_vec);
fclose(fid);

fid = fopen('RTL_Al_vec.txt', 'w');
fprintf(fid, '%8x ', alloc_reg);
fclose(fid);
clear all
close all

%dur  = 3.2e-6;  
NFRM = 3;           % number of frame
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
bit_symbols = round(3*rand(1, NDS*(NC_802_11 + NC_802_16 + NC_802_22)));
Len = [(NDS*NC_802_11) (NDS*NC_802_16) (NDS*NC_802_22)];

%write data to file =======================================================
fid = fopen('OFDM_TX_bit_symbols_Len.txt', 'w');
fprintf(fid, '%d ', NFRM);
fprintf(fid, '%d ', NDS);
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
% Pilot_seq = reshape(pils, 1, 28*240);
% Pilot_seq = (Pilot_seq(1:128)<0)*1;
% fid = fopen('../MY_SOURCES/Pilot_seq.txt', 'w');
% fprintf(fid, '%d ', Pilot_seq);
% fclose(fid);

%Alloc_seq = [Al_Vec(2:841,1:5); Al_Vec(1209:2048,1:5)];
%Alloc_seq = Al_Vec(:,1:2);
%Alloc_seq = reshape(Alloc_seq,1,2048*2);
fid = fopen('../MY_SOURCES/Al_vec.txt', 'w');
fprintf(fid, '%d ', alloc_vec);
fclose(fid);
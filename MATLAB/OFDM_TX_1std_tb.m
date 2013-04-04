% this is used for test each standard
close all
%dur  = 3.2e-6;  
%NFRM = 3;           % number of frame
%NDS  = 2;           % Number of Data symbol per frame per standard
NS   = NDS*NFRM;    % number of symbols per standard

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

% Read data in ============================================================
datin_fid = fopen('OFDM_TX_bit_symbols.txt', 'r');
bit_symbols = fscanf(datin_fid, '%d ');
fclose(datin_fid);

datin_fid = fopen('../MY_SOURCES/Al_vec.txt', 'r');
alloc_vec = fscanf(datin_fid, '%d ');
fclose(datin_fid);

datin_fid = fopen('OFDM_TX_bit_symbols_Len.txt', 'r');
para = fscanf(datin_fid, '%d ');
NFRM = para(1);
NDS  = para(2);
STD  = para(3);
Len  = para(4:length(para));

fclose(datin_fid);

%Read data out of RTL ====================================================
datout_fid = fopen('RTL_OFDM_TX_datout_Re.txt', 'r');
Datout_Re_rtl = fscanf(datout_fid, '%d ');
fclose(datout_fid);
datout_fid = fopen('RTL_OFDM_TX_datout_Im.txt', 'r');
Datout_Im_rtl = fscanf(datout_fid, '%d ');
fclose(datout_fid);
Datout_rtl = (Datout_Re_rtl./2^15) + 1i*(Datout_Im_rtl./2^15);

datout_fid = fopen('RTL_OFDM_TX_Pilots_Insert_Re.txt', 'r');
Pilots_Insert_Re_rtl = fscanf(datout_fid, '%d ');
fclose(datout_fid);
datout_fid = fopen('RTL_OFDM_TX_Pilots_Insert_Im.txt', 'r');
Pilots_Insert_Im_rtl = fscanf(datout_fid, '%d ');
fclose(datout_fid);
Pilots_Insert_rtl = (Pilots_Insert_Re_rtl./2^15) + 1i*(Pilots_Insert_Im_rtl./2^15);

datout_fid = fopen('RTL_OFDM_TX_IFFT_Mod_Re.txt', 'r');
IFFT_Mod_Re_rtl = fscanf(datout_fid, '%d ');
fclose(datout_fid);
datout_fid = fopen('RTL_OFDM_TX_IFFT_Mod_Im.txt', 'r');
IFFT_Mod_Im_rtl = fscanf(datout_fid, '%d ');
fclose(datout_fid);
IFFT_Mod_rtl = (IFFT_Mod_Re_rtl./2^15) + 1i*(IFFT_Mod_Im_rtl./2^15);

% Simulate with data in ===================================================
%bit_symbols_frm1 = bit_symbols(1:Len(1));
%bit_symbols_frm2 = bit_symbols(Len(1) + (1:Len(2)));
%bit_symbols_frm3 = bit_symbols(Len(1) +  Len(2)+ (1:Len(3)));
%QPSK =====================================================================
QPSK = 1- 2.*mod(bit_symbols,2) + 1i *(1- 2.*floor(bit_symbols/2));
switch(STD)
    case 0
        NC = NC_802_11;
    case 1
        NC = NC_802_16;
    case 2
        NC = NC_802_22; 
end
QPSK_frm = reshape(QPSK, NC, NDS);
%insert subcarriers & pilots ==============================================
% pilot ===================================================================
pilots_CR;
switch(STD)
    case 0
        NFFT = NFFT_802_11;
    case 1
        NFFT = NFFT_802_16;
    case 2
        NFFT = NFFT_802_22; 
end
symbol_frm    = zeros(NFFT,NDS);
alloc_vec_frm = reshape(alloc_vec(1:NDS*NFFT), NFFT,NDS);
for ii = 1:NDS,
    dat_cnt = 1;
    for jj =1:NFFT,
        if (alloc_vec_frm(jj,ii) == 1),
            symbol_frm(jj,ii) = 1;           
        elseif (alloc_vec_frm(jj,ii) == 3),
            symbol_frm(jj,ii) = -1;
        elseif(alloc_vec_frm(jj,ii) == 2),
            symbol_frm(jj,ii) = QPSK_frm(dat_cnt,ii);
            dat_cnt       = dat_cnt +1;
        end
    end
end

Pilots_Insert_sim = reshape(symbol_frm, 1, NFFT*NDS) ;
%IFFT =================================================================
tx_d_frm =  ifft(symbol_frm, NFFT);
%Add CP ===============================================================
switch(STD)
    case 0
        CP = CP_802_11;
    case 1
        CP = CP_802_16;
    case 2
        CP = CP_802_22; 
end
tx_d_frm = [tx_d_frm(NFFT-CP+1: NFFT,:); tx_d_frm];

IFFT_Mod_sim = reshape(tx_d_frm, 1, (NFFT+CP)*NDS);
%Add Preamble =========================================================
preamble_CR; 
switch(STD)
    case 0
        preamble_nor = pre_802_11; 
        PRE = PRE_802_11;
    case 1
        preamble_nor = pre_802_16; 
        PRE = PRE_802_16;
    case 2
        preamble_nor = pre_802_22; 
        PRE = PRE_802_22;
end
preamb = reshape(preamble_nor, (NFFT+CP), PRE);
tx_out_frm(:,1:PRE)         = preamb(:,1:PRE);                  
tx_out_frm(:,PRE+(1:NDS))   = tx_d_frm(:,1:NDS);            




Datout_sim = reshape(tx_out_frm, 1, (NFFT+CP)*(PRE + NDS));


% Plotting ================================================================
figure(1);
plot(1:length(Pilots_Insert_sim), real(Pilots_Insert_sim),'o-b');
hold on
plot(1:length(Pilots_Insert_rtl), real(Pilots_Insert_rtl),'x-r');
 ylim([-3 3]);
title('comparison of Pilots\_Insert output');
legend('Pilots\_Insert\_sim','Pilots\_Insert\_rtl');

figure(2);
plot(1:length(IFFT_Mod_sim), imag(IFFT_Mod_sim),'o-b');
hold on
plot(1:length(IFFT_Mod_rtl), imag(IFFT_Mod_rtl),'x-r');
title('comparison of IFFT\_Mod output');
legend('IFFT\_Mod\_sim','IFFT\_Mod\_rtl');

figure(3);
plot(1:length(Datout_sim), real(Datout_sim),'o-b');
hold on
plot(1:length(Datout_rtl), real(Datout_rtl),'x-r');
title('comparison of Data output of transmitter');
legend('Datout\_sim','Datout\_rtl');


close all
%dur  = 3.2e-6;  
NFRM = 3;           % number of frame
NDS  = 2;           % Number of Data symbol per frame per standard
NS   = NDS*NFRM;    % number of symbols per standard

NFFT_802_11 = 64;                   % Number of FFT points  IEEE-802-11
NC_802_11   = 48;                   % Number of subcarriers IEEE-802-11
CP_802_11   = (1/4)*NFFT_802_11;    % cyclic prefix length  IEEE-802-11
PRE_802_11  = 4;                    % preamble symbol = 1   IEEE-802-11


NFFT_802_16 = 256                   % Number of FFT points  IEEE-802-16
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
Len  = para(3:length(para));

fclose(datin_fid);

% %Read data out of RTL ====================================================
% datout_fid = fopen('RTL_OFDM_TX_datout_Re.txt', 'r');
% Datout_Re_rtl = fscanf(datout_fid, '%d ');
% fclose(datout_fid);
% datout_fid = fopen('RTL_OFDM_TX_datout_Im.txt', 'r');
% Datout_Im_rtl = fscanf(datout_fid, '%d ');
% fclose(datout_fid);
% Datout_rtl = (Datout_Re_rtl./2^15) + 1i*(Datout_Im_rtl./2^15);
% 
% datout_fid = fopen('RTL_OFDM_TX_Pilots_Insert_Re.txt', 'r');
% Pilots_Insert_Re_rtl = fscanf(datout_fid, '%d ');
% fclose(datout_fid);
% datout_fid = fopen('RTL_OFDM_TX_Pilots_Insert_Im.txt', 'r');
% Pilots_Insert_Im_rtl = fscanf(datout_fid, '%d ');
% fclose(datout_fid);
% Pilots_Insert_rtl = (Pilots_Insert_Re_rtl./2^15) + 1i*(Pilots_Insert_Im_rtl./2^15);
% 
% datout_fid = fopen('RTL_OFDM_TX_IFFT_Mod_Re.txt', 'r');
% IFFT_Mod_Re_rtl = fscanf(datout_fid, '%d ');
% fclose(datout_fid);
% datout_fid = fopen('RTL_OFDM_TX_IFFT_Mod_Im.txt', 'r');
% IFFT_Mod_Im_rtl = fscanf(datout_fid, '%d ');
% fclose(datout_fid);
% IFFT_Mod_rtl = (IFFT_Mod_Re_rtl./2^15) + 1i*(IFFT_Mod_Im_rtl./2^15);

% Simulate with data in ===================================================
%bit_symbols_frm1 = bit_symbols(1:Len(1));
%bit_symbols_frm2 = bit_symbols(Len(1) + (1:Len(2)));
%bit_symbols_frm3 = bit_symbols(Len(1) +  Len(2)+ (1:Len(3)));
%QPSK =====================================================================
QPSK = 1- 2.*mod(bit_symbols,2) + 1i *(1- 2.*floor(bit_symbols/2));
QPSK_frm1 = reshape(QPSK(1:Len(1))                      ,NC_802_11,NDS);
QPSK_frm2 = reshape(QPSK(Len(1) + (1:Len(2)))           ,NC_802_16,NDS);
QPSK_frm3 = reshape(QPSK(Len(1) +  Len(2)+ (1:Len(3)))  ,NC_802_22,NDS);
%insert subcarriers & pilots ==============================================
% pilot ===================================================================
pilots_CR;

symbol_frm1    = zeros(NFFT_802_11,NDS);
alloc_vec_frm1 = reshape(alloc_vec(1:NDS*NFFT_802_11), NFFT_802_11,NDS);
alloc_vec(1:NDS*NFFT_802_11) = [];
for ii = 1:NDS,
    dat_cnt = 1;
    for jj =1:NFFT_802_11,
        if (alloc_vec_frm1(jj,ii) == 1),
            symbol_frm1(jj,ii) = 1;           
        elseif (alloc_vec_frm1(jj,ii) == 3),
            symbol_frm1(jj,ii) = -1;
        elseif(alloc_vec_frm1(jj,ii) == 2),
            symbol_frm1(jj,ii) = QPSK_frm1(dat_cnt,ii);
            dat_cnt       = dat_cnt +1;
        end
    end
end

symbol_frm2    = zeros(NFFT_802_16,NDS);
alloc_vec_frm2 = reshape(alloc_vec(1:NDS*NFFT_802_16),NFFT_802_16,NDS);
alloc_vec(1:NDS*NFFT_802_16) = [];
for ii = 1:NDS,
    dat_cnt = 1;
    for jj =1:NFFT_802_16,
        if (alloc_vec_frm2(jj,ii) == 1),
            symbol_frm2(jj,ii) = 1;           
        elseif (alloc_vec_frm2(jj,ii) == 3),
            symbol_frm2(jj,ii) = -1;
        elseif(alloc_vec_frm2(jj,ii) == 2),
            symbol_frm2(jj,ii) = QPSK_frm2(dat_cnt,ii);
            dat_cnt       = dat_cnt +1;
        end
    end
end

symbol_frm3    = zeros(NFFT_802_22,NDS);
alloc_vec_frm3 = reshape(alloc_vec(1:NDS*NFFT_802_22),NFFT_802_22,NDS);
alloc_vec(1:NDS*NFFT_802_22) = [];
for ii = 1:NDS,
    dat_cnt = 1;
    for jj =1:NFFT_802_22,
        if (alloc_vec_frm3(jj,ii) == 1),
            symbol_frm3(jj,ii) = 1;           
        elseif (alloc_vec_frm3(jj,ii) == 3),
            symbol_frm3(jj,ii) = -1;
        elseif(alloc_vec_frm3(jj,ii) == 2),
            symbol_frm3(jj,ii) = QPSK_frm3(dat_cnt,ii);
            dat_cnt       = dat_cnt +1;
        end
    end
end

Pilots_Insert_sim = [reshape(symbol_frm1, 1, NFFT_802_11*NDS) ...
                     reshape(symbol_frm2, 1, NFFT_802_16*NDS) ...   
                     reshape(symbol_frm3, 1, NFFT_802_22*NDS)] ;
%IFFT =================================================================
tx_d_frm1 =  ifft(symbol_frm1, NFFT_802_11);
tx_d_frm2 =  ifft(symbol_frm2, NFFT_802_16);
tx_d_frm3 =  ifft(symbol_frm3, NFFT_802_22);
%Add CP ===============================================================
tx_d_frm1 = [tx_d_frm1(NFFT_802_11-CP_802_11+1: NFFT_802_11,:); tx_d_frm1];
tx_d_frm2 = [tx_d_frm2(NFFT_802_16-CP_802_16+1: NFFT_802_16,:); tx_d_frm2];
tx_d_frm3 = [tx_d_frm3(NFFT_802_22-CP_802_22+1: NFFT_802_22,:); tx_d_frm3];

IFFT_Mod_sim = [reshape(tx_d_frm1, 1, (NFFT_802_11+CP_802_11)*NDS) ...
                reshape(tx_d_frm2, 1, (NFFT_802_16+CP_802_16)*NDS) ...   
                reshape(tx_d_frm3, 1, (NFFT_802_22+CP_802_22)*NDS)] ;
%Add Preamble =========================================================
preamble_CR; 

preamble_nor = pre_802_11; 
preamb = reshape(preamble_nor, (NFFT_802_11+CP_802_11), PRE_802_11);
tx_out_frm1(:,1:PRE_802_11)         = preamb(:,1:PRE_802_11);                  
tx_out_frm1(:,PRE_802_11+(1:NDS))   = tx_d_frm1(:,1:NDS);            

preamble_nor = pre_802_16; 
preamb = reshape(preamble_nor, (NFFT_802_16+CP_802_16), PRE_802_16);
tx_out_frm2(:,1:PRE_802_16)         = preamb(:,1:PRE_802_16);                  
tx_out_frm2(:,PRE_802_16+(1:NDS))   = tx_d_frm2(:,1:NDS);

preamble_nor =2*pre_802_22; 
preamb = reshape(preamble_nor, (NFFT_802_22+CP_802_22), PRE_802_22);
tx_out_frm3(:,1:PRE_802_22)         = preamb(:,1:PRE_802_22);                  
tx_out_frm3(:,PRE_802_22+(1:NDS))   = tx_d_frm3(:,1:NDS);


Datout_sim = [reshape(tx_out_frm1, 1, (NFFT_802_11+CP_802_11)*(PRE_802_11 + NDS)) ...
              reshape(tx_out_frm2, 1, (NFFT_802_16+CP_802_16)*(PRE_802_16 + NDS)) ...   
              reshape(tx_out_frm3, 1, (NFFT_802_22+CP_802_22)*(PRE_802_22 + NDS))] ;


% Plotting ================================================================
figure(1);
plot(1:length(Pilots_Insert_sim), real(Pilots_Insert_sim),'o-b');
% hold on
% plot(1:length(Pilots_Insert_rtl), real(Pilots_Insert_rtl),'x-r');
%  ylim([-3 3]);
% title('comparison of Pilots\_Insert output');
% legend('Pilots\_Insert\_sim','Pilots\_Insert\_rtl');

figure(2);
plot(1:length(IFFT_Mod_sim), imag(IFFT_Mod_sim),'o-b');
% hold on
% plot(1:length(IFFT_Mod_rtl), imag(IFFT_Mod_rtl),'x-r');
% title('comparison of IFFT\_Mod output');
% legend('IFFT\_Mod\_sim','IFFT\_Mod\_rtl');

figure(3);
plot(1:length(Datout_sim), real(Datout_sim),'o-b');
hold on
% plot(1:length(Datout_rtl), real(Datout_rtl),'x-r');
% title('comparison of Data output of transmitter');
% legend('Datout\_sim','Datout\_rtl');


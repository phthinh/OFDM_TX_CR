close all
%dur  = 3.2e-6;  
%NFRM = 3;           % number of frame
%NDS  = 2;           % Number of Data symbol per frame per standard
%NS   = NDS*NFRM;    % number of symbols per standard

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

datin_fid = fopen('Al_vec.txt', 'r');
alloc_vec = fscanf(datin_fid, '%d ');
fclose(datin_fid);

datin_fid   = fopen('OFDM_TX_bit_symbols_Len.txt', 'r');
para        = fscanf(datin_fid, '%d ');
NFRM        = para(1);
para(1)     =[];
STD_vec     = para(1:NFRM);
para(1:NFRM)=[];
MOD_vec     = para(1:NFRM);
para(1:NFRM)=[];
NDS_vec     = para(1:NFRM);
para(1:NFRM)=[];
LEN_vec     = para(1:NFRM);

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
Pilots_Insert_sim   = [];
IFFT_Mod_sim        = [];
Datout_sim          = [];
for frm = 1:NFRM,
    STD = STD_vec(frm);
    MOD = MOD_vec(frm);
    NDS = NDS_vec(frm);
    LEN = LEN_vec(frm);
    
    preamble_CR; 
    switch(STD)
        case 0
            NC              = NC_802_11;
            NFFT            = NFFT_802_11;
            CP              = CP_802_11;
            preamble_nor    = pre_802_11; 
            PRE             = PRE_802_11;
        case 1
            NC              = NC_802_16;
            NFFT            = NFFT_802_16;
            CP              = CP_802_16;
            preamble_nor    = pre_802_16; 
            PRE             = PRE_802_16;
        case 2
            NC              = NC_802_22; 
            NFFT            = NFFT_802_22;
            CP              = CP_802_22;
            preamble_nor    = pre_802_22; 
            PRE             = PRE_802_22;
    end
    %Data modulation ======================================================
    bit_symbol_frm = bit_symbols(1:LEN);
    bit_symbols(1:LEN) =[];
    
    if(STD == 1),       % IEEE 802.16
        switch(MOD)
            case 1  %BPSK 
                    BPSK = 1 - 2.*mod(bit_symbol_frm,2);
                    dat_mod = BPSK;        
            case 0  %QPSK 
                    QPSK = 1-2.*floor(bit_symbol_frm/2) + 1i *(1-2.*mod(bit_symbol_frm,2));
                    QPSK = QPSK *(1/sqrt(2));   
                    dat_mod = QPSK;  
            case 2  %QAM16 
                    constel = [-3 -1 1 3] * sqrt(1/10);
                    reorder = [ 3  4 2 1];
                    Q_cons  = mod(bit_symbol_frm,4);
                    I_cons  = floor(bit_symbol_frm./4);
                    QAM16   = constel(reorder(1+I_cons)) + 1i* constel(reorder(1+Q_cons));     
                    dat_mod = QAM16;  
            case 3  %QAM64 
                    constel = [-sqrt(42) -5 -3 -1 1 3 5 sqrt(42)] * sqrt(1/42);
                    reorder = [6 5 7 8 3 4 2 1];
                    Q_cons  = mod(bit_symbol_frm,8);
                    I_cons  = floor(bit_symbol_frm./8);
                    QAM64   = constel(reorder(1+I_cons)) + 1i* constel(reorder(1+Q_cons));    
                    dat_mod = QAM64;         
        end
    else
        switch(MOD)
            case 1  %BPSK 
                    BPSK = 2.*mod(bit_symbol_frm,2)-1;
                    dat_mod = BPSK;        
            case 0  %QPSK 
                    QPSK = 2.*mod(bit_symbol_frm,2)-1 + 1i *(2.*floor(bit_symbol_frm/2)-1);
                    QPSK = QPSK *(1/sqrt(2));   
                    dat_mod = QPSK;  
            case 2  %QAM16 
                    constel = [-3 -1 1 3] * sqrt(1/10);
                    reorder = [1 4 2 3];
                    I_cons  = mod(bit_symbol_frm,4);
                    Q_cons  = floor(bit_symbol_frm./4);
                    QAM16   = constel(reorder(1+I_cons)) + 1i* constel(reorder(1+Q_cons));     
                    dat_mod = QAM16;  
            case 3  %QAM64 
                    constel = [-sqrt(42) -5 -3 -1 1 3 5 sqrt(42)] * sqrt(1/42);
                    reorder = [1 8 4 5 2 7 3 6];
                    I_cons  = mod(bit_symbol_frm,8);
                    Q_cons  = floor(bit_symbol_frm./8);
                    QAM64   = constel(reorder(1+I_cons)) + 1i* constel(reorder(1+Q_cons));    
                    dat_mod = QAM64;                        
        end
    end
    
    dat_mod_frm = reshape(dat_mod, NC, NDS);

    %insert subcarriers & pilots ==============================================
    % pilot ===================================================================
    alloc_vec_frm            = alloc_vec(1:(NFFT*NDS));
    alloc_vec(1:(NFFT*NDS))  = [];
    
    symbol_frm    = zeros(NFFT,NDS);    
    alloc_vec_frm = reshape(alloc_vec_frm, NFFT, NDS);
    
    for ii = 1:NDS,
        dat_cnt = 1;
        for jj =1:NFFT,
            if (alloc_vec_frm(jj,ii) == 1),
                symbol_frm(jj,ii) = 1;           
            elseif (alloc_vec_frm(jj,ii) == 3),
                symbol_frm(jj,ii) = -1;
            elseif(alloc_vec_frm(jj,ii) == 2),
                symbol_frm(jj,ii) = dat_mod_frm(dat_cnt,ii);
                dat_cnt       = dat_cnt +1;
            end
        end
    end
    Pilots_Insert_frm = reshape(symbol_frm, 1, NFFT*NDS);
    
    %IFFT =================================================================
    tx_d_frm =  ifft(symbol_frm, NFFT);
    
    %Add CP ===============================================================
    tx_d_frm        = [tx_d_frm(NFFT-CP+1: NFFT,:); tx_d_frm];

    IFFT_Mod_frm    = reshape(tx_d_frm, 1, (NFFT+CP)*NDS);
    
    %Add Preamble =========================================================
    preamb = reshape(preamble_nor, (NFFT+CP), PRE);
    tx_out_frm                  = [];
    tx_out_frm(:,1:PRE)         = preamb(:,1:PRE);                  
    tx_out_frm(:,PRE+(1:NDS))   = tx_d_frm(:,1:NDS);
    
    Datout_frm = reshape(tx_out_frm, 1, (NFFT+CP)*(PRE + NDS));

    
    Pilots_Insert_sim   = [Pilots_Insert_sim Pilots_Insert_frm];
    IFFT_Mod_sim        = [IFFT_Mod_sim IFFT_Mod_frm];
    Datout_sim          = [Datout_sim Datout_frm];
end
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
title('Verifying Data Output of Multi-Standard CR Transmitter (WLAN/WMAN/WRAN)');
xlabel('Samples');
ylabel('Magnitude');
legend('Datout\_sim','Datout\_rtl');


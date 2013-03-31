
Pils_802_16 = zeros(8, NDS);               % calculate pilots for NDS symbols
init = [0 0 1 1 1 1 1 1 1 1 1];

for ii = 1:1:NDS,
    Wk =  init(11);
    Pils_802_16(1,ii)=1-2*(1-Wk);
    Pils_802_16(2,ii)=1-2*(1-Wk);
    Pils_802_16(6,ii)=1-2*(1-Wk);
    Pils_802_16(8,ii)=1-2*(1-Wk);
    
    Pils_802_16(3,ii)=1-2*Wk;
    Pils_802_16(4,ii)=1-2*Wk;
    Pils_802_16(5,ii)=1-2*Wk;
    Pils_802_16(7,ii)=1-2*Wk;
    init = [xor(init(9),Wk) init(1:10)];
end

%Pils_802_16 = Pils_802_16 ./ sqrt(2);

Al_vec_802_16 = 2*ones(NFFT_802_16, NDS);
Al_vec_802_16(1,:) = zeros(1, NDS);
Pil_pos_vec_802_16 = [13 38 63 88 168 193 218 243];
Al_vec_802_16(1+Pil_pos_vec_802_16,:) = ones(8, NDS);
Al_vec_802_16(102:156,:) = zeros(55, NDS);
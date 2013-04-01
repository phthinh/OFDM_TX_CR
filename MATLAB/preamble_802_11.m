short_sym = zeros(64,1);
short_sym (5) = -1.472 - 1i*1.472;
short_sym (9) = -1.472 - 1i*1.472;
short_sym (13)=  1.472 + 1i*1.472;
short_sym (17)=  1.472 + 1i*1.472;
short_sym (21)=  1.472 + 1i*1.472;
short_sym (25)=  1.472 + 1i*1.472;
short_sym (41)=  1.472 + 1i*1.472;

short_sym (45)= -1.472 - 1i*1.472;
short_sym (49)=  1.472 + 1i*1.472;
short_sym (53)= -1.472 - 1i*1.472;
short_sym (57)= -1.472 - 1i*1.472;
short_sym (61)=  1.472 + 1i*1.472;

STS_802_11 = ifft(short_sym,64);
short_peamble_802_11 = [STS_802_11(49:64).' STS_802_11.' STS_802_11(49:64).' STS_802_11.'];
%short_pre = short_pre ./ max(short_pre);
long_sym = [0 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1  1  1 -1 -1  1 -1  1 -1 1 1 1 1 ...
            0 0  0  0 0 0  0 0  0 0  0 ... 
              1  1 -1 -1 1 1 -1 1 -1 1  1  1  1  1  1 -1 -1  1  1 -1  1 -1  1 1 1 1 ].'; 
Tlong =  ifft(long_sym,64);

long_preamble_802_11 = [Tlong(33:64).'  Tlong.' Tlong.'];

pre_802_11 = [short_peamble_802_11 long_preamble_802_11];
%long_pre = long_pre ./ max(long_pre);
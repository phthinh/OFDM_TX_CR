% Generate allocation vector and Pillot vector for 28 OFDM symbols

P_seed = [0 1 1 0 1 1 1 0 0 0 1 0 1 0 1]; % pilot seed, MSB on left
Pils_802_22 = zeros(28,NDS);
for ii = 1:NDS,
    for jj = 1:240,
        Pils_802_22(ii,jj)= xor(P_seed(1),P_seed(2));
        P_seed = [P_seed(2:15) Pils_802_22(ii,jj)];
    end
end
Pils_802_22 = Pils_802_22.';

P_pattern=[ 1 2 2 2 2 2 2;...
            2 2 2 1 2 2 2;...
            2 2 2 2 2 1 2;...
            2 1 2 2 2 2 2;...
            2 2 2 2 1 2 2;...
            2 2 2 2 2 2 1;...
            2 2 1 2 2 2 2];

Al_Vec = [zeros(28,1) repmat(P_pattern, 4,120) zeros(28,367) repmat(P_pattern,4,120)].';
Al_vec_802_22 = Al_Vec(:,1:NDS);
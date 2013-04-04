pilots_802_11;
pilots_802_16;
pilots_802_22;

for ii = 1:NDS,
    pil_ptr = 1;
    for jj = 1:NFFT_802_11,
        if (Al_vec_802_11(jj,ii) == 1)
            if (Pils_802_11(pil_ptr) == 0)
                Al_vec_802_11(jj,ii) = 3;
            end
            pil_ptr = pil_ptr +1;
        end
    end
end
Al_vec_802_11 = reshape(Al_vec_802_11,1,NFFT_802_11*NDS);

for ii = 1:NDS,
    pil_ptr = 1;
    for jj = 1:NFFT_802_16,
        if (Al_vec_802_16(jj,ii) == 1)
            if (Pils_802_16(pil_ptr) == 0)
                Al_vec_802_16(jj,ii) = 3;
            end
            pil_ptr = pil_ptr +1;
        end
    end
end
Al_vec_802_16 = reshape(Al_vec_802_16,1,NFFT_802_16*NDS);

for ii = 1:NDS,
    pil_ptr = 1;
    for jj = 1:NFFT_802_22,
        if (Al_vec_802_22(jj,ii) == 1)
            if (Pils_802_22(pil_ptr) == 0)
                Al_vec_802_22(jj,ii) = 3;
            end
            pil_ptr = pil_ptr +1;
        end
    end
end
Al_vec_802_22 = reshape(Al_vec_802_22,1,NFFT_802_22*NDS);

%alloc_vec = [Al_vec_802_11 Al_vec_802_16 Al_vec_802_22];
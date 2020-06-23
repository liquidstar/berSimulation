%% setting of variables
ifft_size=64;
pilots=4;
no_carriers=52-pilots;
pst=(ifft_size/2)+1;
tx_databit=round(rand(1,5000));
ofdm_symbols=ceil((length(tx_databit))/no_carriers);
header=6;
footer=ifft_size-4;

%% OFDM Symbol matrix
ofdm_matrix=nan(ifft_size,ofdm_symbols);

%% BPSK
symbol_alphabet = [ 1, -1];
tx_symbol=symbol_alphabet(tx_databit+1);

%% placing guard bands
for dd=1:header
    ofdm_matrix(dd,:)=0;
end

for zz=footer:ifft_size
    ofdm_matrix(zz,:)=0;
end

%% ifft_bins
dd=0;
cyclic_prefix=[];
freq_dom=[];
for mm=1:ofdm_symbols
    for xx=header+1:footer-1
        dd=dd+1;
        %% insertion of 0 to incomplete OFDM symbol
        if dd>length(tx_symbol)
            ofdm_matrix(xx,mm)=0;
        else
            %% DC insertion
            if xx==pst
                ofdm_matrix(xx,mm)=0;
                dd=dd-1;
            
            %% Pilot insertion
            elseif xx==12 || xx==26 || xx==40 || xx==54
                ofdm_matrix(xx,mm)=4;
                dd=dd-1;
           
            %% Symbol insertion to subcarrier
            else
                ofdm_matrix(xx,mm)=tx_symbol(dd);
            end
        end 
        %% ifft of ofdm symbol
        freq_dom(:,mm)=ifft(ofdm_matrix(:,mm));
        
    end
   
end



%% Inserting cyclic prefix
for zz=1:ofdm_symbols
    row=freq_dom(:,zz);
    cyclic_prefix(:,zz)= row(49:64);
end

ext_new=[cyclic_prefix;freq_dom];

%% Parallel to Serial Conversion
ofdmed_=[];
ofdmed_=reshape(ext_new,1,[]);

%% Digital to analog conversion



%% RF front end


%% Channel modelling by Addition of AWGN over different SNRs
SNR_vecs=-20:2:20;
for ff=1:length(SNR_vecs)
    SNR=SNR_vecs(ff);
    distort_sig(ff,:)=awgn(ofdmed_,SNR,'measured');
end

%% Receiver!

%Obtaining different BERs for the different received signals
for aa=1:length(SNR_vecs)
    sig=distort_sig(aa,:);
    %Received databits over different SNRs
    rx_signal=reshape(sig,80,ofdm_symbols);
    
    % remove cyclic prefix
    ee=0;
    ee2=0;
    rx_=[];
    for rr=1:ofdm_symbols
        iter=rx_signal(:,rr);
        rx_ofdm=iter(17:80);
        rx_symbols(:,rr)=rx_ofdm;
        
        %Perform fft
        rx_fft(:,rr)=real(round(fft(rx_symbols(:,rr))));
        
        
        %Obtain received symbols
        for kk=1:ifft_size
       
            if kk<=header || kk>=footer || kk==12 || kk==26 || kk==40 || kk==33 || kk==54 || ee>=length(tx_databit)
                ee2=ee2+1;
        
        %elseif kk==12 || kk~=26 || kk~=40 || kk~=33 || kk~=54 
         %   ee2=ee2+1;
            else          
                ee=ee+1;
                rx_(ee)=rx_fft(kk,rr); 
            end
        end
    end
    %Obtain received databits
    rx_databits=[rx_<0];
    %Calculation of BER for different SNRs
    bit_error=sum(tx_databit~=rx_databits);
    BERs(aa,:)=bit_error/length(tx_databit);

end

%Plot
figure
semilogy(SNR_vecs, BERs,'b-')
xlabel('SNR[dB]')
ylabel('Bit Error Ratio')
grid on









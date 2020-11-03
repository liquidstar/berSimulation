clear all;clc;
%% setting of variables
ifft_size=64;
pilots=4;
no_carriers=52-pilots;
pst=(ifft_size/2)+1;
tx_databit=round(rand(1,100000));
ofdm_symbols=ceil((length(tx_databit))/no_carriers);
header=6;
footer=ifft_size-4;
channel=3; %number of channels 1=AWGN, 2=Rayleigh, 3=Rician

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


%% Channel modelling 
SNR_vecs=-20:1:40;
specular_dB=10;
for bb=1:channel 
    
    
    %h=(randn(1,taps)+j*randn(1,taps)).*sqrt(1/2);
    
    for ff=1:length(SNR_vecs)
        SNR=SNR_vecs(ff);
        sigma_v=10.^(-SNR/10);
        noise=sigma_v*(randn(size(ofdmed_))+1i*randn(size(ofdmed_)))/sqrt(2);
        %AWGN
        if bb==1
            no_fade=ofdmed_+noise;
            awgn(ff,:)=no_fade;  
        end
        
        %Rayleigh fading
        if bb==2
            h=(randn(size(ofdmed_))+1i*randn(size(ofdmed_)))*sqrt(1/2);
            distort=ofdmed_.*h+noise;
            distort_sig(ff,:)=distort;
        end
        
        if bb==3
            K=10^(specular_dB/10);
            channelChar = sqrt(K/(K+1)) + sqrt(1/(K+1))*(1/sqrt(2))*(randn(size(ofdmed_)) + 1i*randn(size(ofdmed_)));
            distorted=ofdmed_.*channelChar+noise;
            ric_sig(ff,:)=distorted;
        end                 
    end
end





%% Receiver!


for aa=1:length(SNR_vecs)
    sig=distort_sig(aa,:);
    distort_=sig./h;
    sig1=ric_sig(aa,:);
    distort_1=sig1./channelChar;
    
    sig2=awgn(aa,:);
    %Received databits over different SNRs
    rx_signal=reshape(distort_,80,ofdm_symbols);
    rx_signal1=reshape(distort_1,80,ofdm_symbols);
    rx_signal2=reshape(sig2,80,ofdm_symbols);
    % remove cyclic prefix
    ee=0;
    ee2=0;
    rx_=[];
    for rr=1:ofdm_symbols
        iter=rx_signal(:,rr);
        iter1=rx_signal1(:,rr);
        iter2=rx_signal2(:,rr);
        rx_ofdm=iter(17:80);
        rx_ofdm1=iter1(17:80);
        rx_ofdm2=iter2(17:80);
        rx_symbols(:,rr)=rx_ofdm;
        rx_symbols1(:,rr)=rx_ofdm1;
        rx_symbols2(:,rr)=rx_ofdm2;
        rx_fft(:,rr)=real(round(fft(rx_symbols(:,rr)),0));
        rx_fft1(:,rr)=real(round(fft(rx_symbols1(:,rr)),0));
        rx_fft2(:,rr)=real(round(fft(rx_symbols2(:,rr)),0));

        for kk=1:ifft_size
       
            if kk<=header || kk>=footer || kk==12 || kk==26 || kk==40 || kk==33 || kk==54 || ee>=length(tx_databit)
                ee2=ee2+1;
        
        %elseif kk==12 || kk~=26 || kk~=40 || kk~=33 || kk~=54 
         %   ee2=ee2+1;
            else          
                ee=ee+1;
                rx_(ee)=rx_fft(kk,rr);
                rx1_(ee)=rx_fft1(kk,rr);
                rx2_(ee)=rx_fft2(kk,rr);
            end
        end
    end
    rx_databits=[rx_<0];
    rx_databits1=[rx1_<0];
    rx_databits2=[rx2_<0];
    bit_error=sum(tx_databit~=rx_databits);
    bit_error1=sum(tx_databit~=rx_databits1);
    bit_error2=sum(tx_databit~=rx_databits2);
    BERs(:,aa)=bit_error/length(tx_databit);
    BERs1(:,aa)=bit_error1/length(tx_databit);
    BERs2(:,aa)=bit_error2/length(tx_databit);

end

%Plot
figure
semilogy(SNR_vecs,BERs,SNR_vecs,BERs1,SNR_vecs,BERs2)
legend('rayleigh','rician','awgn')
xlabel('SNR[dB]')
ylabel('Bit Error Ratio')
grid on









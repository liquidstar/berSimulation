classdef Receiver
    % Get Noisy OFDM signal from channel, give decoded message
    properties
        serOfdmSig  % Combined I and Q signals
        serRecBits  % Communication output
    end
    
    methods
        function rece = Receiver(rfFlag, noisySignal, h, nTs, ofdmVariant, Ts, fc, Dt)
            noisySignal = channelEq(noisySignal, h);
            if (rfFlag)
                t = 0:Dt:nTs;
                [noisyBaseI, noisyBaseQ] = freqDownScale(noisySignal, fc, t, Dt);
                % Analog to Digital
                [digitalI, digitalQ, symbCount] = adc(ofdmVariant, noisyBaseI, noisyBaseQ, t, Ts);
                % - - - Removing unneeeded heavies - - -
                clear t noisyBaseI noisyBaseQ noisyPassBandOfdm;
            else
                ofdmSize = length(ofdmVariant.subCarriers);
                cp = ofdmVariant.cycPrefix/100;
                gi = ofdmVariant.guardInt/100;
                digitalI = real(noisySignal);
                digitalQ = imag(noisySignal);
                symbCount = length(digitalI)/(ofdmSize + floor(cp*ofdmSize) + floor(gi*ofdmSize));
                clear ofdmSize cp gi;
            end
            % Strip guard Interval and Cyclic prefix
            rece.serOfdmSig = ofdmDemux(digitalI, digitalQ, ofdmVariant, symbCount);
            clear digitalI digitalQ;
            % FFT Operation
            parRecBauds = unMapBauds(rece.serOfdmSig, ofdmVariant);
            % Adjust parRecBauds according to pilots and Extracting symbols from FFT bins
            parRecSymb = pilotSync(parRecBauds, ofdmVariant);
            % BPSK Demodulation
            rece.serRecBits = unMapBits(parRecSymb);
        end        
    end
end
%% Channel Equalization
function eqSignal = channelEq(noisySignal, h)
    eqSignal = noisySignal./h;
end
%% Frequency Down-conversion
function [recNoisyBaseI, recNoisyBaseQ] = freqDownScale(noisySignal,fc,t,Dt)
    % Channel equalization
    recMixI = noisySignal.*cos(fc*t);
    recMixQ = noisySignal.*sin(fc*t);
    fs = Dt^-1;
    recNoisyBaseI = lowpass(recMixI, 1e-1*fc, fs);
    recNoisyBaseQ = lowpass(recMixQ, 1e-1*fc, fs);
end

%% Analog to digital conversion
function [recDigI, recDigQ, symbCount] = adc(ofdmVariant, recNoisyBaseI, recNoisyBaseQ, t, Ts)
    symbCount = ceil(max(t)/Ts);
    ofdmSize = length(ofdmVariant.subCarriers);
    cp = ofdmVariant.cycPrefix/100;
    gi = ofdmVariant.guardInt/100;
    % Samples per symbol dependent on variant
    symbLength = ofdmSize + floor(cp*ofdmSize) + floor(gi*ofdmSize);
    % Sampling interval = n * numSym * sampPerSym
    samples = floor(linspace(1,length(t),symbCount*symbLength));
    % And now to convert to digital
    recDigI = recNoisyBaseI(samples);
    recDigQ = recNoisyBaseQ(samples);
end

%% Removing Guard interval and cyclic extension
function recSerOfdm = ofdmDemux(recDigI, recDigQ, ofdmVariant, symbCount)
    % pick out sequences of symbLength from recDigI and recDigQ
    ofdmSize = length(ofdmVariant.subCarriers);
    cp = ofdmVariant.cycPrefix/100;
    gi = ofdmVariant.guardInt/100;
    symbLength = ofdmSize + floor(cp*ofdmSize) + floor(gi*ofdmSize);
    recSerOfdm = zeros(1,symbCount*ofdmSize);
    prefixEnd = floor(cp*ofdmSize) + 1;
    guardStart = ofdmSize + floor(cp*ofdmSize);%floor((1 + gi)*ofdmSize);    
    for i = 0:symbCount-1
        thisSymbI = recDigI(i*symbLength+1:(i+1)*symbLength);
        thisSymbQ = recDigQ(i*symbLength+1:(i+1)*symbLength);
        recSerOfdm(i*ofdmSize+1:(i+1)*ofdmSize) = thisSymbI(prefixEnd: guardStart) + 1i*thisSymbQ(prefixEnd:guardStart);
     end 
end

%% Recover symbols from serial OFDM string
function noisyBauds = unMapBauds(serOfdmSig, ofdmVariant)
    ofdmSize = length(ofdmVariant.subCarriers);
    fftBins = (reshape(serOfdmSig, ofdmSize, []))';
    [symbCount,~] = size(fftBins);
    % Need to FFT each column, thus $symbCount FFT operations
    noisyBauds = zeros(size(fftBins));
    for i = 1:symbCount
        noisyBauds(i,:) = fft(fftBins(i,:));
    end
    noisyBauds = noisyBauds';
end

%% Synchronize parRecBauds to pilots and extract from bins
function [parRecSymb] = pilotSync(parRecBauds, ofdmVariant)
    % Find the mean of pilot subcarrier for every symbol
    ofdmVariant = ofdmVariant.subCarriers;
    [~,symbCount] = size(parRecBauds);
    parRecBauds = parRecBauds';
    for i = 1:symbCount
        meanPilot = mean(parRecBauds(i,ofdmVariant == 'p'));
        parRecBauds(i,:) = parRecBauds(i,:)./meanPilot;
    end
    recBinBauds = parRecBauds';
    parRecSymb = recBinBauds(ofdmVariant == 'd',:);
end

%% BPSK Demodulation
function serRecBits = unMapBits(parRecSymb)
    serRecSymb = reshape(real(parRecSymb), 1, []);
    % BPSK demodulation
    serRecBits = serRecSymb > 0;
end
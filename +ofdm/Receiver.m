classdef Receiver
    % Get Noisy OFDM signal from channel, give decoded message
    properties
        % noisyBaseI  % Freq down-conversion products
        % noisyBaseQ  %
        % digitalI    % ADC products
        % digitalQ    %
        serOfdmSig  % Combined I and Q signals
        % parRecBauds % FFT product
        % binRecBauds %
        % parRecSymb  % 
        serRecBits  % Communication output
    end
    
    methods
        function rece = Receiver(rfFlag, noisySignal, h, nTs, ofdmVariant, Ts, fc, Dt)
            % noisyPassBandOfdm = single(noisyPassBandOfdm);
            % h = single(h);
            % Ts = single(Ts);
            % fc = single(fc);
            % Dt = single(Dt);
            % t = single(t);
            % Frequency DownConversion
            noisySignal = channelEq(noisySignal, h);
            if (rfFlag)
                t = 0:Dt:nTs;
                [noisyBaseI, noisyBaseQ] = freqDownScale(noisySignal, fc, t, Dt);
                % Analog to Digital
                [digitalI, digitalQ, symbCount] = adc(ofdmVariant, noisyBaseI, noisyBaseQ, t, Ts);
                % - - - Removing unneeeded heavies - - -
                clear t noisyBaseI noisyBaseQ noisyPassBandOfdm;
            else
                digitalI = real(noisySignal);
                digitalQ = imag(noisySignal);
                symbCount = length(digitalI)/(1.5*length(ofdmVariant));
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
function [recDigI, recDigQ, numSym] = adc(ofdmVariant, recNoisyBaseI, recNoisyBaseQ, t, Ts)
    numSym = ceil(max(t)/Ts);
    % Samples per symbol dependent on variant
    % TODO: Make this aspect programmable
    sampPerSym = 1.2*(1.25*length(ofdmVariant));        % TODO: Customizable CP & GI
    % Sampling interval = n * numSym * sampPerSym
    samples = floor(linspace(1,length(t),numSym*sampPerSym));
    % And now to convert to digital
    recDigI = recNoisyBaseI(samples);
    recDigQ = recNoisyBaseQ(samples);
end

%% Removing Guard interval and cyclic extension
function recSerOfdm = ofdmDemux(recDigI, recDigQ, ofdmVariant, symbCount)
    % pick out sequences of symbLength from recDigI and recDigQ
    ofdmSize = length(ofdmVariant);
    symbLength = 1.2*1.25*ofdmSize;        % TODO: Customizable CP & GI
    recSerOfdm = zeros(1,symbCount*ofdmSize);
    for i = 0:symbCount-1
        thisSymbI = recDigI(i*symbLength+1:(i+1)*symbLength);
        thisSymbQ = recDigQ(i*symbLength+1:(i+1)*symbLength);
        recSerOfdm(i*ofdmSize+1:(i+1)*ofdmSize) = thisSymbI((0.25*ofdmSize+1):1.25*ofdmSize) + 1i*thisSymbQ((0.25*ofdmSize+1):1.25*ofdmSize);
     end 
end

%% Recover symbols from serial OFDM string
function noisyBauds = unMapBauds(serOfdmSig, ofdmVariant)
    fftBins = reshape(serOfdmSig, length(ofdmVariant), []);
    noisyBauds = fft(fftBins);
    [len, ~] = size(noisyBauds);
    finalNoisyBauds = 0*noisyBauds;
    % Roll FFT product rows (Goes 2 down)
    for i = 1:len
        if i+2 > len
            j = (i+2)-len;
            finalNoisyBauds(i,:) = noisyBauds(j,:);
            if (i+2) == len
                break;
            end
        else
            finalNoisyBauds(i,:) = noisyBauds(i+2,:);
        end
    end
    noisyBauds = finalNoisyBauds;
end

%% Synchronize parRecBauds to pilots and extract from bins
function [parRecSymb] = pilotSync(parRecBauds, ofdmVariant)
    % Find the mean of pilot subcarrier for every symbol
    %meanPilot = mean(mean(parRecBauds(ofdmVariant == 'p',:)));
     [~,symbCount] = size(parRecBauds);
     parRecBauds = parRecBauds';
     for i = 1:symbCount
         meanPilot = mean(parRecBauds(i,ofdmVariant == 'p'));
         parRecBauds(i,:) = parRecBauds(i,:)./meanPilot;
     end
    % Multiply everything by the reciprocal of said mean
    recBinBauds = parRecBauds';
    parRecSymb = flip(recBinBauds(ofdmVariant == 'd',:));
    %recBinBauds = real(meanPilot^-1*parRecBauds);
    %parRecSymb = round(flip(recBinBauds(ofdmVariant == 'd',:)));
end

%% BPSK Demodulation
function serRecBits = unMapBits(parRecSymb)
    serRecSymb = reshape(real(parRecSymb), 1, []);
    % Truncate invalid symbols out // Prone to introducing errors so emitted assuming no knowledge about transmitted data
    serRecBits = serRecSymb > 0;
end
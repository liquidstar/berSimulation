classdef Receiver
    % Get Noisy OFDM signal from channel, give decoded message
    properties
        noisyBaseI  % Freq down-conversion products
        noisyBaseQ  %
        digitalI    % ADC products
        digitalQ    %
        serOfdmSig  % Combined I and Q signals
        parRecBauds % FFT product
        binRecBauds %
        parRecSymb  % 
        serRecBits  % Communication output
    end
    
    methods
        function rece = Receiver(noisyPassBandOfdm, channelCharacterization, analogTimeBase, ofdmVariant, symbolTime, centerFreq, samplingInterval)
            % Frequency DownConversion
            [rece.noisyBaseI, rece.noisyBaseQ] = freqDownScale(noisyPassBandOfdm,  channelCharacterization, centerFreq, analogTimeBase, samplingInterval);
            % Analog to Digital
            [rece.digitalI, rece.digitalQ, numSym] = adc(ofdmVariant, rece.noisyBaseI, rece.noisyBaseQ, analogTimeBase, symbolTime);
            % Strip guard Interval and Cyclic prefix
            rece.serOfdmSig = ofdmDemux(rece.digitalI, rece.digitalQ, ofdmVariant, numSym);
            % FFT Operation
            rece.parRecBauds = unMapBauds(rece.serOfdmSig, ofdmVariant);
            % Adjust parRecBauds according to pilots and Extracting symbols from FFT bins
            [rece.binRecBauds, rece.parRecSymb] = pilotSync(rece.parRecBauds, ofdmVariant);
            % BPSK Demodulation
            rece.serRecBits = unMapBits(rece.parRecSymb);
        end        
    end
end

%% Frequency Down-conversion
function [recNoisyBaseI, recNoisyBaseQ] = freqDownScale(noisyPassBand,h,fc,t,Dt)
    noisyPassBand = noisyPassBand./h;
    recMixI = noisyPassBand.*cos(fc*t);
    recMixQ = noisyPassBand.*sin(fc*t);
    fs = Dt^-1;
    recNoisyBaseI = lowpass(recMixI, 1e-1*fc, fs);
    recNoisyBaseQ = lowpass(recMixQ, 1e-1*fc, fs);
end

%% Analog to digital conversion
function [recDigI, recDigQ, numSym] = adc(ofdmVariant, recNoisyBaseI, recNoisyBaseQ, t, Ts)
    numSym = ceil(max(t)/Ts);
    % Samples per symbol dependent on variant
    % TODO: Make this aspect programmable
    sampPerSym = 1.2*(1.25*length(ofdmVariant));
    % Sampling interval = n * numSym * sampPerSym
    samples = floor(linspace(1,length(t),numSym*sampPerSym));
    % And now to convert to digital
    recDigI = recNoisyBaseI(samples);
    recDigQ = recNoisyBaseQ(samples);
end

%% Removing Guard interval and cyclic extension
function recSerOfdm = ofdmDemux(recDigI, recDigQ, ofdmVariant, numSym)
    % pick out sequences of symbLength from recDigI and recDigQ
    ofdmSize = length(ofdmVariant);
    symbLength = 1.2*1.25*ofdmSize;
    recSerOfdm = zeros(1,numSym*ofdmSize);
    for i = 0:numSym-1
        thisSymbI = recDigI(i*symbLength+1:(i+1)*symbLength);
        thisSymbQ = recDigQ(i*symbLength+1:(i+1)*symbLength);
        % Locating the guard interval (in case of phase shift)
        thisIQDiff = abs(thisSymbI+thisSymbQ)/2;
        nullIndices = find(thisIQDiff<0.01);
        nullContig = diff(nullIndices);
        % Folded loop to find contiguous nulls
        if isempty(nullContig)
            % TODO: Find what this condition represents
            guardIndex = 0;
        end
        for j = 1:length(nullContig)
            if (j+14) <= length(nullContig)
                testRange = nullContig(j:j+14);
            elseif length(nullContig) < 15  % Impossible to locate guard interval (Due to noise)
                guardIndex = 0;
                break
            else
                testRange = [nullContig(j:length(nullContig)) nullContig(1:14-(length(nullContig)-j))];
            end
            if testRange == ones(1,15)
                guardIndex = j;
                break
            else
                guardIndex = 0;
                break
            end
        end
        % Protection against undetected guard interval
        if guardIndex == 0
            guardStartIndex = ofdmSize;
        else
            guardStartIndex = nullIndices(guardIndex);
        end
        symbEndIndex = guardStartIndex - 1;
        % TODO: Verify relevance of this logic
        % Loop to extract unprotected symbol (Check guardStartIndex. If less than min, assume no shift)
        if guardStartIndex <= 1.25*ofdmSize
            recSerOfdm(i*ofdmSize+1:(i+1)*ofdmSize) = thisSymbI((0.25*ofdmSize+1):1.25*ofdmSize) + 1i*thisSymbQ((0.25*ofdmSize+1):1.25*ofdmSize);
        else
            recSerOfdm(i*ofdmSize+1:(i+1)*ofdmSize) = thisSymbI((symbEndIndex-ofdmSize+1):symbEndIndex) + 1i*thisSymbQ((symbEndIndex-ofdmSize+1):symbEndIndex);
        end
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
function [recBinBauds,parRecSymb] = pilotSync(parRecBauds, ofdmVariant)
    % Find the mean of pilot symbols
    meanPilot = mean(mean(parRecBauds(ofdmVariant == 'p',:)));
    % Multiply everything by the reciprocal of said mean
    recBinBauds = real(meanPilot^-1*parRecBauds);
    parRecSymb = round(flip(recBinBauds(ofdmVariant == 'd',:)));
end

%% BPSK Demodulation
function serRecBits = unMapBits(parRecSymb)
    serRecSymb = reshape(parRecSymb, 1, []);
    % Truncate invalid symbols out // Prone to introducing errors so emitted assuming no knowledge about transmitted data
    serRecBits = serRecSymb > 0;
end
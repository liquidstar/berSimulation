classdef Transmitter
    %   All transmitter operations
    %   Inherited by modulator and IFFT module (probably)
    properties
        subCarrierConfig
        signalAmplitude
        parBauds
        serBauds
        binData
        baseBandOfdmSig
        baseBandAnalogI
        baseBandAnalogQ
        centerFreq
        passBandAnalog
        analogTimeBase
    end
    methods
        function trans = Transmitter(serData, ofdmVariant, symbolTime, centerFreq, samplingInterval, sigAmp)
            trans.subCarrierConfig = [sum(ofdmVariant(:) == 'd') sum(ofdmVariant(:) == 'p') sum(ofdmVariant(:) == 'v')];
            trans.centerFreq = centerFreq;
            trans.signalAmplitude = sigAmp;
            % serData to modulator (serial)
            trans.serBauds = mapBits(serData);
            % serBauds to parBauds (parallel)
            trans.parBauds = makeParallel(trans.serBauds, trans.subCarrierConfig);
            % bauData to IFFT bins (parallel)
            trans.binData = binBauds(trans.parBauds, ofdmVariant);
            % binData to IFFT operation (parallel)
            % iffData to guard interval (parallel)
            % cycData to Serial (serial)
            trans.baseBandOfdmSig = ofdmMux(trans.binData);
            % serOfdmData to Analog (serial)
            [trans.baseBandAnalogI,trans.baseBandAnalogQ,trans.analogTimeBase] = dac(trans.baseBandOfdmSig, symbolTime, size(trans.binData), samplingInterval);
            % Upscale frequency to RF
            trans.passBandAnalog = freqUpScale(trans.baseBandAnalogI, trans.baseBandAnalogQ, trans.centerFreq, trans.analogTimeBase, samplingInterval, sigAmp);
        end    
    end
end
%% S - P Conversion
function parBauds = makeParallel(serBauds,subCarrierConfig)
    if (mod(length(serBauds),subCarrierConfig(1)) ~= 0)
        serBauds = [serBauds zeros(1, subCarrierConfig(1) - mod(length(serBauds),subCarrierConfig(1)))];
    end
    parBauds = reshape(serBauds, subCarrierConfig(1), []);
end

%% BPSK Modulation
 function bauds = mapBits(bitArray)
    %symAlph = [-1 1];
    bauds = (bitArray - 0.5);
 end

%% Map symbols to IFFT bins
 function bins = binBauds(baudMatrix, ofdmVariant)
    % baudMatrix = baudMatrix';
    [~, baudCols] = size(baudMatrix);
    bins = zeros(length(ofdmVariant),baudCols);
    j = 1;
    for i=1:length(ofdmVariant)
        if ofdmVariant(i) == 'v'
            bins(i,:) = zeros(1,baudCols);
        elseif ofdmVariant(i) == 'd'
            bins(i,:) = baudMatrix(j,:);
            j = j + 1;
        elseif ofdmVariant(i) == 'p'
            bins(i,:) = ones(1,baudCols);
        end     
    end
 end

%% Operate on binned symbols, give baseband signal
 function serOfdmSig = ofdmMux(binData)
    binData = binData';
    % Add cyclic prefix(25%) and guard interval(20% for 802.11)
    [symPerCarr,numSubCarrier] = size(binData);
    cycData = zeros(symPerCarr,1.5*numSubCarrier);
    for i = 1:symPerCarr
        % ifft it
        ifftData = ifft(binData(i,:));
        % cyclic extend and guard-interval it
        cycData(i,:) = [ifftData((0.75*numSubCarrier+1):numSubCarrier), ifftData, zeros(1,0.25*numSubCarrier)];
    end
    serOfdmSig = reshape(cycData', 1, []);
 end

%% Digital to analog conversion
 function [baseBandAnalogI, baseBandAnalogQ, t] = dac(baseBandSig, Ts, ifftBinSize, Dt)
    % TODO: Specify symbol duration
    baseBandSigI = real(baseBandSig);
    % TODO: Include quadrature component
    baseBandSigQ = imag(baseBandSig);
    n = 0:length(baseBandSig)-1;
    nTs = ifftBinSize(2)*(n*Ts)/length(baseBandSig);    % No of OFDM symbols x normalized symbol duration
    % TODO: Pass Dt(Sampling frequency of analog domain): Dt^-1 > 2*fc
    % Dt = 5e-10;
    t = 0:Dt:max(nTs);%ifftBinSize(2)*20*Ts;
    baseBandAnalogI = spline(nTs, baseBandSigI, t);
    baseBandAnalogQ = spline(nTs, baseBandSigQ, t);
 end

%% Frequency upscaling for pass band 
 function bandPassSig = freqUpScale(baseBandAnalogI, baseBandAnalogQ, fc, t, Dt, sigAmp)
    % Mixing to get cos(fc+fm) + cos(fc-fm)
    mixedSig = baseBandAnalogI.*(cos(fc*t)) + baseBandAnalogQ.*(sin(fc*t));
    % High pass filter to get RF signal
    fs = Dt^-1;
    % Applying amplification
    bandPassSig = sigAmp*highpass(mixedSig, fc, fs);
 end
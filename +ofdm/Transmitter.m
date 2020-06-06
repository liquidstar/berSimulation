classdef Transmitter
    %   All transmitter operations
    %   Inherited by modulator and IFFT module (probably)
    properties
        parData
        bauData
        binData
        baseBandOfdmSig
        baseBandAnalog
        centerFreq
        passBandAnalog
    end
    methods
        function trans = Transmitter(serData, numSubCarriers, samplingRate, centerFreq)
            trans.centerFreq = centerFreq;
            % serData to parallel (serial)
            trans.parData = reshape(serData, numSubCarriers, []);
            % parData to Modulator (parallel)
            trans.bauData = mapBits(trans.parData);
            % bauData to IFFT bins (parallel)
            trans.binData = binBauds(trans.bauData);
            % binData to IFFT operation (parallel)
            % iffData to guard interval (parallel)
            % cycData to Serial (serial)
            trans.baseBandOfdmSig = ofdmMux(trans.binData, numSubCarriers);
            % serOfdmData to Analog (serial)
            [trans.baseBandAnalog, analogTimeBase] = dac(trans.baseBandOfdmSig, samplingRate);
            % Upscale frequency to RF
            trans.passBandAnalog = freqUpScale(trans.baseBandAnalog, trans.centerFreq, analogTimeBase);
        end    
    end
end

%% BPSK Modulation
 function bauds = mapBits(bitArray)
    symAlph = [-1 1];
    bauds = symAlph(bitArray + 1);
 end

%% Map symbols to IFFT bins
 function bins = binBauds(baudMatrix)
    % TODO: @Rosie
    % Add virtual carriers
    % Add pilot carriers
    bins = baudMatrix';
    binSize = size(bins);
    binSize(1) = binSize(1)/2;
    bins = [zeros(binSize); bins; zeros(binSize)]';
 end

%% Operate on binned symbols, give baseband signal
 function serOfdmSig = ofdmMux(binData, numSubcarriers)
    % cycData (symbolsPerCarrier x numSubCarriers + numSubCarriers/4 + guardInterval)
    [symPerCarr,numSubCarrier] = size(binData);
    cycData = zeros(symPerCarr,numSubCarrier*1.5);
    for i = 1:numSubcarriers
        % ifft it
        ifftData = ifft(binData(i,:));
        % cyclic extend and guard-interval it % TODO: Find whether guard
        % interval precedes OFDM symbols or if okay.
        cycData(i,:) = [ifftData, ifftData(1:(numSubCarrier/4)), zeros(1,numSubCarrier/4)];
    end
    serOfdmSig = reshape(cycData', 1, []);
 end

%% Digital to analog conversion
 function [baseBandAnalog,t] = dac(baseBandSig, Fs)
    % TODO: variable specification
    baseBandSig = real(baseBandSig);
    Ts = Fs^-1;
    n = 1:length(baseBandSig);
    nTs = n*Ts;
    Dt = 5e-5;  % TODO: Figure whether I want this to change (Factor of?)
    t = 0:Dt:(length(baseBandSig)*Ts);
    baseBandAnalog = spline(nTs, baseBandSig, t);
 end

%% Frequency upscaling for pass band 
 function bandPassSig = freqUpScale(baseBandAnalog, fc, t)
    bandPassSig = baseBandAnalog.*(2*pi*cos(fc*t));
 end
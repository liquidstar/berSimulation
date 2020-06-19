classdef Transmitter
    %   All transmitter operations
    properties
        subCarrierConfig    % Number of Data, Pilot and Virtual Subcarriers
        signalAmplitude     % 
        parBauds            % Symbols paralleled
        serBauds            % 
        binData             % Bauds organized into bins according to 'ofdmVariant'
        baseBandOfdmSig     % Serialized IFFT product with Cyclic and guard extension
        baseBandAnalogI     % In-phase
        baseBandAnalogQ     % Quadrature
        centerFreq          % RF center frequency
        passBandAnalog      % RF OFDM signal
        analogTimeBase      % 
    end
    methods
        function trans = Transmitter(serData, ofdmVariant, symbolTime, centerFreq, samplingInterval, sigAmp)
            trans.subCarrierConfig = [sum(ofdmVariant(:) == 'd') sum(ofdmVariant(:) == 'p') sum(ofdmVariant(:) == 'v')];
            trans.centerFreq = centerFreq;
            trans.signalAmplitude = sigAmp;
            % serData to modulator (serial)
            trans.serBauds = mapBits(serData);
            % serBauds to parBauds :: Determined by number of data subcarriers
            trans.parBauds = makeParallel(trans.serBauds, trans.subCarrierConfig);
            % bauData to IFFT bins :: Determined by 'ofdmVariant'
            trans.binData = binBauds(trans.parBauds, ofdmVariant);
            % binData -> IFFT -> Cyclic prefix -> Guard Interval -> Serialized
            trans.baseBandOfdmSig = ofdmMux(trans.binData);
            % complex basebandOfdm -> I and Q -> Analog I and Q
            [trans.baseBandAnalogI,trans.baseBandAnalogQ,trans.analogTimeBase] = dac(trans.baseBandOfdmSig, symbolTime, size(trans.binData), samplingInterval);
            % Upscale frequency to RF
            trans.passBandAnalog = freqUpScale(trans.baseBandAnalogI, trans.baseBandAnalogQ, trans.centerFreq, trans.analogTimeBase, samplingInterval, sigAmp);
        end    
    end
end
%% S - P Conversion
function parBauds = makeParallel(serBauds,subCarrierConfig)
    if (mod(length(serBauds),subCarrierConfig(1)) ~= 0)
        % Append zeros to make baud count a multiple of data subcarriers
        serBauds = [serBauds zeros(1, subCarrierConfig(1) - mod(length(serBauds),subCarrierConfig(1)))];
    end
    parBauds = reshape(serBauds, subCarrierConfig(1), []);
end

%% BPSK Modulation
 function bauds = mapBits(bitArray)
    % 'bitArray' are integers, subtracting .5 results in -.5 or .5 rounded to -1 or 1
    bauds = (bitArray - 0.5);
 end

%% Map symbols to IFFT bins
 function bins = binBauds(baudMatrix, ofdmVariant)
    [~, baudCols] = size(baudMatrix);
    % Total subcarriers x number of OFDM symbols
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
        % cyclic prefix and guard-interval it
        cycData(i,:) = [ifftData((0.75*numSubCarrier+1):numSubCarrier), ifftData, zeros(1,0.25*numSubCarrier)];
    end
    serOfdmSig = reshape(cycData', 1, []);
 end

%% Digital to analog conversion
 function [baseBandAnalogI, baseBandAnalogQ, t] = dac(baseBandSig, Ts, ifftBinSize, Dt)
    % In-phase component
    baseBandSigI = real(baseBandSig);
    % Quadrature component
    baseBandSigQ = imag(baseBandSig);
    % baseband signal samples
    n = 0:length(baseBandSig)-1;
    % distribute samples over multiples (Symbol count x symbol duration) :: (numSym * nTs)
    nTs = ifftBinSize(2)*(n*Ts)/length(baseBandSig);
    % Interpolation intervals for DAC up to nTs
    t = 0:Dt:max(nTs);
    % Spline interpolation of I and Q signals (DAC conversion)
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
    bandPassSig = 5000*sigAmp*highpass(mixedSig, fc, fs);
 end
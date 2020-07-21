classdef Transmitter
    %   All transmitter operations
    properties
        % subCarrierConfig    % Number of Data, Pilot and Virtual Subcarriers
        % signalAmplitude     % 
        % parBauds            % Symbols paralleled
        % serBauds            % 
        % binData             % Bauds organized into bins according to 'ofdmVariant'
        baseBandOfdmSig     % Serialized IFFT product with Cyclic and guard extension
        % baseBandAnalogI     % In-phase
        % baseBandAnalogQ     % Quadrature
        centerFreq          % RF center frequency
        passBandAnalog      % RF OFDM signal
        analogTimeBase      %
        symbolTime
        variant
        samplingInterval
    end
    methods
        % function trans = Transmitter(serData, ofdmVariant, symbolTime, centerFreq, samplingInterval, sigAmp)
        function trans = Transmitter(dataSource, ofdmVariant, Ts, fc, Dt)
            % subCarrierConfig = [sum(ofdmVariant(:) == 'd') sum(ofdmVariant(:) == 'p') sum(ofdmVariant(:) == 'v')];
            trans.symbolTime = Ts;
            trans.centerFreq = fc;
            trans.variant = ofdmVariant;
            trans.samplingInterval = Dt;
            % trans.signalAmplitude = sigAmp;
            % serData to modulator (serial)
            serBauds = mapBits(dataSource.serialBits);
            % serBauds to parBauds :: Determined by number of data subcarriers
            parBauds = makeParallel(serBauds, ofdmVariant);
            % bauData to IFFT bins :: Determined by 'ofdmVariant'
            binData = binBauds(parBauds, ofdmVariant);
            % binData -> IFFT -> Cyclic prefix -> Guard Interval -> Serialized
            trans.baseBandOfdmSig = ofdmMux(binData);
            % complex basebandOfdm -> I and Q -> Analog I and Q
            [baseBandAnalogI,baseBandAnalogQ,trans.analogTimeBase] = dac(trans.baseBandOfdmSig, Ts, size(binData), Dt);
            % Upscale frequency to RF
            trans.passBandAnalog = freqUpScale(baseBandAnalogI, baseBandAnalogQ, fc, trans.analogTimeBase, Dt);
        end    
    end
end
%% S - P Conversion
function parBauds = makeParallel(serBauds,ofdmVariant)
    dataSubs = sum(ofdmVariant(:) == 'd');
    if (mod(length(serBauds),dataSubs) ~= 0)
        % Append zeros to make baud count a multiple of data subcarriers
        serBauds = [serBauds zeros(1, dataSubs - mod(length(serBauds),dataSubs))];
    end
    parBauds = reshape(serBauds, dataSubs, []);
end

%% BPSK Modulation
 function bauds = mapBits(bitArray)
    % 'bitArray' are integers, subtracting .5 results in -.5 or .5 rounded to -1 or 1
    bauds = (bitArray - 0.5);
 end

%% Map symbols to IFFT bins
 function bins = binBauds(baudMatrix, ofdmVariant)
    [~, symbCount] = size(baudMatrix);
    % Total subcarriers x number of OFDM symbols
    bins = int8(zeros(length(ofdmVariant),symbCount));
    j = 1;
    for i=1:length(ofdmVariant)
        if ofdmVariant(i) == 'v'
            bins(i,:) = zeros(1,symbCount);
        elseif ofdmVariant(i) == 'd'
            bins(i,:) = baudMatrix(j,:);
            j = j + 1;
        elseif ofdmVariant(i) == 'p'
            bins(i,:) = ones(1,symbCount);
        end     
    end
 end

%% Operate on binned symbols, give baseband signal
 function serOfdmSig = ofdmMux(binData)
    binData = binData';
    % Add cyclic prefix(25%) and guard interval(20% for 802.11)
    [symbCount, ofdmSize] = size(binData);
    cycData = (zeros(symbCount,1.5*ofdmSize));
    for i = 1:symbCount
        % ifft per symbol
        ifftData = ifft(binData(i,:));
        % cyclic prefix and guard-interval it
        cycData(i,:) = [ifftData((0.75*ofdmSize+1):ofdmSize), ifftData, zeros(1,0.25*ofdmSize)];
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
 function bandPassSig = freqUpScale(baseBandAnalogI, baseBandAnalogQ, fc, t, Dt)
    % Mixing to get cos(fc+fm) + cos(fc-fm)
    mixedSig = baseBandAnalogI.*(cos(fc*t)) + baseBandAnalogQ.*(sin(fc*t));
    % High pass filter to get RF signal
    fs = Dt^-1;
    % Applying amplification
    bandPassSig = 1000*highpass(mixedSig, fc, fs);
 end
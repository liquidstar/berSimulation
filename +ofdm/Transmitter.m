classdef Transmitter
    % All transmitter operations
    properties
        rfFlag              % Whether to freq-upscale
        baseBandOfdmSig     % Serialized IFFT product with Cyclic and guard extension
        centerFreq          % RF center frequency
        passBandAnalog      % RF OFDM signal
        nTs                 % symbCount x symbolTime
        symbolTime
        variant
        samplingInterval
    end
    methods
        function trans = Transmitter(rf, dataSource, ofdmVariant, Ts, fc)
            trans.rfFlag = rf;
            trans.symbolTime = Ts;
            trans.centerFreq = fc;
            trans.variant = ofdmVariant;
            trans.samplingInterval = 0.49*(fc)^-1;
            % Convert bit stream into symbol stream
            serBauds = mapBits(dataSource.serialBits);
            % Serial symbol stream into parallel according to variant
            parBauds = makeParallel(serBauds, ofdmVariant);
            % bauData to IFFT bins :: Determined by 'ofdmVariant'
            binData = binBauds(parBauds, ofdmVariant);
            % binData -> IFFT -> Cyclic prefix -> Guard Interval -> Serialized
            trans.baseBandOfdmSig = ofdmMux(binData, ofdmVariant);
            if (trans.rfFlag)
                % complex basebandOfdm -> I and Q -> Analog I and Q
                [baseBandAnalogI,baseBandAnalogQ,t,trans.nTs] = dac(trans.baseBandOfdmSig, Ts, size(binData), Dt);
                % Upscale frequency to RF
                trans.passBandAnalog = freqUpScale(baseBandAnalogI, baseBandAnalogQ, fc, t, Dt);
            end
        end    
    end
end
%% S - P Conversion
function parBauds = makeParallel(serBauds,ofdmVariant)
    ofdmVariant = ofdmVariant.subCarriers;
    dataSubs = sum(ofdmVariant(:) == 'd');
    if (mod(length(serBauds),dataSubs) ~= 0)
        % Append zeros to make baud count a multiple of data subcarriers
        serBauds = [serBauds zeros(1, dataSubs - mod(length(serBauds),dataSubs))];
    end
    parBauds = reshape(serBauds, dataSubs, []);
end

%% BPSK Modulation
 function bauds = mapBits(bitArray)
    % BPSK Modulation
    bauds = 2*bitArray - 1;
 end

%% Map symbols to IFFT bins
 function bins = binBauds(baudMatrix, ofdmVariant)
    ofdmVariant = ofdmVariant.subCarriers;
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
 function serOfdmSig = ofdmMux(binData, ofdmVariant)
    cp = ofdmVariant.cycPrefix/100;
    gi = ofdmVariant.guardInt/100;
    binData = binData';
    [symbCount, ofdmSize] = size(binData);
    symbLength = ofdmSize + floor(cp*ofdmSize) + floor(gi*ofdmSize);
    cycData = (zeros(symbCount,symbLength));
    prefixStart = ofdmSize - floor(cp*ofdmSize) + 1;
    guardSize = floor(gi*ofdmSize);
    for i = 1:symbCount
        % ifft per symbol
        ifftData = ifft(binData(i,:));
        % cyclic prefix and guard-interval
        cycData(i,:) = [ifftData(prefixStart:ofdmSize), ifftData, zeros(1,guardSize)];
    end
    serOfdmSig = reshape(cycData', 1, []);
 end

%% Digital to analog conversion
 function [baseBandAnalogI, baseBandAnalogQ, t, nTsMax] = dac(baseBandSig, Ts, ifftBinSize, Dt)
    % TODO: Intermediate frequency
    % In-phase component
    baseBandSigI = real(baseBandSig);
    % Quadrature component
    baseBandSigQ = imag(baseBandSig);
    % baseband signal samples
    n = 0:length(baseBandSig)-1;
    % distribute samples over multiples (Symbol count x symbol duration) :: (numSym * nTs)
    nTs = ifftBinSize(2)*(n*Ts)/length(baseBandSig);
    nTsMax = max(nTs);
    % Interpolation intervals for DAC up to nTs
    t = 0:Dt:nTsMax;
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
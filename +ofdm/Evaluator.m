% An object to perform all necessary analyses on Communication() instances
classdef Evaluator
    properties
        commArray
        snrVector
        bitErrors
        paprs
    end
    
    methods
        function eval = Evaluator(commArray)
            eval.commArray = commArray;
            eval.snrVector = findSnrs(commArray);
            % Determine Average PAPR by transmit symbol
            eval.paprs = findPapr(eval.commArray);
            % Determine Bit Error Rate
            eval.bitErrors = findBers(eval.commArray);
            % Maybe plot some impressive curves and shit.
        end
    end
end

%% Extracting SNR data from Communication instances
function snrVector = findSnrs(commArray)
    commCount = length(commArray);
    sigVector = zeros(1,commCount);
    %noisVector = sigVector;
    for i = 1:commCount
        sigVector(i) = commArray(i).transmitter.signalAmplitude;
        %noisVector(i) = commArray(i).channel.noiseAmplitude;
    end
    snrVector = sigVector;  %./noisVector;
end

%% PAPR Determination
function paprs = findPapr(commArray)
    % Find the average PAPR of the variant (Constant average expected)
    commCount = length(commArray);
    paprs = zeros(1, commCount);
    for i = 1:commCount
        queryWave = abs(commArray(i).transmitter.baseBandOfdmSig).^2;
        peak = max(queryWave);
        avg = mean(queryWave);
        paprs(i) = peak/avg;
    end
end

%% Extraction of BER curves
function bers = findBers(commArray)
    % Compare received serial data to transmitted
    % Assumption: Well fitting data, therefore overflow caused by zero padding is ignored
    commCount = length(commArray);
    bers = zeros(1, commCount);
    for i = 1:commCount
        txData = commArray(i).dataSource.serialBits;
        rxData = commArray(i).receiver.serRecBits(1:length(txData));
        bers(i) = sum(rxData ~= txData)/length(txData);
    end
end
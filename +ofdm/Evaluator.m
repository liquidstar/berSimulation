% An object to perform all necessary analyses on Communication() instances
classdef Evaluator
    properties
        % commArray
        % snrVector
        bitErrors
        papr
    end
    
    methods
        function eval = Evaluator(transmitter)
            eval.bitErrors = [];
            eval.papr = findPapr(transmitter);
        end
        % Add commInst BER
        function eval = getBer(eval, dataSource, commInst)
            % BER
            txData = dataSource.serialBits;
            rxData = commInst.rece.serRecBits(1:length(txData));
            ber = sum(rxData ~= txData)/length(txData);
            eval.bitErrors = [eval.bitErrors ber];
        end
        % Add commInst PAPR to paprs
        % TODO: Save simulation data to file
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
function papr = findPapr(transmitter)
    queryWave = abs(transmitter.baseBandOfdmSig).^2;
    peak = max(queryWave);
    avg = mean(queryWave);
    papr = peak/avg;
end

%% Extraction of BER curves
function ber = findBer(commInst)
    % Compare received serial data to transmitted
    % Assumption: Well fitting data, therefore overflow caused by zero padding is ignored
    % commCount = length(commArray);
    % bers = zeros(1, commCount);
    txData = dataSource.serialBits;
    rxData = commInst.rece.serRecBits(1:length(txData));
    ber = sum(rxData ~= txData)/length(txData);
end
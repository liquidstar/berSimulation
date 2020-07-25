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

%% PAPR Determination
function papr = findPapr(transmitter)
    queryWave = abs(transmitter.baseBandOfdmSig).^2;
    peak = max(queryWave);
    avg = mean(queryWave);
    papr = peak/avg;
end
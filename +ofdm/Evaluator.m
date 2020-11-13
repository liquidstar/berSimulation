% An object to perform all necessary analyses on Communication() instances
classdef Evaluator
    properties
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
    end
end

%% PAPR Determination
function papr = findPapr(transmitter)
    ofdmSize = length(transmitter.variant.subCarriers);
    cp = transmitter.variant.cycPrefix/100;
    gi = transmitter.variant.guardInt/100;
    symbLength = ofdmSize + floor(cp*ofdmSize) + floor(gi*ofdmSize);
    queryWave = abs(transmitter.baseBandOfdmSig).^2;
    symbCount = length(queryWave)/symbLength;
    peaks = zeros(1,symbCount); avgs = peaks;
    for i = 0:symbCount-1
        thisSymb = queryWave(i*symbLength+1:(i+1)*symbLength);
        peaks(i+1) = max(thisSymb);
        avgs(i+1) = mean(thisSymb);
    end
    papr = max(peaks)/mean(avgs);
end
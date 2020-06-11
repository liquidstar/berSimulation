classdef Receiver
    % Get Noisy OFDM signal from channel, give decoded message
    % Inheritance?
    properties
        noisyBaseBand
    end
    
    methods
        function rece = Receiver(noisyPassBandOfdm, analogTimeBase, numSubCarriers, samplingFreq, centerFreq)
            % Frequency DownConversion
            rece.noisyBaseBand = freqDownScale(noisyPassBandOfdm, centerFreq, analogTimeBase);
            % Analog to Digital
            % Strip Gurad Interval and Cyclic Extension
            % FFT Operation
            % Data recovery from Symbols
            % Pass to evaluator
        end
        
    end
end

%% Frequency Down-conversion
function noisyBaseBand = freqDownScale(noisyPassBand, fc,t)
    coherenceProduct = noisyPassBand.*cos(2*pi*fc*t);
    noisyBaseBand = lowpass(coherenceProduct, 1*fc, 2*fc);
end
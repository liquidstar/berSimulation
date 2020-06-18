classdef Channel
    % Channel for signal transmission
    % Add noise and implement fading(Rayleigh or Rice)
    properties
        noisySignal
        noiseVariance
        channelCharacterization
    end
    
    methods
        function link = Channel(passBandAnalog, sigAmp, type)
            link.noiseVariance = 10^-(sigAmp/10);
            if type == "gauss"
                [link.noisySignal, link.channelCharacterization] = addGaussianNoise(passBandAnalog, link.noiseVariance);
            elseif type == "rayl"
                [link.noisySignal, link.channelCharacterization] = rayleighFading(passBandAnalog, link.noiseVariance);
            elseif type == "rice"
                [link.noisySignal, link.channelCharacterization] = ricianFading(passBandAnalog, link.noiseVariance);
            end
        end
    end
end

%% Function to make AWGN Channel
function [noisySignal, channelChar] = addGaussianNoise(passBandAnalog, No)
    n = length(passBandAnalog);
    channelChar = 1;
    noisySignal = passBandAnalog + sqrt(No/2)*(randn(1,n) + 1i*randn(1,n));
end

%% Function to implement Rayleigh Fading
function [fadedSignal, channelChar] = rayleighFading(passBandAnalog, No)
    % Slow, flat fading therefore over a symbol period. Pass ofdmVariant
    n = length(passBandAnalog);
    channelChar = (1/sqrt(2))*(randn(1,n) + 1i*randn(1,n));
    fadedSignal = passBandAnalog.*channelChar + sqrt(No/2)*(randn(1,n) + 1i*randn(1,n));
end

%% Function to implement Rician Fading
function fadedSignal = ricianFading(passBandAnalog, No)
    fadedSignal = passBandAnalog;
end
classdef Channel
    % Channel for signal transmission
    % Add noise and implement fading(Rayleigh or Rice)
    properties
        noiseAmplitude
        noisySignal
        channelCharacterization
    end
    
    methods
        function link = Channel(passBandAnalog, noisAmp, type)
            link.noiseAmplitude = noisAmp;
            if type == "gauss"
                [link.noisySignal, link.channelCharacterization] = addGaussianNoise(passBandAnalog, noisAmp);
            elseif type == "rayl"
                [link.noisySignal, link.channelCharacterization] = rayleighFading(passBandAnalog, noisAmp);
            elseif type == "rice"
                [link.noisySignal, link.channelCharacterization] = ricianFading(passBandAnalog, noisAmp);
            end
        end
    end
end

%% Function to make AWGN Channel
function [noisySignal, channelChar] = addGaussianNoise(passBandAnalog, noisAmp)
    channelChar = 1;
    noisySignal = passBandAnalog + noisAmp*randn(size(passBandAnalog));
end

%% Function to implement Rayleigh Fading
function [fadedSignal, channelChar] = rayleighFading(passBandAnalog, noisAmp)
    n = length(passBandAnalog);
    channelChar = (randn(1,n) + 1i*randn(1,n));
    fadedSignal = passBandAnalog.*(randn(1,n) + 1i*randn(1,n)) + noisAmp*(randn(1,n) + 1i*randn(1,n));
end

%% Function to implement Rician Fading
function fadedSignal = ricianFading(passBandAnalog, noisAmp)
    fadedSignal = passBandAnalog + 0*noisAmp;
end
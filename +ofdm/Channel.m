classdef Channel
    % Channel for signal transmission
    % Add noise and implement fading(Rayleigh or Rice)
    properties
        noisySignal                 % Signal post fading and AWGN
        noiseVariance               % TODO: Figure this out
        channelCharacterization     % Channel Transfer function for equalization
    end
    
    methods
        function link = Channel(passBandAnalog, sigAmp, speculardB, type, t, Ts)
            link.noiseVariance = 10^-(sigAmp/10);
            if type == "gauss"
                [link.noisySignal, link.channelCharacterization] = addGaussianNoise(passBandAnalog, link.noiseVariance);
            elseif type == "rayl"
                [link.noisySignal, link.channelCharacterization] = rayleighFading(passBandAnalog, link.noiseVariance, t, Ts);
            elseif type == "rice"
                [link.noisySignal, link.channelCharacterization] = ricianFading(passBandAnalog, speculardB, link.noiseVariance, t, Ts);
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
function [fadedSignal, channelChar] = rayleighFading(passBandAnalog, No, t, Ts)
    % Slow, flat fading therefore over a symbol period. Pass symbCount, symbDuration
    n = length(passBandAnalog);
    symbCount = ceil(max(t)/Ts);
    fading = randn(1,symbCount) + 1i*randn(1,symbCount);
    % Repeat fading over symbol interval for slow fading
    channelChar = (1/sqrt(2))*repelem(fading, floor(n/symbCount));
    % If element count doesn't match, append last element until they do
    m = length(channelChar);
    if n ~= m
        channelChar = [channelChar repelem(channelChar(m), n - m)];
    end
    fadedSignal = passBandAnalog.*channelChar + (randn(1,n) + 1i*randn(1,n));
    % TODO: Figure out the place of No in all this
end

%% Function to implement Rician Fading
function [fadedSignal, channelChar] = ricianFading(passBandAnalog, speculardB, No, t, Ts)
    n = length(passBandAnalog);
    symbCount = ceil(max(t)/Ts);
    % Rice Special
    K = 10^(speculardB/10);
    % H = sqrt(K/(K+1)) + sqrt(1/(K+1))*Ray_model(L);
    fading = randn(1,symbCount) + 1i*randn(1,symbCount);
    channelChar = sqrt(K/(K+1)) + sqrt(1/(K+1))*(1/sqrt(2))*repelem(fading, floor(n/symbCount));
    m = length(channelChar);
    if n ~= m
        channelChar = [channelChar repelem(channelChar(m), n - m)];
    end
    fadedSignal = passBandAnalog.*channelChar + (randn(1,n) + 1i*randn(1,n));
    % TODO: Noise Variance?
end
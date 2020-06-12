classdef Channel
    % Channel for signal transmission
    % Add noise and implement fading(Rayleigh or Rice)
    properties
        noisySignal
    end
    
    methods
        function link = Channel(passBandAnalog, type)
            if type == "gauss"
                link.noisySignal = addGaussianNoise(passBandAnalog);
            elseif type == "rayl"
                link.noisySignal = rayleighFading(passBandAnalog);
            elseif type == "rice"
                link.noisySignal = ricianFading(passBandAnalog);
            end
        end
    end
end

%% Function to make AWGN Channel
function noisySignal = addGaussianNoise(passBandAnalog)
    noisySignal = passBandAnalog + 0.5*randn(size(passBandAnalog));
end

%% Function to implement Rayleigh Fading
function fadedSignal = rayleighFading(passBandAnalog)
    fadedSignal = passBandAnalog;
end

%% Function to implement Rician Fading
function fadedSignal = ricianFading(passBandAnalog)
    fadedSignal = passBandAnalog;
end
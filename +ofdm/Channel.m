classdef Channel
    % Channel for signal transmission
    % Add noise and implement fading(Rayleigh or Rice)
    properties
        noisySignal                 % Signal post fading and AWGN
        % noiseVariance               % TODO: Figure this out
        channelCharacterization     % Channel Transfer function for equalization
    end
    
    methods
        function link = Channel(transmitter, sigAmp, speculardB, type)
            rfFlag = transmitter.rfFlag;
            %if (rfFlag)
             %   transmitSig = sigAmp*transmitter.passBandAnalog;
            %else
             %   transmitSig = sigAmp*transmitter.baseBandOfdmSig;
            %end
            transmitSig = transmitter.baseBandOfdmSig;
            t = transmitter.nTs;
            Ts = transmitter.symbolTime;
            No = 10^-(sigAmp/10);
            if type == "gauss"
                [link.noisySignal, link.channelCharacterization] = addGaussianNoise(transmitSig, No);
            elseif type == "rayl"
                [link.noisySignal, link.channelCharacterization] = rayleighFading(rfFlag, transmitSig, No, t, Ts);
            elseif type == "rice"
                [link.noisySignal, link.channelCharacterization] = ricianFading(rfFlag, transmitSig, speculardB, No, t, Ts);
            end
        end
    end
end

%% Function to make AWGN Channel
function [noisySignal, channelChar] = addGaussianNoise(transmitSig, No)
    n = length(transmitSig);
    channelChar = 1;
    %noisySignal = transmitSig + sqrt(No/2)*(randn(1,n) + 1i*randn(1,n));
    noisySignal = transmitSig + No*(randn(1,n) + 1i*randn(1,n))*sqrt(1/2);
end

%% Function to implement Rayleigh Fading
function [fadedSignal, channelChar] = rayleighFading(rfFlag, transmitSig, No, t, Ts)
    n = length(transmitSig);
    if rfFlag
        % Slow, flat fading therefore over a symbol period. Pass symbCount, symbDuration
        symbCount = ceil(max(t)/Ts);
        fading = randn(1,symbCount) + 1i*randn(1,symbCount);
        % Repeat fading over symbol interval for slow fading
        channelChar = (1/sqrt(2))*repelem(fading, floor(n/symbCount));
        % If element count doesn't match, append last element until they do
        m = length(channelChar);
        if n ~= m
            channelChar = [channelChar repelem(channelChar(m), n - m)];
        end
    else
        channelChar = (1/sqrt(2))*(randn(1,n) + 1i*randn(1,n));
    end
    %fadedSignal = transmitSig.*channelChar + sqrt(No/2)*(randn(1,n) + 1i*randn(1,n));
    fadedSignal = transmitSig.*channelChar + No*(randn(1,n) + 1i*randn(1,n))*sqrt(1/2);
    % TODO: Figure out the place of No in all this
end

%% Function to implement Rician Fading
function [fadedSignal, channelChar] = ricianFading(rfFlag, transmitSig, speculardB, No, t, Ts)
    n = length(transmitSig);
    K = 10^(speculardB/10);
    if rfFlag
        symbCount = ceil(max(t)/Ts);
        % Rice Special
        % H = sqrt(K/(K+1)) + sqrt(1/(K+1))*Ray_model(L);
        fading = randn(1,symbCount) + 1i*randn(1,symbCount);
        channelChar = sqrt(K/(K+1)) + sqrt(1/(K+1))*(1/sqrt(2))*repelem(fading, floor(n/symbCount));
        m = length(channelChar);
        if n ~= m
            channelChar = [channelChar repelem(channelChar(m), n - m)];
        end
    else
        channelChar = sqrt(K/(K+1)) + sqrt(1/(K+1))*(1/sqrt(2))*(randn(1,n) + 1i*randn(1,n));
    end
    %fadedSignal = transmitSig.*channelChar + sqrt(No/2)*(randn(1,n) + 1i*randn(1,n));
    fadedSignal = transmitSig.*channelChar + No*(randn(1,n) + 1i*randn(1,n))*sqrt(1/2); 
end
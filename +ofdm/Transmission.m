classdef Transmission
    % Initializes channel and receiver
    properties
        % noisyPassBand
        rece
    end
    
    methods
        function comm = Transmission(transmitter, sigAmp, speculardB, type)
            if nargin == 0
                % Allow 'underloading' for array initialization.
                return
            end
            t = transmitter.analogTimeBase;
            Ts = transmitter.symbolTime;
            fc = transmitter.centerFreq;
            ofdmVariant = transmitter.variant;
            Dt = transmitter.samplingInterval;
            link = ofdm.Channel(transmitter, sigAmp, speculardB, type);
            noisyPassBand = link.noisySignal;
            h = link.channelCharacterization;
            comm.rece = ofdm.Receiver(noisyPassBand, h, t, ofdmVariant, Ts, fc, Dt);
        end
    end
end
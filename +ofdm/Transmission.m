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
            % Save some memory by reducing precision
            t = transmitter.analogTimeBase;
            Ts = single(transmitter.symbolTime);
            fc = single(transmitter.centerFreq);
            Dt = single(transmitter.samplingInterval);
            %--------------
            ofdmVariant = transmitter.variant;
            link = ofdm.Channel(transmitter, sigAmp, speculardB, type);
            noisyPassBand = link.noisySignal;
            h = link.channelCharacterization;
            clear link;
            comm.rece = ofdm.Receiver(noisyPassBand, h, t, ofdmVariant, Ts, fc, Dt);
        end
    end
end
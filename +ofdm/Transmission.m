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
            t = transmitter.nTs;
            Ts = single(transmitter.symbolTime);
            fc = single(transmitter.centerFreq);
            Dt = transmitter.samplingInterval;
            rfFlag = transmitter.rfFlag;
            %--------------
            ofdmVariant = transmitter.variant;
            link = ofdm.Channel(transmitter, sigAmp, speculardB, type);
            noisySignal = link.noisySignal;
            h = link.channelCharacterization;
            clear link;
            comm.rece = ofdm.Receiver(rfFlag, noisySignal, h, t, ofdmVariant, Ts, fc, Dt);
        end
    end
end
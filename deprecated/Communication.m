classdef Communication
    % Communication class: This is the Comms Engine, everything runs through it
    properties
        dataSource
        transmitter
        channel
        receiver
    end
    
    methods
        function comm = Communication(bitCount, ofdmVariant, symbolTime, centerFreq, samplingInterval, channelType, sigAmp, speculardB)
            if nargin == 0
                % Allow 'underloading' for array initialization.
                return
            end
            import ofdm.*;
            % Create a datasource object: serial data for trans
            comm.dataSource = ofdm.DataSource(bitCount);
            % Create a transmitter object: OFDM signal
            comm.transmitter = ofdm.Transmitter(comm.dataSource.serialBits, ofdmVariant, symbolTime, centerFreq, samplingInterval, sigAmp);
            % Create a channel object: Noisy, faded signal
            comm.channel = ofdm.Channel(comm.transmitter.passBandAnalog, sigAmp, speculardB, channelType, comm.transmitter.analogTimeBase, symbolTime);
            % Create a receiver object: Demodulated data
            comm.receiver = ofdm.Receiver(comm.channel.noisySignal, comm.channel.channelCharacterization, comm.transmitter.analogTimeBase, ofdmVariant, symbolTime, centerFreq, samplingInterval);
            % Create a recepient object: rece serial data
        end
    end
end

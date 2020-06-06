classdef Communication
    % Communication class: This is the Comms Engine, everything runs
    % through it
    
    properties
        dataSource
        transmitter
        channel
        receiver
        berEval
    end
    
    methods
        function comm = Communication(bitCount, numSubCarriers, samplingFrequency, centerFreq, channelType)
            % Construct an instance of this class
            import ofdm.*;
            % Create a datasource object: serial data for trans
            comm.dataSource = ofdm.DataSource(bitCount);
            % Create a transmitter object: OFDM signal
            comm.transmitter = ofdm.Transmitter(comm.dataSource.serialBits, numSubCarriers, samplingFrequency, centerFreq);
            % Create a channel object: Noisy, faded signal
            comm.channel = ofdm.Channel(comm.transmitter.passBandAnalog, channelType);
            % Create a receiver object: Demodulated data
            comm.receiver = ofdm.Receiver(comm.channel.noisySignal);
            % Create a recepient object: rece serial data
        end
     
    end
end


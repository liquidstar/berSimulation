classdef Transmission
	%
	% Makes several channels and receivers
	% out of the same transmitter
	%
	properties
		rece
	end
	
	methods
		function comm = Transmission(transmitter, sigAmp, speculardB, type)
			if nargin == 0
				% Allow 'underloading' for Transmission() vector initialization.
				return
			end
			% Save some typing
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
			clear link; % CPU dollars for RAM pennies
			comm.rece = ofdm.Receiver(rfFlag, noisySignal, h, t, ofdmVariant, Ts, fc, Dt);
		end
	end
end

clc;clear;clf;
warning('off'); % Not my proudest

%% Interface() preliminaries
CLI = Interface();
% Save some typing later
bitCount = CLI.bitCount;
rfFlag = CLI.rfFlag;
Ts = CLI.Ts;
fc = CLI.fc;
KdB = CLI.KdB;

% Not making the menu, kid
channelType = ["gauss", "rayl", "rice"];
%channelType = ["gauss"];
%channelType = ["rayl"];
%channelType = ["rice"];

variant = CLI.variant;
sigAmp = 0:1:30;

%% Simulation of Communication
dataSource = ofdm.DataSource(bitCount);
transmitter = ofdm.Transmitter(rfFlag, dataSource, variant, Ts, fc);
% Evaluator: Gets PAPR from transmitter
commCount = length(sigAmp);
for j = 1:length(channelType)
	eval = ofdm.Evaluator(transmitter);
	% Channel and reception for different SNRs
	for i = 1:commCount
		comm = ofdm.Transmission(transmitter, sigAmp(i), KdB, channelType(j));
		CLI.showStatus(CLI, i, commCount);
		eval = eval.getBer(dataSource, comm);
		clear comm;
	end
	% BER plot and show PAPR
	CLI.showReport(eval, sigAmp, CLI, channelType);
	load simData.mat;
	% Save data
	berArray = [berArray; eval.bitErrors];
	save simData berArray;
	clear berArray;
end


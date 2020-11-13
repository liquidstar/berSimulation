clc;
%% Interface instance
CLI = Interface();
% Interface() properties
bitCount = CLI.bitCount;
rfFlag = CLI.rfFlag;
Ts = CLI.Ts;
fc = CLI.fc;
KdB = CLI.KdB;
channelType = CLI.channelType;
variant = CLI.variant;
% vvvvdddddpdddddddddddddpddddddvddddddpdddddddddddddpdddddvvvvv
sigAmp = 0:1:30;

%% Simulation of Communication
dataSource = ofdm.DataSource(bitCount);
transmitter = ofdm.Transmitter(rfFlag, dataSource, variant, Ts, fc, 0.49*(fc)^-1);
% Evaluator: Gets PAPR from transmitter
commCount = length(sigAmp);
eval = ofdm.Evaluator(transmitter);
% Channel and reception for different SNRs
for i = 1:commCount
    comm = ofdm.Transmission(transmitter, sigAmp(i), KdB, channelType);
    CLI.showStatus(CLI, i, commCount);
    eval = eval.getBer(dataSource, comm);
    clear comm;
end
% BER plot and show PAPR
CLI.showReport(eval, sigAmp);
clc;clear;
%% Entrypoint to Simulation of BER of OFDM Variant in a Fading Channel
% Handles all console prints
%% A word about ofdmVariant: It's the subcarrier config
% Proto example: "vvvdddvdddvv"
ieee80211 = carrierMap('vdpdpdvdpdpdv', [5 5 1 13 1 6 1 6 1 13 1 5 6]);
sigAmp = 1:1:30;
% TODO: Ask for user input to supply program variables
bitCount = int32(100000);
Ts = (4e-6);
fc = (2.4e9);
KdB = int8(10);
% A single dataSource instance ... The only necessary attribute is srcBits
dataSource = ofdm.DataSource(bitCount);
% A single transmitter instance ... Necessary attributes: baseBandOfdmSig, passBandOfdm
% (dataSource, ofdmVariant, symbolTime, centerFreq, samplingInterval)
transmitter = ofdm.Transmitter(dataSource, ieee80211, Ts, fc, 0.49*(fc)^-1);
% An Array of receiver instances ... Necessary attributes: serRecBits
commCount = length(sigAmp);
eval = ofdm.Evaluator(transmitter);
% commArray = repelem(ofdm.Transmission(),commCount);
for i = 1:commCount
    comm = ofdm.Transmission(transmitter, sigAmp(i), KdB, "gauss");
    showProgress(i,commCount);
    eval = eval.getBer(dataSource, comm);
    clear comm;
end
% %% Creation of communication instances and associated data
% % Preallocating communication array
% for i = 1:commCount
%     commArray(i) = ofdm.Communication(100000, ieee80211, 4e-6, 2.4e9, .49*(2.4e9)^-1, "gauss", sigAmp(i), 10);    
%     showProgress(i,commCount);
% end
% fprintf('\n');
% 
% % Get a BER evaluation from several comm instances and plot them
% evaluator = ofdm.Evaluator(commArray);
%% Parse OFDM config
function variant = carrierMap(carrGrps, carrCounts)
    variant = repelem(carrGrps, carrCounts);
end

%% Show simulation progress
function showProgress(i,commCount)
    progReport = [repelem('#',i) repelem('-', commCount-i)];
    clc;
    fprintf("Progress: %.2f%% [%s]",100*i/commCount,progReport);
end
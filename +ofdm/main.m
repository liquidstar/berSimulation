clc;clear;
%% Entrypoint to Simulation of BER of OFDM Variant in a Fading Channel
% Handles all console prints
%% A word about ofdmVariant: It's the subcarrier config
% Proto example: "vvvdddvdddvv"
ieee80211 = carrierMap('vdpdpdvdpdpdv', [5 5 1 13 1 6 1 6 1 13 1 5 6]);
sigAmp = 1:19;

%% Creation of communication instances and associated data
% Preallocating communication array
commCount = length(sigAmp);
commArray = repelem(ofdm.Communication(),commCount);
for i = 1:commCount
    commArray(i) = ofdm.Communication(100, ieee80211, 4e-6, 2.4e9, .49*(2.4e9)^-1, "gauss", sigAmp(i));    
    showProgress(i,commCount);
end
fprintf('\n');

% Get a BER evaluation from several comm instances and plot them
evaluator = ofdm.Evaluator(commArray);
%% Parse OFDM config
function variant = carrierMap(carrGrps, carrCounts)
    variant = repelem(carrGrps, carrCounts);
end

%% Show simulation progress
function progReport = showProgress(i,commCount)
    progReport = [repelem('#',i) repelem('-', commCount-i)];
    clc;
    fprintf("Progress: %.2f%% [%s]",100*i/commCount,progReport);
end
clc;clear;
%% Entrypoint to Simulation of BER of OFDM Variant in a Fading Channel
% Handles all console prints
%% A word about ofdmVariant: It's the subcarrier config
% Proto example: "vvvdddvdddvv"
ieee80211 = carrierMap('vdpdpdvdpdpdv', [5 5 1 13 1 6 1 6 1 13 1 5 6]);

%% Class communication
% Parameters: (bitCount, ofdmVariant, symDuration, centerFreq, samplingInterval, channelType)
comm = ofdm.Communication(100, ieee80211, 4e-6, 2.4e9, .49*(2.4e9)^-1, "gauss");

% Get a BER evaluation from several comm instances and plot them

%% Parse OFDM config
function variant = carrierMap(carrGrps, carrCounts)
    variant = repelem(carrGrps, carrCounts);
end
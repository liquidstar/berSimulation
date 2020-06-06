clc;clear;
%% Entrypoint to Simulation of BER of OFDM Variant in a Fading Channel
% Handles all console prints
%% Class communication
% Parameters: (bitCount, numSubCarriers, samplingFreq, centerFreq, channelType)
comm = ofdm.Communication(800, 10, 1e4, 1e10, "gauss");
% Get a BER evaluation from several comm instances and plot them
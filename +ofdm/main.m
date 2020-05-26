clc;clear;
%% Entrypoint to Simulation of BER of OFDM Variant in a Fading Channel
% Handles all console prints
comm = ofdm.Communication(50);
% Get a BER evaluation from several comm instances and plot them
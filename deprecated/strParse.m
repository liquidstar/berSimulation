clear;clc;close all;
% subcarrier grouping
carrGrps = 'vdpdpdvdpdpdv';
% subcarrier count
carrCounts = [5 5 1 13 1 6 1 6 1 13 1 5 6];
% actual subcarrier arrangements
s = repelem(carrGrps, carrCounts);

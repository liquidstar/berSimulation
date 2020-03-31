%% When the shell won't do for dickin' around
clc; clear; close all;
sample = 0.01;      % Sampling interval for carrier ##
symbol_time = 5;    % Number of periods a symbol covers / 2 ##

% Sample times
t = 0:sample*pi:(20-sample)*pi; % ##
% Random bits to correspond to sample intervals and symbol duration
src_data = round(rand(1,symbol_time^(-1)*length(t)/sample^(-1)));

% Map data to alphabet
symbol_alphabet = [ 1, -1]; % BPSK
src_symbols = symbol_alphabet(src_data+1);
% Make symbol array equal sample array in size
src_symbols = repelem(src_symbols,symbol_time*sample^(-1));

% The output
y = src_symbols.*cos(t);
plot(t,y);ylim([-1.1 1.1]);

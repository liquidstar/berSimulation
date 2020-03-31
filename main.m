clear;clc;close all;

%% This will give the input goodies :: Parameters are (sampling interval, symbol duration)
%   data_in   : Input randon bits (1s and 0s)
%   tx_symbols: Input bits mapped to symbols
%   alph      : Symbol Alphabet :: Debug feature
%   y         : matrix to be input to ifft()
%   bin_symb  : Input symbols repeated for modulation :: Debug Feature
%   bin_symb_t: Input symbols unrepeated :: Debug Feature
[data_in, tx_symbols,alph, y,t,bin_symb, bin_symb_t] = transmitter(0.01, 5);

%% Debugging graphical aid
hold on;
for i = 1:10
    plot(t,0.1*i.*y(i,:));
end
%ylim([-1.1 1.1]);

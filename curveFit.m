clear;clc;clf;
load riceFitter.mat;
load bers.mat;

x = -30:0.1:30;
y = qfunc(x);

%semilogy(snrs,bersAWGN);hold on;
%semilogy(snrs,bersRayl);
%semilogy(snrs,bersRice);grid on;
semilogy(snrs, riceBerMatrix, '--');hold on;grid on;
semilogy(snrs, bersRayl, '.-');semilogy(snrs,bersAWGN, '.-');
ylim([1e-7 1]);xlim([0 30])

% Test Bed Starts here
%% RAYL
%semilogy(11.1+3.05*x, 0.5*y);
%semilogy(-35+11*x, 10000*y);
%%AWGN
%semilogy(7.5+2.5*x, 0.47*y);
%semilogy(10 + 1.17*x, 0.15*y);
%%RICE10
%semilogy(8+2.4*x, 0.47*y);
%semilogy(10.3+1.3*x, 0.15*y);
%%RICE9
%semilogy(8.1+2.44*x, 0.47*y);
%semilogy(10.5+1.32*x, 0.15*y);
%%RICE8
%semilogy(8.25+2.44*x, 0.47*y);
%semilogy(10.7+1.39*x, 0.15*y);
%%RICE7
%semilogy(8.7+2.3*x, 0.47*y);
%semilogy(-18+9*x, 10*y);
%%RICE6
%semilogy(9+2.37*x, 0.47*y);
%semilogy(-14.1+8.5*x, 10*y);
%%RICE5
%semilogy(9.5+2.42*x, 0.46*y);
%semilogy(-21.2+9*x, 200*y);
%%RICE4
%semilogy(9.7+2.7*x, 0.46*y);
%semilogy(-22.5+9.5*x, 200*y);
%%RICE3
semilogy(10+2.8*x, 0.47*y);
semilogy(-21.2+9.4*x, 200*y);


%semilogy(10.8+2.85*x, 0.47*y);
%semilogy(10.8+2.6*x, 0.05*y);
%y = 10.^(-0.220724*x + 1.865);
%semilogy(x, y)
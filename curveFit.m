clear;clc;clf;
load riceFitter.mat;
load bers.mat;

x = -30:0.1:30;
y = qfunc(x);

%semilogy(snrs,bersAWGN);hold on;
%semilogy(snrs,bersRayl);
%semilogy(snrs,bersRice);grid on;
%ZOOMED IN
subplot(2,1,1);
semilogy(snrs, riceBerMatrix, '--');hold on;grid on;
semilogy(snrs, bersRayl, '.-');semilogy(snrs,bersAWGN, '.-');
ylim([1e-2 0.6]);xlim([5 15])
%ylim([0.03 0.2]);xlim([9 12])
%plotRice4(x,y);
plotTest(x,y);
%ZOOMED OUT
subplot(2,1,2);
semilogy(snrs, riceBerMatrix, '--');hold on;grid on;
semilogy(snrs, bersRayl, '.-');semilogy(snrs,bersAWGN, '.-');
ylim([1e-7 1]);xlim([5 15])
%plotRice4(x,y);
plotTest(x,y);


% Test Bed Starts here
%% RAYL
function plotRayl(x,y)
    semilogy(11.1+3.05*x, 0.5*y);
    semilogy(-35+11*x, 10000*y);
end
%%AWGN
function plotAwgn(x,y)
    semilogy(7.5+2.5*x, 0.47*y);
    semilogy(10 + 1.17*x, 0.15*y);
end
%%RICE10
function plotRice10(x,y)
    semilogy(8.5+1.9*x, 0.4*y);
    %semilogy(7.85+2.52*x, 0.47*y);
    %semilogy(10.35+1.27*x, 0.15*y);
end
%%RICE9
function plotRice9(x,y)
    semilogy(8.7+1.95*x, 0.4*y);
    %semilogy(8.1+2.53*x, 0.47*y);
    %semilogy(10.6+1.35*x, 0.15*y);
end
%%RICE8
function plotRice8(x,y)
    semilogy(8.9+2*x, 0.4*y);
    %semilogy(8.2+2.54*x, 0.47*y);
    %semilogy(10.7+1.4*x, 0.15*y);
end
%%RICE7
function plotRice7(x,y)
    semilogy(9.1+2.1*x, 0.4*y);
%semilogy(8+4.6*x, 0.47*y);    
%semilogy(8.5+1.8*x, 0.4*y);
    %semilogy(10.7+1.4*x, 0.15*y);
    %semilogy(-18+9*x, 10*y);
end
%%RICE6
function plotRice6(x,y)
    semilogy(9.4+2.2*x, 0.41*y);
    %semilogy(9+2.37*x, 0.47*y);
    %semilogy(-14.1+8.5*x, 10*y);
end
%%RICE5
function plotRice5(x,y)
    semilogy(9.8+2.35*x, 0.41*y);
    %semilogy(9.5+2.42*x, 0.46*y);
    %semilogy(-21.2+9*x, 200*y);
end
%%RICE4
function plotRice4(x,y)
    semilogy(10.1+2.53*x, 0.41*y);
    %semilogy(9.7+2.7*x, 0.46*y);
    %semilogy(-22.5+9.5*x, 200*y);
end
%%RICE3
function plotRice3(x,y)
    semilogy(10.5+2.55*x, 0.42*y);
    %semilogy(10+2.8*x, 0.47*y);
    %semilogy(-21.2+9.4*x, 200*y);
end
%%RICE2
function plotRice2(x,y)
    semilogy(10.8+2.6*x, 0.425*y);
    %semilogy(10.4+2.8*x, 0.47*y);
    %semilogy(-19.5+9.15*x, 200*y);
end
%%RICE1
function plotRice1(x,y)
    semilogy(11+2.69*x, 0.43*y);
    %semilogy(10.6+2.87*x, 0.47*y);
    %semilogy(-27.7+10*x, 2000*y);
end
%%RICE0
function plotRice0(x,y)
    semilogy(11.1+2.72*x, 0.44*y);
    %semilogy(10.8+2.9*x, 0.47*y);
    %semilogy(-27.2+10*x, 2000*y);
end

function plotTest(x,y)
    k = 10.5;
    if k >= 5
       a = 0.4;
    else
       a = 0.004*k^2 - 0.0081*k + 0.4392; 
    end
    b = -0.2895*k + 11.222;
    c = -0.0917*k + 2.785;
    semilogy(b+c*x, a*y);
    %semilogy(10.8+2.9*x, 0.47*y);
    %semilogy(-27.2+10*x, 2000*y);
end

%semilogy(10.8+2.85*x, 0.47*y);
%semilogy(10.8+2.6*x, 0.05*y);
%y = 10.^(-0.220724*x + 1.865);
%semilogy(x, y)
clear;clc;clf;
load riceFitter.mat;
load bers.mat;

x = -30:0.1:30;
y = qfunc(x);

%semilogy(snrs,bersAWGN);hold on;
%ZOOMED IN
%subplot(2,1,1);
%semilogy(snrs, riceBerMatrix, '--');
%riceMatrix2 = [];
%riceMatrix2 = [riceMatrix2; riceBerMatrix(1,:)];
%riceMatrix2 = [riceMatrix2; riceBerMatrix(4,:)];
%riceMatrix2 = [riceMatrix2; riceBerMatrix(11,:)];
%semilogy(snrs, riceMatrix2, '--x', 'linewidth', 1.2, 'MarkerSize', 8);
%hold on;grid on;
%xlabel('SNR(dB)');ylabel('BER');title('Rician Channel Model');
semilogy(snrs,riceBerMatrix, '--x', 'linewidth', 1.2, 'MarkerSize', 8);hold on; grid on;
plotTest(x,y,4);
xlabel('SNR(dB)');ylabel('BER');title('Rician Curve fitting process');
%semilogy(snrs,bersAWGN, '.-');
%semilogy(7.5+2.5*x,0.47*y);hold on; grid on;
ylim([1e-7 1]);xlim([0 30]);

%plotRayl(x,y)

%semilogy(snrs,bersAWGN, '.-');
%ylim([1e-6 1]);xlim([0 20])
%plotTest(x,y,10);
%plotTest(x,y,3);
%plotTest(x,y,0);
%legend('$0.4Q\left(\frac{x - 8.327}{1.868}\right)$', '$0.4509Q\left(\frac{x - 10.3535}{2.5099}\right)$', '$0.4392Q\left(\frac{x - 11.222}{2.785}\right)$');
%legend('K = 0','K = 3', 'K = 10', '0.4Q(1.9x - 8.5)', '0.42Q(2.55x - 8.5)', '0.44Q(2.72x - 11.1)');
%ylim([0.03 0.2]);xlim([9 12])
%plotAwgn(x,y);
%plotTest(x,y);
%ZOOMED OUT
%subplot(2,1,2);
%semilogy(snrs, riceBerMatrix, '--');hold on;grid on;
%semilogy(snrs, bersRayl, '.-');semilogy(snrs,bersAWGN, '.-');
%ylim([1e-7 1]);xlim([5 15])
%plotRice4(x,y);
%plotTest(x,y);


% Test Bed Starts here
%% RAYL
function plotRayl(x,y)
    semilogy(11.1+3.05*x, 0.5*y, 'linewidth', 1.5);
    semilogy(-35+11*x, 10000*y, 'linewidth', 1.5);
    legend('Simulated BER','$0.5Q\left(\frac{x - 11.1}{3.05}\right)$', '$1_E4Q\left(\frac{x - 35}{11}\right)$');
end
%%AWGN
function plotAwgn(x,y)
    semilogy(7.5+2.5*x, 0.47*y);
    semilogy(10 + 1.17*x, 0.15*y);
    legend('Simulated BER', '$0.47Q\left(\frac{x - 7.5}{2.5}\right)$', '$0.15Q\left(\frac{x - 10.5}{1.17}\right)$');
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
    semilogy(10+2.4*x, 0.41*y);
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

function plotTest(x,y,k)
    if k >= 5
       a = 0.4;
    else
       a = 0.004*k^2 - 0.0081*k + 0.4392; 
    end
    b = -0.2895*k + 11.222;
    c = -0.0917*k + 2.785;
    semilogy(b+c*x, a*y, 'linewidth', 2);
    %semilogy(10.8+2.9*x, 0.47*y);
    %semilogy(-27.2+10*x, 2000*y);
end

%semilogy(10.8+2.85*x, 0.47*y);
%semilogy(10.8+2.6*x, 0.05*y);
%y = 10.^(-0.220724*x + 1.865);
%semilogy(x, y)
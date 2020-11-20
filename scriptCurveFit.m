clear;clc;clf;
load bers.mat;
load riceFitter.mat


snrVector=0:0.1:30;
fprintf('Choose channel to curve Fit\n');
fprintf('1.AWGN\n2.Rayleigh\n3.Rician\n');
fprintf('+-------------------------\n');
channel=input('');
fprintf('+-------------------------\n');
if isempty(channel)
    channel=1;
end

if channel==1
    plotAwgn(snrVector,snrs,bersAWGN);
elseif channel==2
    plotRayl(snrVector,snrs,bersRayl);
elseif channel==3
    k=input('Input value of K: ');
    plotRice(snrVector,snrs,riceBerMatrix,k, bersRayl, bersAWGN);
    
else
    fprintf('Invalid selection please try again');
end
BERs=[];
function plotAwgn(snrVector,snrs,bersAWGN)
    for yy=1:length(snrVector)
        xx=snrVector(yy);
        if xx<=9.5
            y=0.47*qfunc((xx-7.5)/2.5);
        elseif xx<=15
            y=0.15*qfunc((xx-10)/1.17);
        else
            y=0;
        end
        BERs(yy,:)=y;
    end 
    semilogy(snrs,bersAWGN, '.-');
    hold on;grid on;
    semilogy(snrVector,BERs);
    legend('AWGN','AWGN Fit')
    xlabel('SNR(dB)');ylabel('BER');title('AWGN Curve fit');
end
function plotRayl(snrVector,snrs,bersRayl)
    for yy=1:length(snrVector)
        xx=snrVector(yy);
        if xx<=17
            y=0.49*qfunc((xx-11.1)/3.05);
        else
            y=10000*qfunc((xx+35)/11);
        end
        BERs(yy,:)=y;
    end 
    semilogy(snrs,bersRayl, '.-');
    hold on;grid on;
    semilogy(snrVector,BERs);
    xlim([0 15])
    legend('Rayleigh','Rayleigh Fit')
    xlabel('SNR(dB)');ylabel('BER');title('Rayleigh Curve fit');
end

function plotRice(snrVector,snrs,riceBerMatrix,k, bersRayl, bersAWGN)
    for yy=1:length(snrVector)
        xx=snrVector(yy);
        if xx<0
            y=0.5;
        else
            if k<0
               plotRayl(snrVector,snrs,bersRayl);
               return
               
            elseif k<5
                y=(0.004*k^2-0.0081*k+0.4392)*qfunc((xx-(-0.2895*k+11.222))/(-0.0917*k+2.785));
            elseif k<=10
                y=0.4*qfunc((xx-(-0.2895*k+11.222))/(-0.0917*k+2.785));
            else
                plotAwgn(snrVector,snrs,bersAWGN);
                return
            end
        end
        BERs(yy,:)=y;
    end
    yyy=riceBerMatrix(k+1,:);
    semilogy(snrs,yyy, '.-');
    hold on;grid on;
    semilogy(snrVector,BERs);
    xlim([0 15])
    legend('Rician','Rician Fit')
    xlabel('SNR(dB)');ylabel('BER');title('Rician Curve fit');
end

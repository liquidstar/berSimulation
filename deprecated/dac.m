%% Ideal Interpolator Digital to Analog Conversion
% Practically infeasible due to non-causality
% (When summing sinc() pulses you need to know the entire sequence beforehand)
close all;clear all;clc;
% Discrete-time signal : x(n)
count = 50;
% Ts is akin to symbol time
% n = 0:count; 
%x = rand(1, length(n));
load('baseband.mat');
x = real(x);
Ts = 10e-4;
n = 1:length(x);
nTs = n*Ts;
fc = 1e5;

%% Analog signal reconstruction
% Dt : tending to zero but ... reality
% t : Conversion range
Dt = 5e-5;
t = 0:Dt:(length(x)*Ts);
% tbh I'm still trying to understand the below line
% xa = x * sinc(Ts^-1 * (ones(length(n),1)*t-nTs'*ones(1,length(t))));
xa = spline(nTs, x, t);
xaRF = xa.*(2*pi*cos(fc*t));
%plot(t,xa);
%hold on;
%stem(nTs,x);
xaRec = xaRF.*(2*pi*cos(fc*t));
xaLPF = lowpass(xaRec,1e2,fc);
% plotting
subplot(2,2,1);plot(t,xa);title("Baseband Analog Signal");
subplot(2,2,2);plot(t,xaRF);title("RF Analog Signal");
subplot(2,2,3);plot(t,xaRec);title("Coherence Mixed Analog Signal");

%% Analog to Digital
%samples = linspace(1,length(xa),length(x)+1);
%xn = xaLPF(samples);
%figure(2);

subplot(2,2,4);plot(t,xaLPF);title("Baseband ReceivedAnalog Signal");
%hold on;stem(t(samples),xn);



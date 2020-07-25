clear; clc; close all;

src_data = randomBits(480);
bauds = mapBits(src_data);
bauds = reshape(bauds, 48, []);
ofdmVariant = 'vvvvvdddddpdddddddddddddpddddddvddddddpdddddddddddddpdddddvvvvvv';

ifftBins = binBauds(bauds, ofdmVariant);


function bins = binBauds(baudMatrix, ofdmVariant)
    % TODO: Pass a vector to map carriers to ifft bins
    % baudMatrix = baudMatrix';
    [baudRows, baudCols] = size(baudMatrix);
    bins = zeros(length(ofdmVariant),baudCols);
    j = 1;
    for i=1:length(ofdmVariant)
        if ofdmVariant(i) == 'v'
            bins(i,:) = zeros(1,baudCols);
        elseif ofdmVariant(i) == 'd'
            bins(i,:) = baudMatrix(j,:);
            j = j + 1;
        elseif ofdmVariant(i) == 'p'
            bins(i,:) = ones(1,baudCols);
        end     
    end
    %binSize = size(bins);
    %binSize(1) = binSize(1)/2;
    %bins = [zeros(floor(binSize)); bins; zeros(ceil(binSize))]';
  
end

 function srcBits = randomBits(bitCount)
    srcBits = int8(round(rand(1,bitCount)));
 end

 function bauds = mapBits(bitArray)
    symAlph = [-1 1];
    bauds = symAlph(bitArray + 1);
 end
 
 %         % Locating the guard interval (in case of phase shift)
%         thisIQDiff = abs(thisSymbI+thisSymbQ)/2;
%         nullIndices = find(thisIQDiff<0.01);
%         nullContig = diff(nullIndices);
%         % Folded loop to find contiguous nulls
%         if isempty(nullContig)
%             % TODO: Find what this condition represents
%             guardIndex = 0;
%         end
%         for j = 1:length(nullContig)
%             if (j+14) <= length(nullContig)
%                 testRange = nullContig(j:j+14);
%             elseif length(nullContig) < 15  % Impossible to locate guard interval (Due to noise)
%                 guardIndex = 0;
%                 break
%             else
%                 testRange = [nullContig(j:length(nullContig)) nullContig(1:14-(length(nullContig)-j))];
%             end
%             if testRange == ones(1,15)
%                 guardIndex = j;
%                 break
%             else
%                 guardIndex = 0;
%                 break
%             end
%         end
%         % Protection against undetected guard interval
%         if guardIndex == 0
%             guardStartIndex = ofdmSize;
%         else
%             guardStartIndex = nullIndices(guardIndex);
%         end
%         symbEndIndex = guardStartIndex - 1;
%         % TODO: Verify relevance of this logic
%         % Loop to extract unprotected symbol (Check guardStartIndex. If less than min, assume no shift)
%         if guardStartIndex <= 1.25*ofdmSize
%             recSerOfdm(i*ofdmSize+1:(i+1)*ofdmSize) = thisSymbI((0.25*ofdmSize+1):1.25*ofdmSize) + 1i*thisSymbQ((0.25*ofdmSize+1):1.25*ofdmSize);
%         else
%             recSerOfdm(i*ofdmSize+1:(i+1)*ofdmSize) = thisSymbI((symbEndIndex-ofdmSize+1):symbEndIndex) + 1i*thisSymbQ((symbEndIndex-ofdmSize+1):symbEndIndex);
%         end

% %% Creation of communication instances and associated data
% % Preallocating communication array
% for i = 1:commCount
%     commArray(i) = ofdm.Communication(100000, ieee80211, 4e-6, 2.4e9, .49*(2.4e9)^-1, "gauss", sigAmp(i), 10);    
%     showProgress(i,commCount);
% end
% fprintf('\n');
% 
% % Get a BER evaluation from several comm instances and plot them
% evaluator = ofdm.Evaluator(commArray);

%% Extracting SNR data from Communication instances
function snrVector = findSnrs(commArray)
    commCount = length(commArray);
    sigVector = zeros(1,commCount);
    %noisVector = sigVector;
    for i = 1:commCount
        sigVector(i) = commArray(i).transmitter.signalAmplitude;
        %noisVector(i) = commArray(i).channel.noiseAmplitude;
    end
    snrVector = sigVector;  %./noisVector;
end


%% Extraction of BER curves
function ber = findBer(commInst)
    % Compare received serial data to transmitted
    % Assumption: Well fitting data, therefore overflow caused by zero padding is ignored
    % commCount = length(commArray);
    % bers = zeros(1, commCount);
    txData = dataSource.serialBits;
    rxData = commInst.rece.serRecBits(1:length(txData));
    ber = sum(rxData ~= txData)/length(txData);
end
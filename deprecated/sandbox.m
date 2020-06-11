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
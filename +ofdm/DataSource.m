classdef DataSource
    properties (SetAccess = private)
        bitCount
        serialBits
    end
    methods
        function serialData = DataSource(bits)
            % constructor calls random data generator
            serialData.bitCount = bits;
            serialData.serialBits = randomBits(serialData.bitCount);
        end
    end
end

% function to generate random bits
function randomBits = randomBits(bitCount)
    randomBits = int8(round(rand(1,bitCount)));
end
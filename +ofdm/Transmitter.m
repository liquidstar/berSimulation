classdef Transmitter
    %   All transmitter operations
    %   Inherited by modulator and IFFT module (probably)
    properties
        parData
        bauData
    end
    methods
        function trans = Transmitter(serData)
            % serData to parallel (serial)
            trans.parData = reshape(serData, 10, []);   % TODO: Pass number of subcarriers
            % parData to Modulator (parallel)
            trans.bauData = mapBits(trans.parData);
            % bauData to IFFT bins (parallel)
            % binData to IFFT operation (parallel)
            % iffData to guard interval (parallel)
            % cycData to Serial (serial)
            % serOfdmData to Analog (serial)
        end    
    end
end

 function bauds = mapBits(bitArray)
    symAlph = [-1 1];
    bauds = symAlph(bitArray + 1);
 end

 function modSymb = bpskMod(parData)
    % This is where I choose symbol duration and thus subcarrier spacing
    % Subcarrier form: A cos(w*t + phi)
    % Sampling frequency
    % 
    
 end
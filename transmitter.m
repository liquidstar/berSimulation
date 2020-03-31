function [data_in, tx_symbols,alph, y,t,bin_symb, bin_symb_t] = transmitter(sample, symbol_time)
    % Time samples of the simulation
    t = 0:sample*pi:(20-sample)*pi; % That subtraction is useful for matching matrix size later
    % Bring in source data and symbol alphabet
    [data_in,alph,tx_symbols] = src_data(sample, symbol_time, t);
    [y,bin_symb, bin_symb_t] = bpsk(tx_symbols, sample,symbol_time,t);
end

%% Generates random source bits and maps to symbols
function [src_data, symbol_alphabet,tx_symbols] = src_data(sample, symbol_time, t)
    src_data = round(rand(1,10*symbol_time^(-1)*length(t)/sample^(-1)));
    % BPSK symbol mapping
    symbol_alphabet = [ 1, -1];
    % Map input bits to symbol alphabet
    tx_symbols = symbol_alphabet(src_data+1);
end

%% Performs S/P conversion and BPSK modulation
function [ifft_matrix,bin_symb, bin_symb_t] = bpsk(tx_symbols, sample,symbol_time,t)
    % debugging variable, need to reshape original symbols before repeating
    % for modulation
    bin_symb_t = reshape(tx_symbols, 10, []);
    % Repeat symbols as many times as (shit I've forgotten) ... works tho
    bin_symb = repelem(bin_symb_t,1,symbol_time*sample^(-1));
    % //TODO: Needs optimization by preallocation
    temp_t = [];
    % Repeats samples to make matrix of equal size to bin_symb
    % Must find a faster way
    for i=1:10
        temp_t = [temp_t;t];
    end
    % And the matrix feedable to the ifft machine:
    ifft_matrix = bin_symb.*cos(temp_t);
end
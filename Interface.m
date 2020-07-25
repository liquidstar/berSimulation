classdef Interface
    properties
        variant
        bitCount
        rfFlag
        Ts
        fc
        KdB
        channelType
    end
    methods
        function CLI = Interface()
            displayBanner(0);
            [CLI.bitCount, CLI.variant, CLI.rfFlag, CLI.Ts, CLI.fc, CLI.KdB, CLI.channelType] = dataEntry();
        end
    end
    methods(Static)
        function showStatus(CLI, iter, commCount)
            clc;
            displayBanner(0);
            fprintf('\t\t\t\t\t\t\tBits\t|\t%d\n', CLI.bitCount);
            if CLI.rfFlag
                transType = "Passband";
                fprintf('\t\t\t\t\tTransmission\t|\t%s\n', transType);
                fprintf('\t\t\t\t\t\t\t\tTs\t|\t%.1e s\n', CLI.Ts);
                fprintf('\t\t\t\t\t\t\t\tfc\t|\t%.1e Hz\n', CLI.fc);
            else
                transType = "Baseband";
                fprintf('\t\t\t\t\tTransmission\t|\t%s\n', transType);
            end
            % Only for Rician Fading
            displayBanner(1);
            if CLI.channelType == "rice"
                fprintf('\t\t\t\t\tChannel Model\t|\tRician\n');
                fprintf('\t\t\t\t\t\t\t\tK\t|\t%.1f dB\n', CLI.KdB);
            elseif CLI.channelType == "rayl"
                fprintf('\t\t\t\t\tChannel Model\t|\tRayleigh\n');
            else
                fprintf('\t\t\t\t\tChannel Model\t|\tAWGN\n');
            end
            displayBanner(1);
            showProgress(iter, commCount);
            fprintf('\n');
        end
        % function to report from Evaluator()
        function showReport(eval, snrVector)
            displayBanner(1);
            semilogy(snrVector, eval.bitErrors);
            fprintf('PAPR: %.2f\n', eval.papr);
        end
    end
end

%% Print a UI decoration
function displayBanner(bannerNo)
    [text, dashes] = padText('Super Didact');
    if bannerNo == 0
        % overline
        fprintf('\t\t\t\t# - - - - ');
        fprintf(dashes);
        fprintf(' - - - - #\n');
        % text actual
        fprintf('\t\t\t\t# - - - - ');
        fprintf(text);
        fprintf(' - - - - #\n');
        % underline
        fprintf('\t\t\t\t# - - - - ');
        fprintf(dashes);
        fprintf(' - - - - #\n');
    elseif bannerNo == 1
        fprintf('\t\t\t# - - - - - - ');
        stars = repelem(' ', length(dashes));
        stars(dashes == '-') = '*';
        fprintf(stars);
        fprintf(' - - - - - - #\n');
    end
end

%% Parameter input function
function [bitCount, variant, rfFlag, Ts, fc, KdB, channelType] = dataEntry()
    % Prompt user for bit count
    bitCount = input("How many bits, boss?[100,000]");% int32(1e5);
    if isempty(bitCount)
        bitCount = 1e5;
    end
    % User selects OFDM variant
    varChoice = input("Which OFDM variant would you like to use?\n (0).IEEE 802.11\n (1).Custom (Expert)\n [0]");
    if isempty(varChoice) || varChoice == 0
        variant = repelem('vdpdpdvdpdpdv', [5 5 1 13 1 6 1 6 1 13 1 5 6]);
    else
        % enterVariant()
        variant = repelem('vdpdpdvdpdpdv', [5 5 1 13 1 6 1 6 1 13 1 5 6]);
    end
    % User decides whether transmission is over RF
    rfFlag = logical(input("(0).Baseband or (1).Passband transmission?[0] "));
    if isempty(rfFlag)
        rfFlag = false;
    end
    % Passband parameters
    if rfFlag
        Ts = input('Symbol duration[4 us] ');
        if isempty(Ts)
            Ts = 4e-6;
        end
        fc = input('Carrier center frequency[2.4 GHz] ');
        if isempty(fc)
            fc = 2.4e9;
        end
    else
        Ts = 4e-6;
        fc = 2.4e9;
    end
    % Channel Parameters
    KdB = [];
    channel = input('Channel type?\n    (1).AWGN\n    (2).Rayleigh\n    (3).Rician\n[1] ');
    if isempty(channel)
        channel = 1;
    end
    if channel == 1
        channelType = "gauss";
    elseif channel == 2
        channelType = "rayl";
    elseif channel == 3
        channelType = "rice";
        KdB = single(input('Give me K in dB[0] '));
    end
    if isempty(KdB)
        KdB = 0;
    end
end

%% Banner text padding
function [paddedText, matchDashes] = padText(text)
    n = length(text);
    m = 2*n-1;
    paddedText = repelem(' ', m);
    matchDashes = repelem(' ', m);
    for i = 1:n
        if i == 1
            paddedText(i) = text(i);
            matchDashes(i) = '-';
        elseif i == n
            paddedText(m) = text(i);
            matchDashes(m) = '-';
        else
            paddedText(2*i - 1) = text(i);
            matchDashes(2*i - 1) = '-';
        end
    end
end

%% Simulation progress
function showProgress(i,commCount)
    progReport = [repelem('#',i) repelem('-', commCount-i)];
    %clc;
    fprintf("Progress: %.2f%% [%s]",100*i/commCount,progReport);
end


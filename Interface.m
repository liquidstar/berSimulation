classdef Interface
    properties
        variant
        bitCount
        rfFlag
        Ts
        fc
        KdB
    end
    methods
        function CLI = Interface()
            displayBanner(0);
            [CLI.bitCount, CLI.variant, CLI.rfFlag, CLI.Ts, CLI.fc, CLI.KdB] = dataEntry();
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
            %if CLI.channelType == "rice"
            %    fprintf('\t\t\t\t\tChannel Model\t|\tRician\n');
            fprintf('\t\t\t\t\t\t\t\tK\t|\t%.1f dB\n', CLI.KdB);
            displayBanner(1);
            renderVariant(CLI.variant);
            displayBanner(1);
            showProgress(iter, commCount);
            fprintf('\n');
            displayBanner(1);
        end
        % function to report from Evaluator()
        function showReport(eval, snrVector)
            semilogy(snrVector, eval.bitErrors);
            xlabel('SNR [dB]');ylabel('BER');title('BER for OFDM Project Variant');
            xlim([0 15]);ylim([1e-6 1]);
            hold on; grid on;
            fprintf('\t\t\t\t\t\t\tPAPR\t|\t%.2f dB\n', 10*log10(mean(eval.papr)));
        end
    end
end

%% Print a UI decoration
function displayBanner(bannerNo)
    [text, dashes] = padText('BER Simulation');
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
    elseif bannerNo == 2
        fprintf('+-------------------------\n');
    end
end

%% Parameter input function
function [bitCount, variant, rfFlag, Ts, fc, KdB] = dataEntry()
    % Prompt user for bit count
    bitCount = input("How many bits, boss?\n[1,000,000] > ");
    displayBanner(2);
    if isempty(bitCount)
        bitCount = 1e6;
    end
    % User selects OFDM variant
    varChoice = input("Which OFDM variant would you like to use?\n  (0).IEEE 802.11\n  (1).Project Variant\n  (2).Custom (Expert Mode)\n[1] > ");
    displayBanner(2);
    if isempty(varChoice) || varChoice == 1
        variant = enterVariant(1);
    else
        variant = enterVariant(varChoice);
    end
    % No RF presentation required
    rfFlag = [];
    if isempty(rfFlag)
        rfFlag = false;
    end
    % Passband parameters
    if rfFlag
        Ts = input('Symbol duration:\n[4 us] > ');
        displayBanner(2);
        if isempty(Ts)
            Ts = 4e-6;
        end
        fc = input('Carrier center frequency\n[2.4 GHz] > ');
        displayBanner(2);
        if isempty(fc)
            fc = 2.4e9;
        end
    else
        Ts = 4e-6;
        fc = 2.4e9;
    end
    % Specular dB
    KdB = single(input('Give me K in dB\n[0] > '));
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
    fprintf("\t\t\tProgress: %.2f%% [%s]",100*i/commCount,progReport);
end

%% Enter Variant details
function variant = enterVariant(varNo)
    if varNo == 0
        variant.subCarriers = repelem('vdpdpdvdpdpdv', [5 5 1 13 1 6 1 6 1 13 1 5 6]);
        variant.cycPrefix = 25;
        variant.guardInt = 25;
        variant.name = 'IEEE 802.11';
    elseif varNo == 2
        subcarriers = []; cycPrefix = []; guardInt = [];
        while isempty(subcarriers) || ~verifySubcarrierMap(subcarriers)
            subcarriers = input('Subcarrier arrangement: (v)irtual, (d)ata or (p)ilot subcarriers.\ne.g. (vvddpddvddpdddvv) for 5-Virtual, 2-Pilot and 9-Data in the order entered, sans parentheses\n> ', 's');
        end
        while isempty(cycPrefix) || ~isnumeric(cycPrefix) || (cycPrefix > 100 || cycPrefix < 0)
            cycPrefix = input('Cyclic prefix in %:\n (0-100) > ');
        end
        while isempty(guardInt) || ~isnumeric(guardInt)
            guardInt = input('Guard interval in %: ');
        end
        name = input('Variant name: ', 's');
        if isempty(name)
            name = 'Sanctimonious Titter';
        end
        variant.subCarriers = subcarriers;
        variant.cycPrefix = cycPrefix;
        variant.guardInt = guardInt;
        variant.name = name;
    elseif varNo == 1
        variant.subCarriers = repelem('vdpdpdvdpdpdv', [7 11 1 13 1 6 1 6 1 13 1 11 8]);
        variant.cycPrefix = 25;
        variant.guardInt = 25;
        variant.name = 'Project Variant';
    end
end

%% Verify subcarriers
function valid = verifySubcarrierMap(subcarriers)
    if ischar(subcarriers)
        legal = 'vpd';
        for i = 1:length(subcarriers)
            if isempty(find(legal == subcarriers(i),1))
                valid = false;
                return
            end
        end
        valid = true;
    else
        valid = false;
    end
end

%% Render variant graphically
function renderVariant(variant)
    subCarriers = variant.subCarriers;
    ofdmSize = length(subCarriers);
    % first line - pilots only
    fprintf('\n\t\t\t\t\tOFDM Variant\t|\t%s\n', variant.name);
    line = repelem(' ', length(subCarriers));
    for i = 1:ofdmSize
        line(subCarriers == 'v') = '.';
        line(subCarriers == 'd') = '|';
        line(subCarriers == 'p') = char(12);
    end
    % midpoint is ofdmSize/2 which should be displaced to 37 spaces
    spaceCount = 36 - ceil(ofdmSize/2);
    for i = 1:spaceCount
        fprintf(' ');
    end
    fprintf('%s\n\n', line);
    fprintf('\t\t\t\t\tCyclic Prefix\t|\t%.0f%%\n', variant.cycPrefix);
    fprintf('\t\t\t\t\tGuard Interval\t|\t%.0f%%\n', variant.guardInt);
end
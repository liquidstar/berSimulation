% # Test cases for the DataSource class
% # BER OFDM Variant project 2020
function tests = dataSourceTests
    tests = functiontests(localfunctions);
end

%% Check count of serial input bits
function testBitCount(testCase)
    testBits = 2000;
    srcData = ofdm.DataSource(testBits);
    verifyNumElements(testCase, srcData.serialBits, srcData.bitCount)
end

%% Check that contains only integers
function testIntegers(testCase)
    srcData = ofdm.DataSource(2000);
    verifyInstanceOf(testCase, srcData.serialBits, 'int8')
end

%% Ensure integers in serial data are binary
function testBinaryDigits(testCase)
    srcData = ofdm.DataSource(2000);
    %binTest = 
    verifyEqual(testCase, ismember([2 3 4 5 6 7 8 9], srcData.serialBits), logical([0 0 0 0 0 0 0 0]))
end
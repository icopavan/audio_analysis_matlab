function [F] = prepareTrainingData( y, drum, windowSize, windowShift, n )
%PREPAREDATA Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 5
        n = 24;
    end
    if nargin < 4
        windowShift = 128;
    end
    if nargin < 3
        windowSize = 2024;  %window size in samples
    end
    
    windowFunction = hamming(windowSize);

    %% detect onsets
    onsets = detectOnsets(y);
    onset = onsets(1);
    
    
    %% fft frames
    
    F = zeros(n,windowSize+1);
    start = onset;
    
    for i=1:n
        F(i,1)=drum;
        F(i,2:windowSize+1) = abs(fft(windowFunction.*y(start:start+windowSize-1)));
        start = start+windowShift;
    end
end


function [A] = prepareTrainingData( y, noise, windowSize, windowShift, n )
%PREPAREDATA Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 5
        n = 32;
    end
    if nargin < 4
        windowShift = 128;
    end
    if nargin < 3
        windowSize = 2048;  %window size in samples
    end
    if nargin < 2
        noise = zeros(windowSize,1);  %window size in samples
    end
    
    windowFunction = hamming(windowSize);

    %% detect onsets
    onsets = detectOnsets(y);
    onset = onsets(1);
    
    
    %% fft single frame
    A = zeros(n,windowSize/2);
    start = onset;
    
    for i=1:n
        %A(i,1)=drum;
        
        Atmp=zeros(windowSize,1);
        Atmp=abs(fft(windowFunction.*y(start:start+windowSize-1)));
        Atmp=Atmp-noise.*1.5;
        Atmp(Atmp<0) = 0;
        Atmp=Atmp./mean(Atmp);
        %Atmp(1:length(Atmp)/32)=Atmp(1:length(Atmp)/32)./mean(Atmp(1:length(Atmp)/32));
        A(i,:)=Atmp(1:length(Atmp)/2);
        start = start+windowShift;
    end
end


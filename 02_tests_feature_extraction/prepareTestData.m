function [w, w1, w2, w3] = prepareTestData( testdata, noise, windowSize )
%PREPwREDwTw Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 3
        windowSize = 2048;  %window size in samples
    end
    if nargin < 2
        noise = zeros(windowSize,1);  %window size in samples
    end
    
    windowFunction = hamming(windowSize);    
    windowSizeFrames = windowSize/2;
    windowFunctionFrames = hamming(windowSizeFrames);  
    
    numData=length(testdata(1,:));
    
    w = zeros(numData,windowSize/2);
    w1 = zeros(numData,windowSizeFrames/2);
    w2 = zeros(numData,windowSizeFrames/2);
    w3 = zeros(numData,windowSizeFrames/2);

    for i=1:numData
        %% define y
        y = testdata(:,i);
        
        %% detect onsets
        onsets = detectOnsets(y);
        onset = onsets(1);  

        wtmp=fft(windowFunction.*y(onset:onset+windowSize-1));
        w1tmp=fft(windowFunctionFrames.*y(onset:onset+windowSizeFrames-1));
        w2tmp=fft(windowFunctionFrames.*y(onset+windowSizeFrames/2:onset+windowSizeFrames+windowSizeFrames/2-1));
        w3tmp=fft(windowFunctionFrames.*y(onset+windowSizeFrames:onset+windowSize-1));            
        
        wtmp=wtmp(1:length(wtmp)/2);
        w1tmp=w1tmp(1:length(w1tmp)/2);
        w2tmp=w2tmp(1:length(w2tmp)/2);
        w3tmp=w3tmp(1:length(w3tmp)/2);

%         wtmp=wtmp-fft(windowFunction.*noise);            
%         noiseFrames=fft(windowFunctionFrames.*noise(1:length(noise)/2));
%         w1tmp=w1tmp-noiseFrames;
%         w2tmp=w2tmp-noiseFrames;
%         w3tmp=w3tmp-noiseFrames;

        wtmp(1:2)=0;
        w1tmp(1:2)=0;
        w2tmp(1:2)=0;
        w3tmp(1:2)=0;

        wtmp=wtmp./max(wtmp);
        %w1tmp=w1tmp./max(wtmp);
        %w2tmp=w2tmp./max(wtmp);
        %w3tmp=w3tmp./max(wtmp);
        
        w(i,:)=wtmp(1:length(wtmp));
        w1(i,:)=w1tmp(1:length(w1tmp));
        w2(i,:)=w2tmp(1:length(w2tmp));
        w3(i,:)=w3tmp(1:length(w3tmp));

    end
    
end


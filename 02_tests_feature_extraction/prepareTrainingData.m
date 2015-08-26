function [w, w1, w2, w3] = prepareTrainingData( trainingdata, noise, windowSize, windowShift, n )
%PREPwREDwTw Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 5
        n = 24;
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
    windowSizeFrames = windowSize/2;
    windowFunctionFrames = hamming(windowSizeFrames);  
    
    numData=length(trainingdata(1,:));
    
    w = zeros(numData*n,windowSize/2);
    w1 = zeros(numData*n,windowSizeFrames/2);
    w2 = zeros(numData*n,windowSizeFrames/2);
    w3 = zeros(numData*n,windowSizeFrames/2);
    
    idx = 0;
    
    for j=1:numData
        %% define y
        y = trainingdata(:,j);
        
        %% detect onsets
        onsets = detectOnsets(y);
        onset = onsets(1);        
       
        start = onset;
        
        for i=1:n  
            wtmp=fft(windowFunction.*y(start:start+windowSize-1));                        
            w1tmp=fft(windowFunctionFrames.*y(start:start+windowSizeFrames-1));
            w2tmp=fft(windowFunctionFrames.*y(start+windowSizeFrames/2:start+windowSizeFrames+windowSizeFrames/2-1));
            w3tmp=fft(windowFunctionFrames.*y(start+windowSizeFrames:start+windowSize-1));

            wtmp=wtmp(1:length(wtmp)/2);
            w1tmp=w1tmp(1:length(w1tmp)/2);
            w2tmp=w2tmp(1:length(w2tmp)/2);
            w3tmp=w3tmp(1:length(w3tmp)/2);
% 
%             wtmp=wtmp-fft(windowFunction.*noise);            
%             noiseFrames=fft(windowFunctionFrames.*noise(1:length(noise)/2));
%             w1tmp=w1tmp-noiseFrames;
%             w2tmp=w2tmp-noiseFrames;
%             w3tmp=w3tmp-noiseFrames;

            wtmp(1:2)=0;
            w1tmp(1:2)=0;
            w2tmp(1:2)=0;
            w3tmp(1:2)=0;
            
            wtmp(length(wtmp)-1:length(wtmp))=0;
            w1tmp(length(w1tmp)-1:length(w1tmp))=0;
            w2tmp(length(w2tmp)-1:length(w2tmp))=0;
            w3tmp(length(w3tmp)-1:length(w3tmp))=0;
            
            maxVal=max(wtmp); 
            
            wtmp=wtmp./maxVal;
%             w1tmp=w1tmp./maxVal;
%             w2tmp=w2tmp./maxVal;
%             w3tmp=w3tmp./maxVal;            

            idx=idx+1;  
            
            w(idx,:)=wtmp(1:length(wtmp));
            w1(idx,:)=w1tmp(1:length(w1tmp));
            w2(idx,:)=w2tmp(1:length(w2tmp));
            w3(idx,:)=w3tmp(1:length(w3tmp));

            start = start+windowShift;
        end
    end
    
end


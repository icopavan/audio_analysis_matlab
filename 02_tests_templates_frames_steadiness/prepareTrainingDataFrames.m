function [A, S] = prepareTrainingDataFrames( y, noise, windowSize, windowShift, n )
%PREPAREDATA Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 5
        n = 24;
    end
    if nargin < 4
        windowShift = 128;
    end
    if nargin < 3
        windowSize = 1024;  %window size in samples
    end
    if nargin < 2
        noise = zeros(windowSize,1);  %window size in samples
    end
    
    windowFunction = hamming(windowSize);

    %% detect onsets
    onsets = detectOnsets(y);
    onset = onsets(1);
        
    %% fft three frames  
    
    A = zeros(n,windowSize/2);
    S = zeros(n,windowSize/2);
    start = onset;

    for i=1:n        
        frames=zeros(windowSize/2,3);
        start2 = start;
        for j=1:3
            %fft
            frame=zeros(windowSize,1);
            frame=fft(windowFunction.*y(start2:start2+windowSize-1)); 
            %save in frames array
            frames(:,j)=frame(1:windowSize/2);
            
            %set start
            start2 = start2+windowSize/2;
        end       

        %calculate mean A
        Atmp = ((abs(frames(:,1)).^2)+(abs(frames(:,2)).^2)+(abs(frames(:,3)).^2))/3;

        %noise reduction
        Atmp=Atmp-noise(1:windowSize/2);  
        Atmp(Atmp<0) = 0;

        %normalization
        Atmp=Atmp./mean(Atmp);

        % save
        A(i,:) = Atmp;

        %calculate S
        S(i,:) = abs (angle (frames(:,2 ) .* frames(:,2) ./ frames(:,1) ./ frames(:,3)));

        %set start       
        start = start+windowShift;
    end

end


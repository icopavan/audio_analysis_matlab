function test()
%TRAIN Summary of this function goes here
%   Detailed explanation goes here

    %% variables
    windowSize = 1024;
    n = 24;
    windowShift = 128;
    windowFunction = hamming(windowSize);

    %% get data
    [drums, trainingdata, testdata] = getData();
    
    
    %% get noise
    [y_noise,fs] = audioread('E:\FH\Masterthesis\recordings\14_11_18\silence.wav');
    
    noiseFrames=zeros(windowSize/2,3);
    start = 1;
    for i=1:3
        start = start+windowSize/2;
        frame=zeros(1,windowSize);
        frame=fft(windowFunction.*y_noise(start:start+windowSize-1));
        noiseFrames(:,i)=frame(1:windowSize/2);
    end
    noise = zeros(windowSize,1);
    noise = ((abs(noiseFrames(:,1)).^2)+(abs(noiseFrames(:,2)).^2)+(abs(noiseFrames(:,3)).^2))/3;



    %% training
    'training'
    sizeData=size(trainingdata);
    A = zeros(sizeData(2)*n,windowSize/2);
    S = zeros(sizeData(2)*n,windowSize/2);


    for i=1:sizeData(2)
      y = trainingdata(2:sizeData(1),i);
      [A(((i-1)*n)+1:i*n,:), S(((i-1)*n)+1:i*n,:)] = prepareTrainingDataFrames(y, noise, windowSize, windowShift, n);      
    end
    
    'create template'
    [AMin, AMax, AMean, APeaks] = createTemplates(A,n);
    [SMin, SMax, SMean, SPeaks] = createTemplates(S,n,0.2,0.8);
    
    
    %% tests
    'tests'
    timestamp = datestr(now,'yymmddHHMMSS');
    mkdir('results');
    
    rACritA = zeros(length(testdata(1,:))+1,length(AMin(:,1))+1);
    rACritA(1,:)=0:length(rACritA(1,:))-1;
    resultsA = zeros(length(drums));
    
    rACritS = zeros(length(testdata(1,:))+1,length(AMin(:,1))+1);
    rACritS(1,:)=0:length(rACritS(1,:))-1;
    resultsS = zeros(length(drums));
    
    rACrit = zeros(length(testdata(1,:))+1,length(AMin(:,1))+1);
    rACrit(1,:)=0:length(rACrit(1,:))-1;
    results = zeros(length(drums));
    
    for i=1:length(testdata(1,:))

        onsets = detectOnsets(testdata(2:length(testdata),i));
        frames=zeros(windowSize/2,3);
        start = onsets(1);

        % use three frames
        for j=1:3
            %fft
            frame=zeros(windowSize,1);
            frame=fft(windowFunction.*testdata(start:start+windowSize-1,i));

            %save in frames array
            frames(:,j)=frame(1:windowSize/2);

            start = start+windowSize/2; 
        end

        %calculate mean A
        Atmp = ((abs(frames(:,1)).^2)+(abs(frames(:,2)).^2)+(abs(frames(:,3)).^2))/3;

        %noise reduction
        Atmp=Atmp-noise(1:windowSize/2);  
        Atmp(Atmp<0) = 0;

        %normalization
        Atmp=Atmp./mean(Atmp);


        %calculate S
        Stmp(i,:) = abs (angle (frames(:,2 ) .* frames(:,2) ./ frames(:,1) ./ frames(:,3)));


        [ ResultsA ] = testQuantileAD(Atmp, AMax, AMin, windowSize, 8000);      
        [ ResultsS ] = testQuantileSD(Atmp, Stmp, SMean, SMin, SMax, windowSize, 4000);

        
        
        %get results
        [minR,idx]=min(ResultsA);
        %rdrum=drums(:,idx)        
        tidx=testdata(1,i);
        %tdrum=drums(:,tidx)
        %fprintf('-');
        rACritA(i+1,1)=tidx;
        rACritA(i+1,2:length(rACritA(1,:)))=ResultsA;
        resultsA(tidx,idx)=resultsA(tidx,idx)+1;

        [minR,idx]=min(ResultsS);
        %rdrum=drums(:,idx)        
        tidx=testdata(1,i);
        %tdrum=drums(:,tidx)
        %fprintf('-----');
        rACritS(i+1,1)=tidx;
        rACritS(i+1,2:length(rACritS(1,:)))=ResultsS;
        resultsS(tidx,idx)=resultsS(tidx,idx)+1;

        Results = ResultsA+ResultsS;
        [minR,idx]=min(Results);
        %rdrum=drums(:,idx)        
        tidx=testdata(1,i);
        %tdrum=drums(:,tidx)
        %fprintf('-----');
        rACrit(i+1,1)=tidx;
        rACrit(i+1,2:length(rACritS(1,:)))=Results;
        results(tidx,idx)=resultsS(tidx,idx)+1;

    end

        size(ResultsS)
        size(ResultsA)
        size(Results)

    dlmwrite(strcat('results\',timestamp,'_result_frames_AD_matrix.csv'),resultsA,'delimiter','\t');
    dlmwrite(strcat('results\',timestamp,'_result_frames_SD_matrix.csv'),resultsS,'delimiter','\t');
    dlmwrite(strcat('results\',timestamp,'_result_frames_AD_SD_matrix.csv'),results,'delimiter','\t');
    
    
end


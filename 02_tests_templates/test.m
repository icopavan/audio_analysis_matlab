function test(test)
%TRAIN Summary of this function goes here
%   Detailed explanation goes here

    %% variables
    windowSize = 2048;
    n = 16;
    windowShift = 128;
    windowFunction = hamming(windowSize);

    %% get data
    [drums, trainingdata, testdata] = getData();
    
    %% get noise
    [y_noise,fs] = audioread('E:\FH\Masterthesis\recordings\14_11_18\silence.wav');
    noise = abs(fft(windowFunction.*((y_noise(1:2048)+y_noise(2049:4096)+y_noise(4097:6144))./3)));

    %% training
    'training'
    sizeData=size(trainingdata);
    A = zeros(sizeData(2)*n,windowSize/2);
    
    for i=1:sizeData(2)
      y = trainingdata(2:sizeData(1),i);
      A(((i-1)*n)+1:i*n,:) = prepareTrainingData(y, noise, windowSize, windowShift, n );      
    end
    
    'create template'
    [AMin, AMax, AMean, Peaks] = createTemplates(A,n);
    
    
    %% tests
    'tests'
    if test==1
        'test quantile'
        timestamp = datestr(now,'yymmddHHMMSS');
        mkdir('results');
        rACrit = zeros(length(testdata(1,:))+1,length(AMin(:,1))+1);
        rACrit(1,:)=0:length(rACrit(1,:))-1;
        results = zeros(length(drums));
        for i=1:length(testdata(1,:))

            onsets = detectOnsets(testdata(2:length(testdata),i));
            frame = testdata(onsets(1):onsets(1)+windowSize-1,i);
            Atmp=abs(fft(hamming(windowSize).*frame));
            Atmp=Atmp-noise.*1.5;
            Atmp(Atmp<0) = 0;
            Atmp=Atmp./mean(Atmp);

            Atmp=Atmp(1:length(Atmp)/2);
            [ Results ] = testQuantileA(Atmp, AMax, AMin, windowSize);        

            [minR,idx]=min(Results);
            rdrum=drums(:,idx)        
            tidx=testdata(1,i);
            tdrum=drums(:,tidx)
            fprintf('-----');
            rACrit(i+1,1)=tidx;
            rACrit(i+1,2:length(rACrit(1,:)))=Results;
            results(tidx,idx)=results(tidx,idx)+1;
        end
        dlmwrite(strcat('results\',timestamp,'_quantiles_acrit_matrix.csv'),rACrit,'delimiter','\t');
        dlmwrite(strcat('results\',timestamp,'_quantile_result_matrix.csv'),results,'delimiter','\t');
    end
    
    
    if test==2
        'test quantile with distance from min/max'
        timestamp = datestr(now,'yymmddHHMMSS');
        mkdir('results');
        rACrit = zeros(length(testdata(1,:))+1,length(AMin(:,1))+1);
        rACrit(1,:)=0:length(rACrit(1,:))-1;
        results = zeros(length(drums));
        for i=1:length(testdata(1,:))

            onsets = detectOnsets(testdata(2:length(testdata),i));
            frame = testdata(onsets(1):onsets(1)+windowSize-1,i);
            Atmp=abs(fft(hamming(windowSize).*frame));
            Atmp=Atmp-noise.*1.5;
            Atmp(Atmp<0) = 0;
            Atmp=Atmp./mean(Atmp);

            Atmp=Atmp(1:length(Atmp)/2);
            [ Results ] = testQuantileAD(Atmp, AMax, AMin, windowSize, 8000);        

            [minR,idx]=min(Results);
            rdrum=drums(:,idx);      
            tidx=testdata(1,i);
            tdrum=drums(:,tidx);
            %fprintf('-----');
            rACrit(i+1,1)=tidx;
            rACrit(i+1,2:length(rACrit(1,:)))=Results;
            results(tidx,idx)=results(tidx,idx)+1;
        end
        dlmwrite(strcat('results\',timestamp,'_quantile_d_acrit_matrix.csv'),rACrit,'delimiter','\t');
        dlmwrite(strcat('results\',timestamp,'_quantile_d_result_matrix.csv'),results,'delimiter','\t');
    end
    
    
    if test==3
        'test quantile with distance from mean'
        timestamp = datestr(now,'yymmddHHMMSS');
        mkdir('results');
        rACrit = zeros(length(testdata(1,:))+1,length(AMin(:,1))+1);
        rACrit(1,:)=0:length(rACrit(1,:))-1;
        results = zeros(length(drums));
        for i=1:length(testdata(1,:))

            onsets = detectOnsets(testdata(2:length(testdata),i));
            frame = testdata(onsets(1):onsets(1)+windowSize-1,i);
            Atmp=abs(fft(hamming(windowSize).*frame));
            Atmp=Atmp-noise.*1.5;
            Atmp(Atmp<0) = 0;
            Atmp=Atmp./mean(Atmp);

            Atmp=Atmp(1:length(Atmp)/2);
            [ Results ] = testQuantileADMean(Atmp, AMean, windowSize);        

            [minR,idx]=min(Results);
            rdrum=drums(:,idx)        
            tidx=testdata(1,i);
            tdrum=drums(:,tidx)
            fprintf('-----');
            rACrit(i+1,1)=tidx;
            rACrit(i+1,2:length(rACrit(1,:)))=Results;
            results(tidx,idx)=results(tidx,idx)+1;
        end
        dlmwrite(strcat('results\',timestamp,'_quantile_d_mean_acrit_matrix.csv'),rACrit,'delimiter','\t');
        dlmwrite(strcat('results\',timestamp,'_quantile_d_mean_result_matrix.csv'),results,'delimiter','\t');
    end
    
    
    if test==4
        'test quantile with distance from min/max at peak positions'
        timestamp = datestr(now,'yymmddHHMMSS');
        mkdir('results');
        rACrit = zeros(length(testdata(1,:))+1,length(AMin(:,1))+1);
        rACrit(1,:)=0:length(rACrit(1,:))-1;
        results = zeros(length(drums));
        
        for i=1:length(testdata(1,:))

            onsets = detectOnsets(testdata(2:length(testdata),i));
            frame = testdata(onsets(1):onsets(1)+windowSize-1,i);
            Atmp=abs(fft(hamming(windowSize).*frame));
            Atmp=Atmp-noise.*1.5;
            Atmp(Atmp<0) = 0;
            Atmp=Atmp./mean(Atmp);

            Atmp=Atmp(1:length(Atmp)/2);
            
            [ Results ] = testQuantileADPeaks(Atmp, AMax, AMin, windowSize);        

            [minR,idx]=min(Results);
            rdrum=drums(:,idx)        
            tidx=testdata(1,i);
            tdrum=drums(:,tidx)
            fprintf('-----');
            rACrit(i+1,1)=tidx;
            rACrit(i+1,2:length(rACrit(1,:)))=Results;
            results(tidx,idx)=results(tidx,idx)+1;
        end
        dlmwrite(strcat('results\',timestamp,'_quantile_d_peaks_acrit_matrix.csv'),rACrit,'delimiter','\t');
        dlmwrite(strcat('results\',timestamp,'_quantile_d_peaks_result_matrix.csv'),results,'delimiter','\t');
    end
    
    if test==5
        'test peak comparison'
        timestamp = datestr(now,'yymmddHHMMSS');
        mkdir('results');
        results = zeros(length(drums));
        
        for i=1:length(testdata(1,:))

            onsets = detectOnsets(testdata(2:length(testdata),i));
            frame = testdata(onsets(1):onsets(1)+windowSize-1,i);
            Atmp=abs(fft(hamming(windowSize).*frame));
            Atmp=Atmp-noise.*1.5;
            Atmp(Atmp<0) = 0;
            Atmp=Atmp./mean(Atmp);

            Atmp=Atmp(1:length(Atmp)/2);  
            [ Results ] = testQuantilePeaks(Atmp, Peaks, windowSize); 
            
            tidx=testdata(1,i);
            tdrum=drums(:,tidx)
            [maxR,idx]=max(Results);
            rdrum=drums(:,idx) 
            results(tidx,idx)=results(tidx,idx)+1;
            fprintf('-----');
        end
          dlmwrite(strcat('results\',timestamp,'_quantile_compare_peaks_only_result_matrix.csv'),results,'delimiter','\t');
    end
    
    
    if test==6
        'test peak comparison'
        timestamp = datestr(now,'yymmddHHMMSS');
        mkdir('results');
        results = zeros(length(drums));
        
        for i=1:length(testdata(1,:))

            onsets = detectOnsets(testdata(2:length(testdata),i));
            frame = testdata(onsets(1):onsets(1)+windowSize-1,i);
            Atmp=abs(fft(hamming(windowSize).*frame));
            Atmp=Atmp-noise.*1.5;
            Atmp(Atmp<0) = 0;
            Atmp=Atmp./mean(Atmp);

            Atmp=Atmp(1:length(Atmp)/2);  
            [ Results ] = testQuantilePeaks2(Atmp, Peaks, AMean, windowSize); 
            
            tidx=testdata(1,i);
            tdrum=drums(:,tidx)
            [minR,idx]=min(Results);
            rdrum=drums(:,idx) 
            results(tidx,idx)=results(tidx,idx)+1;
            fprintf('-----');
        end
          dlmwrite(strcat('results\',timestamp,'_quantile_compare_peaks_result_matrix.csv'),results,'delimiter','\t');
    end
end


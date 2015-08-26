function test(test)
%TRAIN Summary of this function goes here
%   Detailed explanation goes here

    %% variables
    windowSize = 2048;
    n = 24;
    windowFunction = hamming(windowSize);

    %% get data
    [drums, drums1, drums2, trainingdata, trainingdata1, trainingdata2, testdata, testdata1, testdata2, fs] = getData(); 
    
    testdata_combined = superimpose(testdata1, testdata2);
    testdata_combined(1,:) = testdata_combined(1,:)+length(drums); 
    testdata = [testdata, testdata_combined]; 
    
    trainingdata_combined = superimpose(trainingdata1, trainingdata2); 
    trainingdata_combined(1,:) = trainingdata_combined(1,:)+length(drums);    
    trainingdata = [trainingdata, trainingdata_combined];
 
    drums1 = [drums, drums1];
    drums2 = [drums, drums2];
    
    %% get noise
    [y_noise,fs] = audioread('E:\FH\Masterthesis\recordings\14_11_18\silence.wav');
    noise = abs(fft(windowFunction.*((y_noise(1:2048)+y_noise(2049:4096)+y_noise(4097:6144))./3)));

    %% training
    'training'
    sizeData=size(trainingdata);
    A = zeros(sizeData(2)*n,windowSize/2);
    
    for i=1:sizeData(2)
      y = trainingdata(2:sizeData(1),i);
      A(((i-1)*n)+1:i*n,:) = prepareTrainingData(y, noise);      
    end
    
    
    'create template'
    [AMin, AMax, AMean, Peaks] = createTemplates(A,24);
  
%     %% test combined drums
%     'test combined drums'
%     timestamp = datestr(now,'yymmddHHMMSS');
%     mkdir('results');
%     resultMatrix = cell(length(testdata(1,:)), 4);
%     results = zeros(length(drums1),length(drums));
%     for i=1:length(testdata(1,:))
%         onsets = detectOnsets(testdata(2:length(testdata),i));
%         frame = testdata(onsets(1):onsets(1)+windowSize-1,i);
%         Atmp=abs(fft(hamming(windowSize).*frame));
%         Atmp=Atmp-noise.*1.5;
%         Atmp(Atmp<0) = 0;
%         Atmp=Atmp./mean(Atmp);
% 
%         Atmp=Atmp(1:length(Atmp)/2);
%         
%         % find drum
%         [ Results ] = testQuantileAD(Atmp, AMax, AMin, windowSize, 8000); 
%         [minR,idx]=min(Results);    % get result index in training array        
%  
%         
%         % result can be another drum or noise
%         
%         %print results 
%         fprintf('-----');
%         fprintf('tested:');
%         tidx=testdata(1,i);
%         tdrum1=drums1(:,tidx)
%         tdrum2=drums2(:,tidx)
%         fprintf('results:');
%         rdrum1=trainingdrums1(:,idx)
%         rdrum2=trainingdrums2(:,idx)
%         
%         %save results in matrix
%         resultMatrix(i,1)=tdrum1;
%         resultMatrix(i,2)=tdrum2;
%         resultMatrix(i,3)=rdrum1;
%         resultMatrix(i,4)=rdrum2;
%     
%     end
    
    % save results as file
%     timestamp = datestr(now,'yymmddHHMMSS');
%     mkdir('results');
%     fileID = fopen(strcat('results\',timestamp,'_results_test_1.csv'),'w');
%     formatSpec = '%s \t %s \t %s \t %s\n';
%     [nrows,ncols] = size(resultMatrix);
%     for row = 1:nrows
%         fprintf(fileID,formatSpec,resultMatrix{row,:});
%     end
%     fclose(fileID);
    
    
    %% test single drums
    
    'test single drums'
    timestamp = datestr(now,'yymmddHHMMSS');
    mkdir('results');
    rACrit = zeros(length(testdata(1,:))+1,length(AMin(:,1))+1);
    rACrit(1,:)=0:length(rACrit(1,:))-1;
    results = zeros(length(drums1));
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
        rdrum1=drums1(:,idx); 
        rdrum2=drums2(:,idx);    
        tidx=testdata(1,i);
        tdrum=drums1(:,tidx);
        fprintf('-----');
        rACrit(i+1,1)=tidx;
        rACrit(i+1,2:length(rACrit(1,:)))=Results;
        results(tidx,idx)=results(tidx,idx)+1;
    end
    dlmwrite(strcat('results\',timestamp,'_quantile_d_result_matrix.csv'),results,'delimiter','\t');

end


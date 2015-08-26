function test(test)
%TRAIN Summary of this function goes here
%   Detailed explanation goes here

    %% variables
    windowSize = 2048;
    windowShift = 128;
    n = 24;
    windowFunction = hamming(windowSize);

    %% get data
    [trainingdrums, testdrums1, testdrums2, trainingdata, testdata, testdata1, testdata2] = getData(); 
    testdata_combined = prepareTestData(testdata1, testdata2); 
    testdata_combined(1,:) = testdata_combined(1,:)+length(trainingdrums); 
    testdata = [testdata, testdata_combined]; 
    
    testdrums1 = [trainingdrums, testdrums1];
    testdrums2 = [trainingdrums, testdrums2];
     
    %% get noise
    [y_noise,fs] = audioread('E:\FH\Masterthesis\recordings\14_11_18\silence.wav');
    noise = abs(fft(windowFunction.*((y_noise(1:2048)+y_noise(2049:4096)+y_noise(4097:6144))./3)));

    %% train drums
    'training'
    sizeData=size(trainingdata);
    A = zeros(sizeData(2)*n+n,windowSize/2);
    
    for i=1:sizeData(2)
      y = trainingdata(2:sizeData(1),i);
      A(((i-1)*n)+1:i*n,:) = prepareTrainingData(y, noise, windowSize, windowShift, n);      
    end
    
    %% train noise
    A(sizeData(2)*n+1:sizeData(2)*n+n,:) = prepareTrainingData(y_noise, noise, windowSize, windowShift, n, 512 ); 
    trainingdrums = [trainingdrums, 'none'];
    
    
    'create template'
    [AMin, AMax, AMean, Peaks] = createTemplates(A,24);
  
    %% tests
    'test multiple drums'
    timestamp = datestr(now,'yymmddHHMMSS');
    mkdir('results');
    %rACrit = zeros(length(testdata(1,:))+1,length(AMin(:,1))+1);
    %rACrit(1,:)=0:length(rACrit(1,:))-1;
    resultMatrix = cell(length(testdata(1,:)), 4);
    results = zeros(length(testdrums1),length(trainingdrums));
    for i=1:length(testdata(1,:))
        onsets = detectOnsets(testdata(2:length(testdata),i));
        frame = testdata(onsets(1):onsets(1)+windowSize-1,i);
        Atmp=abs(fft(hamming(windowSize).*frame));
        Atmp=Atmp-noise.*1.5;
        Atmp(Atmp<0) = 0;
        Atmp=Atmp./mean(Atmp);

        Atmp=Atmp(1:length(Atmp)/2);
        
        % find first drum
        [ Results ] = testQuantileAD(Atmp, AMax, AMin, windowSize, 8000); 
        [minR,idx]=min(Results);    % get result index in training array        
 
        % v1
        % subtract spectrum mean of the first found drum
        
        Atmp2 = Atmp - AMean(idx,:)'.*1.3;
        Atmp2(Atmp2<0) = 0;         %set negative values to zero
        Atmp2=Atmp2./mean(Atmp2);   %normalize 
        
        % find second drum
        % apply testQuentileAD again to the new spectrum
        [ Results2 ] = testQuantileAD(Atmp2, AMax, AMin, windowSize, 8000);  
        [minR,idx2]=min(Results2);    % get result index in training array 
        
        
        % result can be another drum or noise
        
        %print results 
        %fprintf('-----');
        %fprintf('tested:');
        tidx=testdata(1,i);
        tdrum1=testdrums1(:,tidx);
        tdrum2=testdrums2(:,tidx);
        %fprintf('results:');
        rdrum1=trainingdrums(:,idx);
        rdrum2=trainingdrums(:,idx2);
        
        %save results in matrix
        resultMatrix(i,1)=tdrum1;
        resultMatrix(i,2)=tdrum2;
        resultMatrix(i,3)=rdrum1;
        resultMatrix(i,4)=rdrum2;
    
    end
    
    % save results as file
    fileID = fopen(strcat('results\',timestamp,'_results_test_1.csv'),'w');
    formatSpec = '%s \t %s \t %s \t %s\n';
    [nrows,ncols] = size(resultMatrix);
    for row = 1:nrows
        fprintf(fileID,formatSpec,resultMatrix{row,:});
    end
    fclose(fileID);

end


function writeFeatureVector()
%TRAIN Summary of this function goes here
%   Detailed explanation goes here

    %% variables
    windowSize = 2048;
    n = 24;
    windowFunction = hamming(windowSize);

    %% get data
    [drums, trainingdata, testdata] = getData();
    %% get noise
    [y_noise, fs] = audioread('E:\FH\Masterthesis\recordings\14_11_18\silence.wav');
    noise = (y_noise(1:2048)+y_noise(2049:4096)+y_noise(4097:6144))./3;
    
    
    %% training data
    'training data'
    [w, w1, w2, w3] = prepareTrainingData(trainingdata(2:length(trainingdata),:), noise);

    trainingFeatures = {};
    for i=1:length(w(:,1))
        [ peak1F, peak1A, peak2F, peak2A, peak3F, peak3A, numPeaks, meanPeakF, meanPeakA, meanA, maxFI1, maxAI1, meanFI1, meanAI1, meanAI2, IRate, peakW1F, peakW1A, peakW2F, peakW2A, peakW3F, peakW3A, maxS, meanS ] = getFeatures(w(i,:), w1(i,:), w2(i,:), w3(i,:), fs);
        newFeatures = {char(drums(ceil(i/n))), peak1F, peak1A, peak2F, peak2A, peak3F, peak3A, numPeaks, meanPeakF, meanPeakA, meanA, maxFI1, maxAI1, meanFI1, meanAI1, meanAI2, IRate, peakW1F, peakW1A, peakW2F, peakW2A, peakW3F, peakW3A, maxS, meanS };
        trainingFeatures = [trainingFeatures; newFeatures];
    end

    
    
    %% test data
    'test data'
    [w, w1, w2, w3] = prepareTestData(testdata(2:length(testdata),:), noise);
    testFeatures = {};
    for i=1:length(w(:,1))
        [ peak1F, peak1A, peak2F, peak2A, peak3F, peak3A, numPeaks, meanPeakF, meanPeakA, meanA, maxFI1, maxAI1, meanFI1, meanAI1, meanAI2, IRate, peakW1F, peakW1A, peakW2F, peakW2A, peakW3F, peakW3A, maxS, meanS ] = getFeatures(w(i,:), w1(i,:), w2(i,:), w3(i,:), fs);
        newFeatures = {char(drums(ceil(i/10))), peak1F, peak1A, peak2F, peak2A, peak3F, peak3A, numPeaks, meanPeakF, meanPeakA, meanA, maxFI1, maxAI1, meanFI1, meanAI1, meanAI2, IRate, peakW1F, peakW1A, peakW2F, peakW2A, peakW3F, peakW3A, maxS, meanS };
        testFeatures = [testFeatures; newFeatures];
    end
    
    
    
    %% write files
    'write files'
    timestamp = datestr(now,'yymmddHHMMSS');
    trainingfile = fopen(strcat('files','\training_data',timestamp,'.txt'),'at');
    testfile = fopen(strcat('files','\test_data',timestamp,'.txt'),'at');

    formatSpec = '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n';        

    FeatureNames = {'drums', 'peak 1 (frequency)', 'peak 1 (amplitude)', 'peak 2 (frequency)', 'peak 2 (amplitude)', 'peak 3 (frequency)', 'peak 3 (amplitude)', 'number of peaks', 'mean peak (frequency)', 'mean peak (amplitude)', 'mean amplitude', 'maximum peak interval 1 (frequency)', 'maximum peak interval 1 (amplitude)', 'mean frequency interval 1', 'mean amplitude interval 1', 'mean amplitude interval 2', 'interval rate', 'peak frame 1 (frequency)', 'peak frame 1 (amplitude)', 'peak frame 2 (frequency)', 'peak frame 2 (amplitude)', 'peak frame 3 (frequency)', 'peak frame 3 (amplitude)', 'maximum steadiness', 'mean steadiness'};
    fprintf(trainingfile,formatSpec,FeatureNames{1,:});
    fprintf(testfile,formatSpec,FeatureNames{1,:});

    formatSpec = '%s\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\t%2.4f\n';
    nrows = size(trainingFeatures);
    for row = 1:nrows
        fprintf(trainingfile,formatSpec,trainingFeatures{row,:});
    end
    nrows = size(testFeatures);
    for row = 1:nrows
        fprintf(testfile,formatSpec,testFeatures{row,:});
    end
    fclose(trainingfile);
    fclose(testfile);

end


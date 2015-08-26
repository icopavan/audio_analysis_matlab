function [ R ] = testQuantilePeaks2( A, training_peaks, AMean, window_size )
%TESTQUANTILEPEAKS Summary of this function goes here
%   Detailed explanation goes here
     
    %% set variables    
    num_training_data = length(training_peaks(:,1));  
    window_size =2048;
    window_function = hamming(window_size);
    onsetDelay = 512;
    frequency_domain_from = 1;
    frequency_domain_to = window_size/8;
    peak_threshold = 5;
    
    %% testing
    results = zeros(1,length(training_peaks(1,:)));
   
        
    % get frequency peaks
    [pks,locs_peaks] = findpeaks(A, 'MinPeakHeight', max(A(:,1))/peak_threshold);

    P = zeros(1,length(A));
    for i=1:length(locs_peaks)
       P(locs_peaks(i))=1;
    end
    % add values to classification matrix
    result_matrix = zeros(length(training_peaks(:,1)), length(training_peaks(1,:)));
    for i=1:length(training_peaks(:,1))
        for j=1:frequency_domain_to           
           if P(j)==1
              distance = abs(AMean(i,j)-A(j));
              result_matrix(i,j)=(24-training_peaks(i,j))*distance;
               
              %result_matrix(i,j)=training_peaks(i,j);
           end
        end
    end 
    
    R = zeros(length(training_peaks(:,1)),1);
    for i=1:length(training_peaks(:,1))
        R(i)=sum(result_matrix(i,:));
    end
    
end


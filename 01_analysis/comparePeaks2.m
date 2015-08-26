function [  ] = comparePeaks( )
    %% get data
    folder = 'E:\FH\Masterthesis\recordings\14_08_18\wav';
    [ drums, training_data, test_data, fs ] = GetData( folder );
    %% set variables    
    num_training_data = length(training_data(1,:));    
    num_test_data = length(test_data(1,:));
    window_size =2048;
    window_function = hamming(window_size);
    onsetDelay = 512;
    peak_threshold = 5;
    frequency_domain_from = 1;
    frequency_domain_to = window_size/4;
    %% training
    training_peaks = zeros(9,window_size);
    for i = 1:num_training_data
        % get frequency spectrum
        y = training_data(:,i);     
        onsets = DetectOnsets(y);
        start = onsets(1) + onsetDelay;
        F = abs(fft(window_function.*y(start:start+window_size-1)));
        F = F(frequency_domain_from:frequency_domain_to);
        % get frequency peaks
        [pks,locs_peaks] = findpeaks(F, 'MinPeakHeight', max(F(:,1))/peak_threshold);
        loc_drum = ((i+9)-mod((i-1),10))/10;
        for j=1:length(locs_peaks)
            training_peaks(loc_drum,locs_peaks(j)) = training_peaks(loc_drum,locs_peaks(j))+1;
        end
    end
    %% testing
    classification_matrix = zeros(num_training_data,length(training_peaks(1,:)));
    for i = 1:num_training_data
        % get frequency spectrum
        y = training_data(:,i);     
        onsets = DetectOnsets(y);
        start = onsets(1) + onsetDelay;
        F = abs(fft(window_function.*y(start:start+window_size-1)));
        F = F(frequency_domain_from:frequency_domain_to);        
        % get frequency peaks
        [pks,locs_peaks] = findpeaks(F, 'MinPeakHeight', max(F(:,1))/peak_threshold);
        
        % add values to classification matrix
        for j=1:length(locs_peaks)
           [a_max, idx_max] = max(training_peaks(:,locs_peaks(j)));
           classification_matrix(i,locs_peaks(j)) = idx_max;
        end
    end
    for i = 1:num_training_data
        values = classification_matrix(i,:);
        values(values==0) = [];
        drums(i)
        tabulate(values)
    end
end






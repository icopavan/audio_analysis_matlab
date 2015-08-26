folder = 'E:\FH\Masterthesis\recordings\14_08_18\wav';

[training_files, test_files ] = GetData( folder );

% variables
window_size = 1024;
onset_delay = 512;
accuracy = 1;
peak_threshold = 5;
window_function = hamming(window_size);

%% find peak intersection
intersections = zeros(length(training_files(:,1))/2,window_size);
for i = 1:length(training_files(:,1))
    peaks_tmp = zeros(1,window_size);
    for j = 2:length(training_files)
        [y_tmp, fs_tmp] = audioread(char(training_files(i,j)));
        onsets_tmp = DetectOnsets(y_tmp);   
        start_tmp = onsets_tmp(1)+onset_delay;
        F_tmp = abs(fft(window_function.*y_tmp(start_tmp:start_tmp+window_size-1)));

        %frequency peaks
        [pks_tmp,locs_tmp] = findpeaks(F_tmp, 'MinPeakHeight', max(F_tmp(:,1))/peak_threshold);

        locs_tmp_shortened = locs_tmp(1:length(locs_tmp)/2);
        locs_tmp_rounded = round(locs_tmp_shortened./accuracy).*accuracy;

        if j>2
            peaks_tmp = intersect(peaks_tmp,locs_tmp_rounded);
        else
            peaks_tmp = locs_tmp_rounded;
        end     
    end
    
    intersections(i,1:length(peaks_tmp))=peaks_tmp;
end


%% compare testdata

for i = 1:length(test_files(:,1))
    values_2 = zeros(length(intersections(:,1)),length(test_files(:,1)));
    for j = 2:length(test_files)
        
        [y_tmp, fs_tmp] = audioread(char(test_files(i,j)));
        onsets_tmp = DetectOnsets(y_tmp);   
        start_tmp = onsets_tmp(1)+onset_delay;
        F_tmp = abs(fft(window_function.*y_tmp(start_tmp:start_tmp+window_size-1)));

        %frequency peaks
        [pks_tmp,locs_tmp] = findpeaks(F_tmp, 'MinPeakHeight', max(F_tmp(:,1))/peak_threshold);

        locs_tmp_shortened = locs_tmp(1:round(length(locs_tmp)/2));
        locs_tmp_rounded = round(locs_tmp_shortened./accuracy).*accuracy;
        
        fprintf('-------------------------------------------')        
        char(test_files(i,1))
        for k = 1:length(test_files(:,1))
            result = 0;
            for l = 2:length(test_files)
                [y_tmp_2, fs_tmp_2] = audioread(char(test_files(k,l)));
                onsets_tmp_2 = DetectOnsets(y_tmp_2);   
                start_tmp_2 = onsets_tmp_2(1)+onset_delay;
                F_tmp_2 = abs(fft(window_function.*y_tmp(start_tmp_2:start_tmp_2+window_size-1)));

                %frequency peaks
                [pks_tmp_2,locs_tmp_2] = findpeaks(F_tmp_2, 'MinPeakHeight', max(F_tmp_2(:,1))/peak_threshold);

                locs_tmp_shortened_2 = locs_tmp_2(1:round(length(locs_tmp_2)/2));
                locs_tmp_rounded_2 = round(locs_tmp_shortened_2./accuracy).*accuracy;
                
                
                result = result + length(intersect(locs_tmp_rounded_2,locs_tmp_rounded));
            end
            strcat(char(test_files(k,1)),{': '},num2str(result))
        end  
        fprintf('---')
        values_1 = zeros(length(intersections(:,1)),1);
        for k = 1:length(intersections(:,1))
            values_1(k) = length(intersect(intersections(k,:),locs_tmp_rounded));
            strcat(char(test_files(k,1)),{': '},num2str(values_1(k)));
        end  
        
        values_2(:,j) = values_1;
    end
    
    %values_2
end





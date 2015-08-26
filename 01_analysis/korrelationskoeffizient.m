folder = 'E:\FH\Masterthesis\recordings\14_08_18\wav';

bass1 = strcat(folder,'\play_bass_snare_off_134129.wav');
bass2 = strcat(folder,'\play_bass_snare_off_134142.wav');

crash1 = strcat(folder,'\play_crash_snare_on_140957.wav');
crash2 = strcat(folder,'\play_crash_snare_on_141022.wav');

hihat_open1 = strcat(folder,'\play_hihat_open_snare_on_135728.wav');
hihat_open2 = strcat(folder,'\play_hihat_open_snare_on_135743.wav');

ride1 = strcat(folder,'\play_ride_snare_on_141352.wav');
ride2 = strcat(folder,'\play_ride_snare_on_141406.wav');


crash_training_files = {
    strcat(folder,'\play_crash_snare_on_141143.wav'), ...
    strcat(folder,'\play_crash_snare_on_141153.wav'), ...
    strcat(folder,'\play_crash_snare_on_141202.wav'), ...
    strcat(folder,'\play_crash_snare_on_141212.wav'), ...
    strcat(folder,'\play_crash_snare_on_141222.wav'), ...
    strcat(folder,'\play_crash_snare_on_141231.wav'), ...
    strcat(folder,'\play_crash_snare_on_141240.wav'), ...
    strcat(folder,'\play_crash_snare_on_141249.wav'), ...
    strcat(folder,'\play_crash_snare_on_141259.wav'), ...
    strcat(folder,'\play_crash_snare_on_141309.wav')
 };

ride_training_files = {
    strcat(folder,'\play_ride_snare_on_141819.wav'), ...
    strcat(folder,'\play_ride_snare_on_141809.wav'), ...
    strcat(folder,'\play_ride_snare_on_141712.wav'), ...
    strcat(folder,'\play_ride_snare_on_141701.wav'), ...
    strcat(folder,'\play_ride_snare_on_141650.wav'), ...
    strcat(folder,'\play_ride_snare_on_141639.wav'), ...
    strcat(folder,'\play_ride_snare_on_141628.wav'), ...
    strcat(folder,'\play_ride_snare_on_141617.wav'), ...
    strcat(folder,'\play_ride_snare_on_141605.wav'), ...
    strcat(folder,'\play_ride_snare_on_141555.wav')
 };

bass_training_files = {
    strcat(folder,'\play_bass_snare_off_134149.wav'), ...
    strcat(folder,'\play_bass_snare_off_134155.wav'), ...
    strcat(folder,'\play_bass_snare_off_134202.wav'), ...
    strcat(folder,'\play_bass_snare_off_134209.wav'), ...
    strcat(folder,'\play_bass_snare_off_134216.wav'), ...
    strcat(folder,'\play_bass_snare_off_134222.wav'), ...
    strcat(folder,'\play_bass_snare_off_134229.wav'), ...
    strcat(folder,'\play_bass_snare_off_134235.wav'), ...
    strcat(folder,'\play_bass_snare_off_134243.wav'), ...
    strcat(folder,'\play_bass_snare_off_134257.wav')
 };


% variables
window_size = 256;
window_function = hamming(window_size);

%% create training data

% create spectral shape matrix
crash_training_data = zeros(length(crash_training_files),window_size);
crash_steadiness_training_data = zeros(length(crash_training_files),window_size);

for i = 1:length(crash_training_files)
    [y_tmp, fs_tmp] = audioread(char(crash_training_files(i)));
    onsets_tmp = DetectOnsets(y_tmp);   
    start_tmp = onsets_tmp(1)+512;
    A_tmp = fft(window_function.*y_tmp(start_tmp:start_tmp+window_size-1));
    crash_training_data(i,:) = abs(A_tmp);
    
    % steadiness
    start_tmp = start_tmp + window_size;
    B_tmp = fft(window_function.*y_tmp(start_tmp:start_tmp+window_size-1));
    start_tmp = start_tmp + window_size;
    C_tmp = fft(window_function.*y_tmp(start_tmp:start_tmp+window_size-1));
    S_tmp = angle(A_tmp.*A_tmp./B_tmp./C_tmp);
    crash_steadiness_training_data(i,:) = abs(S_tmp);
end

ride_training_data = zeros(length(ride_training_files),window_size);
ride_steadiness_training_data = zeros(length(ride_training_files),window_size);
for i = 1:length(ride_training_files)
    [y_tmp, fs_tmp] = audioread(char(ride_training_files(i)));
    onsets_tmp = DetectOnsets(y_tmp);   
    start_tmp = onsets_tmp(1)+512;
    A_tmp = fft(window_function.*y_tmp(start_tmp:start_tmp+window_size-1));
    ride_training_data(i,:) = abs(A_tmp);
    
    % steadiness
    start_tmp = start_tmp + window_size;
    B_tmp = fft(window_function.*y_tmp(start_tmp:start_tmp+window_size-1));
    start_tmp = start_tmp + window_size;
    C_tmp = fft(window_function.*y_tmp(start_tmp:start_tmp+window_size-1));
    S_tmp = angle(A_tmp.*A_tmp./B_tmp./C_tmp);
    ride_steadiness_training_data(i,:) = abs(S_tmp);
end

bass_training_data = zeros(length(bass_training_files),window_size);
bass_steadiness_training_data = zeros(length(bass_training_files),window_size);
for i = 1:length(ride_training_files)
    [y_tmp, fs_tmp] = audioread(char(bass_training_files(i)));
    onsets_tmp = DetectOnsets(y_tmp);   
    start_tmp = onsets_tmp(1)+512;
    A_tmp = fft(window_function.*y_tmp(start_tmp:start_tmp+window_size-1));
    bass_training_data(i,:) = abs(A_tmp);
    
    % steadiness
    start_tmp = start_tmp + window_size;
    B_tmp = fft(window_function.*y_tmp(start_tmp:start_tmp+window_size-1));
    start_tmp = start_tmp + window_size;
    C_tmp = fft(window_function.*y_tmp(start_tmp:start_tmp+window_size-1));
    S_tmp = angle(A_tmp.*A_tmp./B_tmp./C_tmp);
    bass_steadiness_training_data(i,:) = abs(S_tmp);
end

% get spectral shape mean array
crash_reference_shape = zeros(window_size, 1);
crash_steadiness_reference_shape = zeros(window_size, 1);
for i = 1:window_size
    crash_reference_shape(i, 1) = sum(crash_training_data(:,i));
    crash_steadiness_reference_shape(i, 1) = sum(crash_steadiness_training_data(:,i));
end

ride_reference_shape = zeros(window_size, 1);
ride_steadiness_reference_shape = zeros(window_size, 1);
for i = 1:window_size
    ride_reference_shape(i, 1) = sum(ride_training_data(:,i));
    ride_steadiness_reference_shape(i, 1) = sum(ride_steadiness_training_data(:,i));
end

bass_reference_shape = zeros(window_size, 1);
bass_steadiness_reference_shape = zeros(window_size, 1);
for i = 1:window_size
    bass_reference_shape(i, 1) = sum(bass_training_data(:,i));
    bass_steadiness_reference_shape(i, 1) = sum(bass_steadiness_training_data(:,i));
end

%% compare spectral shape

[y, fs] = audioread(ride1); %aufiofile to compare with training data
onsets = DetectOnsets(y);

%frequency spectrum F(k)
start = onsets(1)+512;
A = fft(window_function.*y(start:start+window_size-1));

%correlation coefficient
abs_A = abs(A);
k_crash = sum (abs_A .* crash_reference_shape) / sqrt (sum (abs_A.^2) * sum (crash_reference_shape.^2))
k_ride = sum (abs_A .* ride_reference_shape) / sqrt (sum (abs_A.^2) * sum (ride_reference_shape.^2))
k_bass = sum (abs_A .* bass_reference_shape) / sqrt (sum (abs_A.^2) * sum (bass_reference_shape.^2))


%% compare spectral shape with each test data set

for i = 1:10
    ride_reference_shape = ride_training_data(i,:)';
    k_each_ride = sum (abs_A .* ride_reference_shape) / sqrt (sum (abs_A.^2) * sum (ride_reference_shape.^2))
end


%% compare steadiness shape

start
start = start + window_size
B = fft(window_function.*y(start:start+window_size-1));

start = start + window_size
C = fft(window_function.*y(start:start+window_size-1));

%phase angles
%P_A = angle(A)
%P_B = angle(B)
%P_C = angle(C)

S = angle(B.*B./A./C);

abs_S = abs(S);

%mean steadiness
sum(abs_S)/length(abs_S)
sum(crash_steadiness_reference_shape)/length(abs_S)/10
sum(ride_steadiness_reference_shape)/length(abs_S)/10
sum(bass_steadiness_reference_shape)/length(abs_S)/10

%correlation coefficient 
k_steadiness_crash = sum (abs_S .* crash_steadiness_reference_shape) / sqrt (sum (abs_S.^2) * sum (crash_steadiness_reference_shape.^2))
k_steadiness_ride = sum (abs_S .* ride_steadiness_reference_shape) / sqrt (sum (abs_S.^2) * sum (ride_steadiness_reference_shape.^2))
k_steadiness_bass = sum (abs_S .* bass_steadiness_reference_shape) / sqrt (sum (abs_S.^2) * sum (bass_steadiness_reference_shape.^2))


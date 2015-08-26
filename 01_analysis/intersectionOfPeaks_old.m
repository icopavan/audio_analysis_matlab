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
window_size = 1024;
onset_delay = 512;
accuracy = 2;
peak_threshold = 10;

window_function = hamming(window_size);

%% find peak intersection
%crash
crash_peaks = zeros(1,window_size);
for i = 1:length(crash_training_files)
    [y_tmp, fs_tmp] = audioread(char(crash_training_files(i)));
    onsets_tmp = DetectOnsets(y_tmp);   
    start_tmp = onsets_tmp(1)+onset_delay;
    F_tmp = abs(fft(window_function.*y_tmp(start_tmp:start_tmp+window_size-1)));
    
    %frequency peaks
    [pks_tmp,locs_tmp] = findpeaks(F_tmp, 'MinPeakHeight', max(F_tmp(:,1))/peak_threshold);
    
    locs_tmp_shortened = locs_tmp(1:length(locs_tmp)/2);
    locs_tmp_rounded = round(locs_tmp_shortened./accuracy).*accuracy;
    
    if i>1
        crash_peaks = intersect(crash_peaks,locs_tmp_rounded);
    else
        crash_peaks = locs_tmp_rounded;
    end     
end
%ride
ride_peaks = zeros(1,window_size);
for i = 1:length(crash_training_files)
    [y_tmp, fs_tmp] = audioread(char(ride_training_files(i)));
    onsets_tmp = DetectOnsets(y_tmp);   
    start_tmp = onsets_tmp(1)+onset_delay;
    F_tmp = abs(fft(window_function.*y_tmp(start_tmp:start_tmp+window_size-1)));
    
    %frequency peaks
    [pks_tmp,locs_tmp] = findpeaks(F_tmp, 'MinPeakHeight', max(F_tmp(:,1))/peak_threshold);
    
    locs_tmp_shortened = locs_tmp(1:length(locs_tmp)/2);
    locs_tmp_rounded = round(locs_tmp_shortened./accuracy).*accuracy;
    
    if i>1
        ride_peaks = intersect(ride_peaks,locs_tmp_rounded);
    else
        ride_peaks = locs_tmp_rounded;
    end     
end
%bass
bass_peaks = zeros(1,window_size);
for i = 1:length(crash_training_files)
    [y_tmp, fs_tmp] = audioread(char(bass_training_files(i)));
    onsets_tmp = DetectOnsets(y_tmp);   
    start_tmp = onsets_tmp(1)+onset_delay;
    F_tmp = abs(fft(window_function.*y_tmp(start_tmp:start_tmp+window_size-1)));
    
    %frequency peaks
    [pks_tmp,locs_tmp] = findpeaks(F_tmp, 'MinPeakHeight', max(F_tmp(:,1))/peak_threshold);
    
    locs_tmp_shortened = locs_tmp(1:length(locs_tmp)/2);
    locs_tmp_rounded = round(locs_tmp_shortened./accuracy).*accuracy;
    
    if i>1
        bass_peaks = intersect(bass_peaks,locs_tmp_rounded);
    else
        bass_peaks = locs_tmp_rounded;
    end     
end

crash_peaks
ride_peaks
bass_peaks

%% compare testdata
[y, fs] = audioread(crash1); %aufiofile to compare with training data
onsets = DetectOnsets(y);
start = onsets(1)+onset_delay;
F = abs(fft(window_function.*y(start:start+window_size-1)));

%frequency peaks
[pks,locs] = findpeaks(F, 'MinPeakHeight', max(F(:,1))/peak_threshold);
locs_shortened = locs(1:length(locs)/2);
locs_rounded = round(locs_shortened./accuracy).*accuracy;


n_ride = length(intersect(ride_peaks,locs_rounded));
n_crash = length(intersect(crash_peaks,locs_rounded));
n_bass = length(intersect(bass_peaks,locs_rounded));

n_ges = n_ride+n_crash+n_bass;

percent_ride = 100/n_ges*n_ride;
percent_crash = 100/n_ges*n_crash;
percent_bass = 100/n_ges*n_bass;

strcat({'Ride: '},num2str(percent_ride),'%')
strcat({'Crash: '},num2str(percent_crash),'%')
strcat({'Bass: '},num2str(percent_bass),'%')





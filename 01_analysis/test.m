%file = 'E:\FH\Masterthesis\recordings\14_04_25\play_snare_off\184216_hamming_512_0.5.wav';
%file = 'E:\FH\Masterthesis\recordings\14_04_25\play_snare_off\182323_hamming_512_0.5.wav';
%file = 'E:\FH\Masterthesis\recordings\14_04_25\play_snare_off\185004_hamming_512_0.5.wav';
%file = 'E:\FH\Masterthesis\recordings\14_04_25\play_snare_off\185046_hamming_512_0.5.wav';
file = 'E:\FH\Masterthesis\recordings\14_04_13\play_tom3\hamming_172930.wav';
%file = 'E:\FH\Masterthesis\recordings\14_04_21\play_tom1_snare_off\210512_hamming_512_0.5.wav';
%file = 'E:\FH\Masterthesis\recordings\14_04_22\play_hihat_crash_snare_off\171658_hamming_512_0.5.wav';
%file = 'E:\FH\Masterthesis\recordings\14_04_21\play_hihat_snare_off\210419_hamming_512_0.5.wav';
%file = 'E:\FH\Masterthesis\recordings\14_04_21\play_snare_snare_on\210012_hamming_512_0.5.wav';
%file = 'E:\FH\Masterthesis\recordings\14_04_21\play_bass_snare_off\205608_hamming_512_0.5.wav';
%file = 'E:\FH\Masterthesis\recordings\14_04_21\play_bass_snare_off\205754_hamming_512_0.5.wav';
%file = 'E:\FH\Masterthesis\recordings\14_04_21\play_crash_snare_off\211523_hamming_512_0.5.wav';
%file = 'E:\FH\Masterthesis\recordings\14_04_21\play_ride_snare_off\211321_hamming_512_0.5.wav';

% get file data
[y, fs] = audioread(file);

% detect onsets
% function DetectOnsets(y, window_size, lock_size, reference_denominator)
% default values: no default, 128, 10, 2.5
onsets = DetectOnsets(y);
%onsets = DetectOnsets(y, 128, 3, 2.5);
%onsets = DetectOnsets(y, 64, 8, 1.6);

%get features
window_size = 512;
[F, peak_1, peak_2, peak_3, frames, A, RMS_ges, RMS_i1, RMS_i2, RMS_rate_i1, RMS_rate_i2, peak_c1, peak_c2, peak_c3, S] = GetFeatures(y, fs, onsets(1), window_size);

%plot
plot_count = 0;
[h,plot_count] = DrawOnsets( plot_count, y, fs, onsets );
[h,plot_count] = DrawOnset( plot_count, y, fs, onsets(1), window_size );
[h,plot_count] = DrawFrames( plot_count, fs, F, peak_1, peak_2, peak_3, RMS_ges, RMS_i1, RMS_i2, frames, peak_c1, peak_c2, peak_c3, 512 );


%save data in file
%calculate standard deviation

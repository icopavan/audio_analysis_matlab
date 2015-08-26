file = 'c:\Documents and Settings\katrin\Desktop\matlab\soundfiles\hits_low-tom_sticks_5x.wav'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% analyse file
[y, fs, nb] = wavread(file);
wave = mean(y,2); %avrg of 2 channels
t=0:1/fs:(length(wave)-1)/fs;

% smooth data
[b,a] = butter(1,1000/(fs/0.03),'low');
smoothData = filtfilt(b,a,abs(hilbert(wave)));

%find peaks
%[pks,locs] = findpeaks(smoothData, 'MinPeakHeight', 0.01);
[pks,locs] = findpeaks(wave, 'MinPeakHeight', 0.01);

%plot
h=figure(1);
plot(t,wave);
hold on
plot(t,smoothData,'g','lineWidth', 1.5);
plot(t(locs),pks+0.001,'rv','MarkerFaceColor','r');
hold off

title('Beatdetection');
ylabel('Amplitude');
xlabel('Length (in seconds)');


file = 'E:\FH\Masterthesis\recordings\14_04_13\play_tom3\hamming_172930.wav'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% analyse file
[y, fs] = audioread(file);
wave = mean(y,2);
t=0:1/fs:(length(wave)-1)/fs;
YY = abs(fft(wave));
f=0:length(wave)-1;                    %frequency scale - scale from 0 to length(y)-1
f=f*fs/length(wave);
%YY = abs(Y)/max(abs(Y));
%smoothData = sgolayfilt(YY,2,35);

% smooth data
%[b,a] = butter(1,1000/(fs/0.03),'low');
%smoothData = filtfilt(b,a,abs(hilbert(wave)));

%find peaks
%[pks,locs] = findpeaks(smoothData, 'MinPeakHeight', 0.01);
%[pks,locs] = findpeaks(YY,'MinPeakDistance',20);

%smoothData = abs(hilbert(YY));
%[pks,locs] = findpeaks(smoothData, 'MinPeakHeight', 0.1);


[pks,locs] = findpeaks(YY, 'MinPeakHeight', max(YY(:,1))/10);
%write peaks to file
M = sortrows([f(locs)',pks]);
M(M(:,1)>4000,:)=[];

%plot
h=figure(1);
subplot(3,1,1), plot(t,y);

subplot(3,1,2);
grid on
hold on
   plot(f,YY);
   %plot(f,smoothData,'r');
   %plot(f(locs),pks, 'g');
   plot(f(locs),pks+0.001,'rv','MarkerFaceColor','r');
hold off
%axis([0 fs/2 0 100]);
xlim([0,4000]);

subplot(3,1,3)
grid on
hold on
    plot(f,YY);
   % plot(f,smoothData,'r');
   %plot(f(locs),pks, 'g');
    plot(f(locs),pks+0.05,'rv','MarkerFaceColor','r');
hold off
%axis([0 fs/2 0 100]);
xlim([0,500]);

title('Beatdetection');
ylabel('Amplitude');
xlabel('Length (in seconds)');


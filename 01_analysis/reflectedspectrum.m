function [ output_args ] = reflectedspectrum( input_args )
%REFLECTEDSPECTRUM Summary of this function goes here
%   Detailed explanation goes here

%% variables
windowSize = 8096;
windowFunction = hamming(windowSize);

%% get audio data
file = 'E:\FH\Masterthesis\recordings\14_11_18\trainingset\crash_141118_140108.wav';    
[y,fs] = audioread(char(file)); 

%% get stroke and spectrum
onsets = DetectOnsets(y);
F = fft(windowFunction.*y(onsets(1):onsets(1)+windowSize-1));
F2 = F;
F(windowSize/2:windowSize)=F(windowSize/4:windowSize/4*3);

%% time and frequency scale  
t = 0:length(F)-1;                    % time scale
t = t/fs;
f = 0:length(F)-1;           % frequency scale - scale from 0 to length(y)-1
f = f*fs/length(F);


%% figures
h1=figure(1);
set(0,'Units','pixels'); 
set(h1, 'Position', [100 100 600 250]);

% plot 1
subplot(2,1,1), plot(f,abs(F));
axis([0 fs 0 1]);
xlabel('f [Hz] \rightarrow'), ylabel('|A(f) \rightarrow|');

% plot 2
subplot(2,1,2), plot(f,abs(F2));
axis([0 fs 0 1]);
xlabel('f [Hz] \rightarrow'), ylabel('|A(f) \rightarrow|');

%% save figure
set(gcf,'PaperPositionMode','auto');
saveas(h1,'reflectedspectrum.pdf');


end




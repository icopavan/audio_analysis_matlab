% define variables
Fs = 8000;
nfft = 2^nextpow2(Fs);
recObj = audiorecorder(Fs,8,1);
iT = 1;
rT = 5;

fprintf('start recording with iT = %d and rT = %d \n', iT, rT);

% record rTtest.wav and save wav file
recordblocking(recObj, rT);
sig = getaudiodata(recObj);
audiowrite('test.wav', sig, 8000);

fprintf('\n recording finished \n');

% read audio signal
filename = 'test.wav';

[y,fs,bits] = wavread(filename);

% spectral analysis
Y = fft(y)

% graphics    

t = 0:length(y)-1;                   % time scale
t = t/fs;

fprintf('fig1 ...');
FIG1 = figure(1);
subplot(2,1,1), plot(t,y), grid;
xlabel('t [s] \rightarrow'), ylabel('y(t)  \rightarrow');

f=0:length(y)-1;                    %frequency scale
f=f*fs/length(y);
fprintf('\n recording finished \n');
YY = abs(Y)/max(abs(Y));
subplot(2,1,2), plot(f,YY), grid
axis([0 fs/2 0 1]);
xlabel('f [Hz] \rightarrow'), ylabel('norm. |Y(f) \rightarrow|');    

soundsc(y,fs,bits);                 % sound

% short term spectral analysis  
fprintf('short term spectral analysis ...');
M = 512;                            % fft length    
w = hamming(M);                     % Hamming window    
OL = 4;                             % overlap of the fft blocks

N = floor(length(y)/M);
Y = zeros(OL*N,M/2);

for k=1:OL*(N-1)
   start = 1+(M/OL)*(k-1);
   stop = start+M-1;
   YY = fft(w.*y(start:stop))';
   Y(k,:) = abs(YY(1:M/2));
end

% graphics
fprintf('fig2 ...');
FIG2 = figure(2);
Y = abs(Y(:,1:M/4));
Ymax = max(max(Y));
Y = Y/Ymax;
t = 1:OL*N;
t=t*(M/OL)/fs;
f=0:1:M/4-1;
f=(fs/2)*f/M;
h=waterfall(f,t,Y);
view(30,30)
xlabel(' f [Hz] \rightarrow'), ylabel(' t [s] \rightarrow')
zlabel('magnitudes of short term dft spectra \rightarrow')

% MATLAB built-in spectrogram
fprintf('fig 3');
FIG3 = figure(3);
specgram(y,M,fs,hamming(M),M/OL);

fprintf('done!!!');
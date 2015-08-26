Fs = 8000;                    % sampling frequency in Hz
T = 0.25;                     % length of one interval signal in sec
t = 0:1/Fs:T-1/Fs;            % time vector
nfft = 2^nextpow2(Fs);        % n-point DFT
numUniq = ceil((nfft+1)/2);   % half point
f = (0:numUniq-1)'*Fs/nfft;   %' frequency vector (one sided)

% prepare audio recording
recObj = audiorecorder(Fs,8,1);

% Record for 10 intervals of 1sec each
fprintf('Make some sound! ...')
for i=1:100
    recordblocking(recObj, T);

    % get data and compute FFT
    sig = getaudiodata(recObj);
    wavefft = abs(fft(sig,nfft));    
    
    % test if a drum was played
    [val idx] = max(wavefft);
    
    if val>10 && idx<170 && idx>155
        fprintf('HIT LOWTOM:\n');
        fprintf('frequency: %d\n', idx);
        fprintf('amplitude: %f\n', val);
        fprintf('\n');
    elseif val>10 && idx<270 && idx>210
        fprintf('HIT HIHAT:\n');
        fprintf('frequency: %d\n', idx);
        fprintf('%f\n', val);
        fprintf('\n');
    elseif val>10
        fprintf('HIT SOMETHING ELSE:\n');
        fprintf('frequency: %d\n', idx);
        fprintf('amplitude: %f\n', val);
        fprintf('\n');
    end
end
fprintf('Done.')
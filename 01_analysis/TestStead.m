% Rade, 16.9.2014

function TestStead()

%% Drei Testsounds, y zum Trainieren, y2 und y3 zum Testen
folder = 'E:\FH\Masterthesis\recordings\14_08_18\wav';
[ride1,fs] = audioread(strcat(folder,'/play_ride_snare_on_141352.wav'));
[ride2,fs] = audioread(strcat(folder,'/play_ride_snare_on_141514.wav'));
%[y2,fs] = audioread(strcat(folder,'/play_ride_snare_on_141639.wav'));
[crash1,fs] = audioread(strcat(folder,'/play_crash_snare_on_141059.wav'));
[crash2,fs] = audioread(strcat(folder,'/play_crash_snare_on_141212.wav'));
%[y3,fs] = audioread(strcat(folder,'/play_tom1_snare_on_140341.wav'));
[hihat_open1,fs] = audioread(strcat(folder,'/play_hihat_open_snare_on_135728.wav'));
[hihat_open2,fs] = audioread(strcat(folder,'/play_hihat_open_snare_on_135743.wav'));
[hihat_closed1,fs] = audioread(strcat(folder,'/play_hihat_snare_on_135531.wav'));
[hihat_closed2,fs] = audioread(strcat(folder,'/play_hihat_snare_on_135548.wav'));
[bass1,fs] = audioread(strcat(folder,'/play_bass_snare_on_134640.wav'));
[bass2,fs] = audioread(strcat(folder,'/play_bass_snare_on_134700.wav'));
[snare1,fs] = audioread(strcat(folder,'/play_snare_snare_on_134952.wav'));
[snare2,fs] = audioread(strcat(folder,'/play_snare_snare_on_134930.wav'));
[tom11,fs] = audioread(strcat(folder,'/play_tom1_snare_on_140348.wav'));
[tom12,fs] = audioread(strcat(folder,'/play_tom1_snare_on_140348.wav'));
[tom21,fs] = audioread(strcat(folder,'/play_tom2_snare_on_140611.wav'));
[tom22,fs] = audioread(strcat(folder,'/play_tom2_snare_on_140634.wav'));
[tom31,fs] = audioread(strcat(folder,'/play_tom3_snare_on_140814.wav'));
[tom32,fs] = audioread(strcat(folder,'/play_tom3_snare_on_140854.wav'));

%combine drums
onsets1 = DetectOnsets(bass1);
onsets2 = DetectOnsets(hihat_closed1);
after_onset = min(length(bass1)-onsets1(1), length(hihat_closed1)-onsets2(1));
before_onset = min(onsets1(1), onsets2(1));
bass_hihat_closed1 = bass1(onsets1(1)-before_onset+1:onsets1(1)+after_onset) + hihat_closed1(onsets2(1)-before_onset+1:onsets2(1)+after_onset);

onsets1 = DetectOnsets(bass2);
onsets2 = DetectOnsets(hihat_closed2);
after_onset = min(length(bass2)-onsets1(1), length(hihat_closed2)-onsets2(1));
before_onset = min(onsets1(1), onsets2(1));
bass_hihat_closed2 = bass2(onsets1(1)-before_onset+1:onsets1(1)+after_onset) + hihat_closed2(onsets2(1)-before_onset+1:onsets2(1)+after_onset);


%% variables
window_size = 1024;
onsetDelay = 256;  % erster Frame nach so viel Samples
drum = hihat_closed1;

sound(drum, fs);

%% Trainieren
onsets = DetectOnsets(drum);
start = onsets(1) + onsetDelay;
window_function = hamming(window_size);
freqBins = floor(window_size/4);
Frames = zeros(freqBins, 3);
statLen = 80;
AStat = zeros(freqBins, statLen);
SStat = zeros(freqBins, statLen);
for t=1:statLen
  start=start+window_size;
  for k=1:3
    start2 = start+k*window_size/2;
    C = fft(window_function .* drum(start2:start2+window_size-1));
    Frames(:,k) = C(1 : freqBins);
  end
  A = ((abs(Frames(:,1)).^2)+(abs(Frames(:,2)).^2)+(abs(Frames(:,3)).^2))/3;
  A = A./ mean(A);
  S = abs (angle (Frames(:,2 ) .* Frames(:,2) ./ Frames(:,1) ./ Frames(:,3)));
  AStat(:,t) = A;
  SStat(:,t) = S;
end


%% Output von Trainieren: AMin, AMax (Grenzen in denen sich Energie bewegen soll), und SMax (Obergrenze für Steadiness)
AMax = quantile(AStat, 0.99, 2);
AMin = quantile(AStat, 0.01, 2);
%figure; plot(AMin); hold on; plot(AMax);
SMax = quantile(SStat, 0.9, 2);  %SMin = min(SStat, [], 2);
%figure; plot(SMax);

%% Testen mit Ride
onsets = DetectOnsets(ride2);
start = onsets(1) + onsetDelay;
for k=1:3
  start2 = start+k*window_size;
  C = fft(window_function .* ride2(start2:start2+window_size-1));
  Frames(:,k) = C(1 : freqBins);
end
A = ((abs(Frames(:,1)).^2)+(abs(Frames(:,2)).^2)+(abs(Frames(:,3)).^2))/3;
%A /= mean(A);
A = A./ mean(A);
S = abs (angle (Frames(:,2 ) .* Frames(:,2) ./ Frames(:,1) ./ Frames(:,3)));
ACrit = 0;  for i=1:freqBins; if (A(i)<AMin(i) || A(i)>AMax(i))  ACrit = ACrit + 1; end; end;
SCrit = 0;  for i=1:freqBins; if (S(i)>SMax(i))  SCrit = SCrit + 1; end; end;
ride = [ACrit SCrit]  % Anzahl der Bins außerhalb des Akzeptanzbereichs für Energie und Steadiness

%% Testen mit Crash
onsets = DetectOnsets(crash2);
start = onsets(1) + onsetDelay;
for k=1:3
  start2 = start+k*window_size;
  C = fft(window_function .* crash2(start2:start2+window_size-1));
  Frames(:,k) = C(1 : freqBins);
end
A = ((abs(Frames(:,1)).^2)+(abs(Frames(:,2)).^2)+(abs(Frames(:,3)).^2))/3;
%A /= mean(A);
A = A./ mean(A);
S = abs (angle (Frames(:,2 ) .* Frames(:,2) ./ Frames(:,1) ./ Frames(:,3)));
ACrit = 0;  for i=1:freqBins; if (A(i)<AMin(i) || A(i)>AMax(i))  ACrit = ACrit + 1; end; end;
SCrit = 0;  for i=1:freqBins; if (S(i)>SMax(i))  SCrit = SCrit + 1; end; end;
crash = [ACrit SCrit]



%% Testen mit Hihat closed
onsets = DetectOnsets(hihat_closed2);
start = onsets(1) + onsetDelay;
for k=1:3
  start2 = start+k*window_size;
  C = fft(window_function .* hihat_closed2(start2:start2+window_size-1));
  Frames(:,k) = C(1 : freqBins);
end
A = ((abs(Frames(:,1)).^2)+(abs(Frames(:,2)).^2)+(abs(Frames(:,3)).^2))/3;
%A /= mean(A);
A = A./ mean(A);
S = abs (angle (Frames(:,2 ) .* Frames(:,2) ./ Frames(:,1) ./ Frames(:,3)));
ACrit = 0;  for i=1:freqBins; if (A(i)<AMin(i) || A(i)>AMax(i))  ACrit = ACrit + 1; end; end;
SCrit = 0;  for i=1:freqBins; if (S(i)>SMax(i))  SCrit = SCrit + 1; end; end;
hihat_closed = [ACrit SCrit]


%% Testen mit Hihat open
onsets = DetectOnsets(hihat_open2);
start = onsets(1) + onsetDelay;
for k=1:3
  start2 = start+k*window_size;
  C = fft(window_function .* hihat_open2(start2:start2+window_size-1));
  Frames(:,k) = C(1 : freqBins);
end
A = ((abs(Frames(:,1)).^2)+(abs(Frames(:,2)).^2)+(abs(Frames(:,3)).^2))/3;
%A /= mean(A);
A = A./ mean(A);
S = abs (angle (Frames(:,2 ) .* Frames(:,2) ./ Frames(:,1) ./ Frames(:,3)));
ACrit = 0;  for i=1:freqBins; if (A(i)<AMin(i) || A(i)>AMax(i))  ACrit = ACrit + 1; end; end;
SCrit = 0;  for i=1:freqBins; if (S(i)>SMax(i))  SCrit = SCrit + 1; end; end;
hihat_open = [ACrit SCrit]


%% Testen mit Hihat open
onsets = DetectOnsets(bass2);
start = onsets(1) + onsetDelay;
for k=1:3
  start2 = start+k*window_size;
  C = fft(window_function .* bass2(start2:start2+window_size-1));
  Frames(:,k) = C(1 : freqBins);
end
A = ((abs(Frames(:,1)).^2)+(abs(Frames(:,2)).^2)+(abs(Frames(:,3)).^2))/3;
%A /= mean(A);
A = A./ mean(A);
S = abs (angle (Frames(:,2 ) .* Frames(:,2) ./ Frames(:,1) ./ Frames(:,3)));
ACrit = 0;  for i=1:freqBins; if (A(i)<AMin(i) || A(i)>AMax(i))  ACrit = ACrit + 1; end; end;
SCrit = 0;  for i=1:freqBins; if (S(i)>SMax(i))  SCrit = SCrit + 1; end; end;
bass = [ACrit SCrit]


%% Testen mit Hihat open
onsets = DetectOnsets(snare2);
start = onsets(1) + onsetDelay;
for k=1:3
  start2 = start+k*window_size;
  C = fft(window_function .* snare2(start2:start2+window_size-1));
  Frames(:,k) = C(1 : freqBins);
end
A = ((abs(Frames(:,1)).^2)+(abs(Frames(:,2)).^2)+(abs(Frames(:,3)).^2))/3;
%A /= mean(A);
A = A./ mean(A);
S = abs (angle (Frames(:,2 ) .* Frames(:,2) ./ Frames(:,1) ./ Frames(:,3)));
ACrit = 0;  for i=1:freqBins; if (A(i)<AMin(i) || A(i)>AMax(i))  ACrit = ACrit + 1; end; end;
SCrit = 0;  for i=1:freqBins; if (S(i)>SMax(i))  SCrit = SCrit + 1; end; end;
snare = [ACrit SCrit]


%% Testen mit Hihat open
onsets = DetectOnsets(tom12);
start = onsets(1) + onsetDelay;
for k=1:3
  start2 = start+k*window_size;
  C = fft(window_function .* tom12(start2:start2+window_size-1));
  Frames(:,k) = C(1 : freqBins);
end
A = ((abs(Frames(:,1)).^2)+(abs(Frames(:,2)).^2)+(abs(Frames(:,3)).^2))/3;
%A /= mean(A);
A = A./ mean(A);
S = abs (angle (Frames(:,2 ) .* Frames(:,2) ./ Frames(:,1) ./ Frames(:,3)));
ACrit = 0;  for i=1:freqBins; if (A(i)<AMin(i) || A(i)>AMax(i))  ACrit = ACrit + 1; end; end;
SCrit = 0;  for i=1:freqBins; if (S(i)>SMax(i))  SCrit = SCrit + 1; end; end;
tom1 = [ACrit SCrit]


%% Testen mit Hihat open
onsets = DetectOnsets(tom22);
start = onsets(1) + onsetDelay;
for k=1:3
  start2 = start+k*window_size;
  C = fft(window_function .* tom22(start2:start2+window_size-1));
  Frames(:,k) = C(1 : freqBins);
end
A = ((abs(Frames(:,1)).^2)+(abs(Frames(:,2)).^2)+(abs(Frames(:,3)).^2))/3;
%A /= mean(A);
A = A./ mean(A);
S = abs (angle (Frames(:,2 ) .* Frames(:,2) ./ Frames(:,1) ./ Frames(:,3)));
ACrit = 0;  for i=1:freqBins; if (A(i)<AMin(i) || A(i)>AMax(i))  ACrit = ACrit + 1; end; end;
SCrit = 0;  for i=1:freqBins; if (S(i)>SMax(i))  SCrit = SCrit + 1; end; end;
tom2 = [ACrit SCrit]


%% Testen mit Hihat open
onsets = DetectOnsets(tom32);
start = onsets(1) + onsetDelay;
for k=1:3
  start2 = start+k*window_size;
  C = fft(window_function .* tom32(start2:start2+window_size-1));
  Frames(:,k) = C(1 : freqBins);
end
A = ((abs(Frames(:,1)).^2)+(abs(Frames(:,2)).^2)+(abs(Frames(:,3)).^2))/3;
%A /= mean(A);
A = A./ mean(A);
S = abs (angle (Frames(:,2 ) .* Frames(:,2) ./ Frames(:,1) ./ Frames(:,3)));
ACrit = 0;  for i=1:freqBins; if (A(i)<AMin(i) || A(i)>AMax(i))  ACrit = ACrit + 1; end; end;
SCrit = 0;  for i=1:freqBins; if (S(i)>SMax(i))  SCrit = SCrit + 1; end; end;
tom3 = [ACrit SCrit]


%% Testen mit Hihat closed + bass
onsets = DetectOnsets(bass_hihat_closed2);
start = onsets(1) + onsetDelay;
for k=1:3
  start2 = start+k*window_size;
  C = fft(window_function .* bass_hihat_closed2(start2:start2+window_size-1));
  Frames(:,k) = C(1 : freqBins);
end
A = ((abs(Frames(:,1)).^2)+(abs(Frames(:,2)).^2)+(abs(Frames(:,3)).^2))/3;
%A /= mean(A);
A = A./ mean(A);
S = abs (angle (Frames(:,2 ) .* Frames(:,2) ./ Frames(:,1) ./ Frames(:,3)));
ACrit = 0;  for i=1:freqBins; if (A(i)<AMin(i) || A(i)>AMax(i))  ACrit = ACrit + 1; end; end;
SCrit = 0;  for i=1:freqBins; if (S(i)>SMax(i))  SCrit = SCrit + 1; end; end;
bass_hihat_closed = [ACrit SCrit]

end


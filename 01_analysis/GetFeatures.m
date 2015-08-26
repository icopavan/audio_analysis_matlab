function [ F, num_peaks, Max_peaks, Max_peaks_per_interval, mean_peak, Frames, A, rms_ges, rms_i1, rms_i2, rms_rate_i1, rms_rate_i2, Peaks_frames, peak_shift_c2, peak_shift_c3, Mean_Peaks_frames, mean_peak_shift_c2, mean_peak_shift_c3, mean_peak_shift_delta, s ] = GetFeatures( y, onset, window_size )
%Analyse Window
%   Analyses frequency characteristics of a window in a soundfile

    if nargin < 3
        window_size = 2048;  %window size in samples
    end    
    if nargin < 2
        onset = 0;  %window size in samples
    end  
    
    %%%%%%%%%%%%%%%%
    %INPUT: only the window
    %%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %NORMALIZATION -> largest value = 1 (w_norm = w./max(w)))
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %frequency spectrum F(k)
    window_function = hamming(window_size);
    %F = abs(fft(window_function.*y(start:start+window_size*3-1)));  
    F = abs(fft(window_function.*y(onset:onset+window_size-1))); 
   

    % noise reduction    
    noise = abs(fft(window_function.*((y(1:2048)+y(2049:4096)+y(4097:6144))./3)));
    F=F-noise;

    
    %find frequency peaks
    %[pks,locs] = findpeaks(F, 'MinPeakHeight', max(F(:,1))/10); 
    [pks,locs] = findpeaks(F);   %find all peaks
   
    pks = pks(1:length(pks)/2);
    locs = locs(1:length(locs)/2);
    
    %sorts peaks descendending
    P = sortrows([locs';pks']',-2); % sort peaks descendending to pick the three lagest of them, afterwards
    
    size_P = size(P);
    num_peaks = size_P(1);
    max_amp = P(1,2);
    
    if size_P(1) > 0        
        Peak_1 = [P(1,1),P(1,2),100];
    else
        Peak_1 = [0,0,0];
    end
    
    %returns 3 maximum peaks
    if size_P(1) > 1        
        Peak_2 = [P(2,1),P(2,2),P(2,2)/(max_amp/100)]; % Peak_2 = [frequency, amplitude, percentage of amplitude compared to max_amp]
    else
        Peak_2 = [0,0,0];
    end
    
    if size_P(1) > 2        
        Peak_3 = [P(3,1),P(3,2),P(3,2)/(max_amp/100)]; % Peak_3 = [frequency, amplitude, percentage of amplitude compared to max_amp]
    else
        Peak_3 = [0,0,0];
    end
    
    Max_peaks = [Peak_1; Peak_2; Peak_3];
    
    %max peaks for every interval when F is split in 10 intervals
    [size_F_x,size_F_y] = size(F);
    interval_size = floor(size_F_x/2/10);
    Max_peaks_per_interval = zeros(2,10);
    for k=1:10
       start = (k-1)*interval_size+1;
       stop = k*interval_size;
       F_tmp = F(start:stop);
       [mag_max_pks_tmp, idx_max_pks_tmp] = max(F_tmp);      
       Max_peaks_per_interval(:,k)=[idx_max_pks_tmp+start, mag_max_pks_tmp];
    end
    
    %frames C1(k), C2(k), C3(k)
    frame_size = round(window_size/2);
    Frames = zeros(frame_size,3); 
    window_function = hamming(frame_size); 
    start = onset;
    for k=1:3
     if start+k*frame_size < length(y)         % if the audio file does not end
         start = start+(k-1)*frame_size/2;
         Frames(:,k) = abs(fft(window_function.*y(start:start+frame_size-1)));
     end
    end
    
    %mean peak frequency and amplitude 
    mean_peak_amplitude_tmp = 0;
    mean_peak_frequency_tmp = 0;
    for i=1:length(pks)
      mean_peak_amplitude_tmp = mean_peak_amplitude_tmp + abs(pks(i)^2);
      mean_peak_frequency_tmp = mean_peak_frequency_tmp + (abs(pks(i)^2) * locs(i));
    end
    mean_peak_frequency = mean_peak_frequency_tmp/mean_peak_amplitude_tmp;
    mean_peak_amplitude = mean_peak_amplitude_tmp/length(pks);
    mean_peak = [mean_peak_frequency,mean_peak_amplitude,mean_peak_amplitude/(max_amp/100)]; % Peak_3 = [frequency, amplitude, percentage of amplitude compared to max_amp]
    
    %Energy A(k)
    A = ((abs(Frames(:,1)).^2)+(abs(Frames(:,2)).^2)+(abs(Frames(:,3)).^2))/3; 
   
    %root mean sqare energy of F
    %TODO: rms with normalized amplitudes
    rms_ges_tmp = 0;
    for i=1:length(F)
      rms_ges_tmp = rms_ges_tmp + abs(F(i)^2); 
    end
    rms_ges = rms_ges_tmp/length(F);    
    
    %root mean sqare energy of F - Interval 1
    rms_i1 = 0;
    for i=1:length(F)/6
      rms_i1 = rms_i1 + abs(F(i)^2);
    end
    
    rms_i1 = rms_i1/(length(F)/6); 
    
    %root mean sqare energy of F - Interval 2
    rms_i2 = 0;
    for i=round(length(F)/6+1:length(F))
      rms_i2 = rms_i2 + abs(F(i)^2);  
    end
    
    rms_i2 = rms_i2/(length(F)-length(F)/6);
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %rms rate
    %To save the relation between \lstinline{I1} and \lstinline{I2}, the variable \lstinline{IRate} is used. 
    %It saves a value between -1 and +1, whereas a negative value means that \lstinline{I1} is greater and 
    %a positive value shows that \lstinline{I2} is greater. If \lstinline{IRate} is -1, \lstinline{meanI1} 
    %is 1 and \lstinline{meanI2} is 0. inversely, if \lstinline{IRate} is +1, \lstinline{meanI1} is 0 and 
    %\lstinline{meanI2} is 1.
    rms_rate_i1 = ((rms_i1-rms_ges)/(Peak_1(2)/100))/100;
    rms_rate_i2 = ((rms_i2-rms_ges)/(Peak_1(2)/100))/100;
  
    % max frame peaks
    C1 = Frames(:,1);
    C2 = Frames(:,2);
    C3 = Frames(:,3);    
    [mag_1, idx_1] = max(abs(C1));
    [mag_2, idx_2] = max(abs(C2));
    [mag_3, idx_3] = max(abs(C3));    

    %max peak of each frame
    peak_c1 = [idx_1, mag_1, max_amp/(mag_1/100)];  %[frequency, amplitude, percentage of amplitude compared to max_amp]    
    peak_c2 = [idx_2, mag_2, max_amp/(mag_2/100)];  %[frequency, amplitude, percentage of amplitude compared to max_amp]    
    peak_c3 = [idx_3, mag_3, max_amp/(mag_3/100)];  %[frequency, amplitude, percentage of amplitude compared to max_amp]
    
    Peaks_frames = [peak_c1; peak_c2; peak_c3];
    
    peak_shift_c2 = [idx_1-idx_2,max_amp/(mag_1/100)-max_amp/(mag_2/100)]; 
    peak_shift_c3 = [idx_2-idx_3,max_amp/(mag_2/100)-max_amp/(mag_3/100)]; 
    
    
    %mean peak for each frame
    
    %frequency peaks
    [pks_c1,locs_c1] = findpeaks(C1, 'MinPeakHeight', max(C1)/10);  %find all peaks
    [pks_c2,locs_c2] = findpeaks(C2, 'MinPeakHeight', max(C2)/10);   
    [pks_c3,locs_c3] = findpeaks(C3, 'MinPeakHeight', max(C3)/10);   
    
    pks_c1 = pks_c1(1:length(pks_c1)/2);
    pks_c2 = pks_c2(1:length(pks_c2)/2);
    pks_c3 = pks_c3(1:length(pks_c3)/2);
    
    locs_c1 = locs_c1(1:length(locs_c1)/2);
    locs_c2 = locs_c2(1:length(locs_c2)/2);
    locs_c3 = locs_c3(1:length(locs_c3)/2);
    
    %mean peak
    %c1
    mean_peak_amplitude_c1_tmp = 0;
    mean_peak_frequency_c1_tmp = 0;
    for i=1:length(pks_c1)
      mean_peak_amplitude_c1_tmp = mean_peak_amplitude_c1_tmp + abs(pks_c1(i)^2);
      mean_peak_frequency_c1_tmp = mean_peak_frequency_c1_tmp + (abs(pks_c1(i)^2) * locs_c1(i));
    end
    mean_peak_frequency_c1 = mean_peak_frequency_c1_tmp/mean_peak_amplitude_c1_tmp;
    mean_peak_amplitude_c1 = mean_peak_amplitude_c1_tmp/length(pks_c1);
    mean_peak_c1 = [mean_peak_frequency_c1,mean_peak_amplitude_c1,mean_peak_amplitude_c1/(max_amp/100)]; %[frequency, amplitude, percentage of amplitude compared to max_amp]
    %c2
    mean_peak_amplitude_c2_tmp = 0;
    mean_peak_frequency_c2_tmp = 0;
    for i=1:length(pks_c2)
      mean_peak_amplitude_c2_tmp = mean_peak_amplitude_c2_tmp + abs(pks_c2(i)^2);
      mean_peak_frequency_c2_tmp = mean_peak_frequency_c2_tmp + (abs(pks_c2(i)^2) * locs_c2(i));
    end
    mean_peak_frequency_c2 = mean_peak_frequency_c2_tmp/mean_peak_amplitude_c2_tmp;
    mean_peak_amplitude_c2 = mean_peak_amplitude_c2_tmp/length(pks_c2);
    mean_peak_c2 = [mean_peak_frequency_c2,mean_peak_amplitude_c2,mean_peak_amplitude_c2/(max_amp/100)]; %[frequency, amplitude, percentage of amplitude compared to max_amp]
    %c3
    mean_peak_amplitude_c3_tmp = 0;
    mean_peak_frequency_c3_tmp = 0;
    for i=1:length(pks_c3)
      mean_peak_amplitude_c3_tmp = mean_peak_amplitude_c3_tmp + abs(pks_c3(i)^2);
      mean_peak_frequency_c3_tmp = mean_peak_frequency_c3_tmp + (abs(pks_c3(i)^2) * locs_c3(i));
    end
    mean_peak_frequency_c3 = mean_peak_frequency_c3_tmp/mean_peak_amplitude_c3_tmp;
    mean_peak_amplitude_c3 = mean_peak_amplitude_c3_tmp/length(pks_c3);
    mean_peak_c3 = [mean_peak_frequency_c3,mean_peak_amplitude_c3,mean_peak_amplitude_c3/(max_amp/100)]; %[frequency, amplitude, percentage of amplitude compared to max_amp]
     
    Mean_Peaks_frames = [mean_peak_c1; mean_peak_c2; mean_peak_c3]; 
    
    %mean peak shift
    mean_peak_shift_c2 = [mean_peak_frequency_c1-mean_peak_frequency_c2,mean_peak_amplitude_c1/(max_amp/100)-mean_peak_amplitude_c2/(max_amp/100)]; 
    mean_peak_shift_c3 = [mean_peak_frequency_c2-mean_peak_frequency_c3,mean_peak_amplitude_c2/(max_amp/100)-mean_peak_amplitude_c3/(max_amp/100)]; 
    
    mean_peak_shift_delta = [mean_peak_shift_c2(1)-mean_peak_shift_c3(1),mean_peak_shift_c2(2)-mean_peak_shift_c3(2)];
   
    
    %Phase shift / Steadiness S(k)    
    %P = (Frames(:,2)/abs(Frames(:,2)))*(abs(Frames(:,1))/Frames(:,1));
    %S = P-(Frames(:,2)/abs(Frames(:,2)))*(abs(Frames(:,3))/Frames(:,3));
    
    %TODO use mean peak instead of idx
    mean_peak_frequency_c1
    % P1 = angle(C1(idx_1))
    % P2 = angle(C2(idx_2))
    % P3 = angle(C3(idx_3))
    P1 = angle(mean_peak_frequency_c1);
    P2 = angle(mean_peak_frequency_c2);
    P3 = angle(mean_peak_frequency_c3);
    
    %test1 = C2(idx_2)/abs(C2(idx_2))*abs(C1(idx_1))/C1(idx_1);
    %test2 = C2(idx_2)/abs(C2(idx_2))*abs(C3(idx_3))/C3(idx_3);    
    %test_s = test1-test2;
    %test_s = abs(test_s)^2;
  
    %amplitude_ratio1 = mag_2/mag_1;
    %amplitude_ratio2 = mag_3/mag_1;
    
    %phase_lag1 = P2 - P1;
    %phase_lag2 = P3 - P1;
    %S = phase_lag2 - phase_lag1;
    
     phase_lag1 = P2 - P1;
     phase_lag2 = P2 - P3;
    %S = abs(phase_lag1 + phase_lag2);
     s = abs(phase_lag1 + phase_lag2)^2;
     
     S = angle(C2.*C2./C1./C3);
end


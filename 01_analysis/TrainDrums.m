function [AMax, AMin, SMax ] = TrainDrums( data )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    window_size = 1024;
    onsetDelay = 256; 
    window_function = hamming(window_size);
    freqBins = floor(window_size/4);
    statLen = 80;
    AMax = zeros(freqBins,length(data(1,:)));
    AMin =zeros(freqBins,length(data(1,:)));
    SMax = zeros(freqBins,length(data(1,:)));
    for i = 1:length(data(1,:))
        drum = data(:,i);
        onsets = DetectOnsets(drum);
        start = onsets(1) + onsetDelay;
        Frames = zeros(freqBins, 3);
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
        AMax(:,i) = quantile(AStat, 0.99, 2);
        AMin(:,i) = quantile(AStat, 0.01, 2);
        SMax(:,i) = quantile(SStat, 0.9, 2);  
    end

end


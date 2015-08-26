function [] = Classify(y, AMax, AMin, SMax)

    window_size = 1024;
    onsetDelay = 256;
    window_function = hamming(window_size);
    freqBins = floor(window_size/4);
    onsets = DetectOnsets(y);
    start = onsets(1) + onsetDelay;
    Frames = zeros(freqBins, 3);
    for i=1:3
      start2 = start+i*window_size;
      C = fft(window_function .* y(start2:start2+window_size-1));
      Frames(:,i) = C(1 : freqBins);
    end
    A = ((abs(Frames(:,1)).^2)+(abs(Frames(:,2)).^2)+(abs(Frames(:,3)).^2))/3;
    A = A./ mean(A);
    S = abs (angle (Frames(:,2 ) .* Frames(:,2) ./ Frames(:,1) ./ Frames(:,3)));
        
    Results = zeros(length(AMax(1,:)),2);
    for i = 1:length(AMax(1,:))        
        ACrit = 0;  
        for j=1:freqBins
            if (A(j)<AMin(j,i) || A(j)>AMax(j,i))  
                ACrit = ACrit + 1;
            end
        end
        SCrit = 0; 
        for j=1:freqBins
            if (S(j)>SMax(j,i))  
                SCrit = SCrit + 1;
            end
        end
        Results(i,:) = [ACrit SCrit];  % Anzahl der Bins außerhalb des Akzeptanzbereichs für Energie und Steadiness

    end
    
    Results
end
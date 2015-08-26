function [  ] = korrelationskoeffizient2( )


    %% get data
    folder = 'E:\FH\Masterthesis\recordings\14_08_18\wav';
    [ drums, training_data, test_data, fs ] = GetData( folder );

    %% set variables    
    num_training_data = length(training_data(1,:));    
    num_test_data = length(test_data(1,:));
    
    window_size = 1024;
    window_function = hamming(window_size);
    onsetDelay = 512;
    freqBins = window_size / 4;
    
    
    %% training
    statLen = 80;
    AMax = zeros(freqBins,num_training_data);  
    AMin = zeros(freqBins,num_training_data);
    AMaxSum = zeros(freqBins,9);  
    AMinSum = zeros(freqBins,9);
    SMax = zeros(freqBins,num_training_data);  
    
    for i = 1:num_training_data
        y = training_data(:,i);     
        onsets = DetectOnsets(y);
        start = onsets(1) + onsetDelay; 
        Frames = zeros(freqBins, 3);
        AStat = zeros(freqBins, statLen);
        SStat = zeros(freqBins, statLen);
        
        %AStatMean
        
        if mod(i-1,10)==0
            AStatSum = zeros(freqBins, statLen);
        end
        
        for j=1:statLen
          start=start+window_size;
          for k=1:3
            start2 = start+k*window_size/2;            
            C = fft( window_function .* y(start2:start2+window_size-1));
            Frames(:,k) = C(1 : freqBins);
          end
          A = ((abs(Frames(:,1)).^2)+(abs(Frames(:,2)).^2)+(abs(Frames(:,3)).^2))/3;
          A = A./ mean(A);
          S = abs (angle (Frames(:,2 ) .* Frames(:,2) ./ Frames(:,1) ./ Frames(:,3)));
          
          AStat(:,j) = A;
          SStat(:,j) = S;
        end
        
        '-'
        test1 = AStatSum(1,1)
        test2 = AStat(1,1)
        AStatSum = AStatSum + AStat;
        test3 = AStatSum(1,1)
        
        if mod(i-1,10)==9
           loc = ((i+9)-mod((i-1),10))/10;
           AMaxSum(:,loc) = quantile(AStatSum, 0.99, 2);  
           AMinSum(:,loc) = quantile(AStatSum, 0.01, 2); 
        end                
        
        % Output von Trainieren: AMin, AMax (Grenzen in denen sich Energie bewegen soll), und SMax (Obergrenze f�r Steadiness)
        AMax(:,i) = quantile(AStat, 0.99, 2);  
        AMin(:,i) = quantile(AStat, 0.01, 2);
        
        SMax(:,i) = quantile(SStat, 0.9, 2);  %SMin = min(SStat, [], 2);
    end
    
    %% testing
    ACrit = zeros(num_test_data,num_training_data);
    ACritSum = zeros(num_test_data,num_training_data/length(drums));
    SCrit = zeros(num_test_data,num_training_data);
    for i = 1:num_test_data
        
        y = test_data(:,i);  
        start = onsets(1) + onsetDelay;
        for k=1:3
          start2 = start+k*window_size;
          C = fft(window_function .* y(start2:start2+window_size-1));
          Frames(:,k) = C(1 : freqBins);
        end
        A = ((abs(Frames(:,1)).^2)+(abs(Frames(:,2)).^2)+(abs(Frames(:,3)).^2))/3;
        A = A./ mean(A);
        S = abs (angle (Frames(:,2 ) .* Frames(:,2) ./ Frames(:,1) ./ Frames(:,3)));
        
        for j = 1:num_training_data

            aCrit = 0;  
            for k=1:freqBins; 
                if (A(k)<AMin(k,j) || A(k)>AMax(k,j))  
                    aCrit = aCrit + 1; 
                end; 
            end;
            
            aCritSum = 0; 
            loc = ((j+9)-mod((j-1),10))/10; 
            for k=1:freqBins;
                if (A(k)<AMinSum(k,loc) || A(k)>AMaxSum(k,loc))  
                    aCritSum = aCritSum + 1; 
                end; 
            end;

            sCrit = 0;  
            for k=1:freqBins;
                if (S(k)>SMax(k,j))  
                    sCrit = sCrit + 1;
                end;
            end;

            ACrit(i,j) = aCrit;
            ACritSum(i,loc) = aCrit;
            SCrit(i,j) = sCrit;
            
            %[aCrit sCrit]  % Anzahl der Bins außerhalb des Akzeptanzbereichs für Energie und Steadiness
        end
    end
        
    %% Write results to testfile
    path = 'C:\Users\Katrin\Desktop';
    timestamp = datestr(now,'yymmddHHMMSS');
    mkdir(strcat(path, '\','classification'));
    file = fopen(strcat(path,'\','classification','\classification_results',timestamp,'.txt'),'at');
    
    fprintf(file,'%s\n------------------------------------------------------\n\n', char(strcat({'Classification log '},timestamp)));
  
    fprintf(file,'%s\n',char(strcat({'Onset delay: '},num2str(onsetDelay))));
    fprintf(file,'%s\n\n\n',char(strcat({'Window size: '},num2str(window_size))));
    
    for i = 1:length(ACrit)
        fprintf(file,'%s\n---------------------------\n',char(strcat({'tested '},drums(i))));
        [n_min, i_min] = min(ACrit(i,:));
        fprintf(file,'%s\n',char(strcat({'- classified by energy as '},drums(i_min),{' with value '},num2str(n_min))));
        [n_min, i_min] = min(ACritSum(i,:));
        fprintf(file,'%s\n',char(strcat({'- classified by energy sum as '},drums(i_min*10),{' with value '},num2str(n_min))));
        [n_min, i_min] = min(SCrit(i,:));
        fprintf(file,'%s\n',char(strcat({'- classified by steadiness as '},drums(i_min),{' with value '},num2str(n_min))));
        
        pointer = 1;
        for j = 1:9
            fprintf(file,'\n%s (E): ',char(drums(pointer)));
            for k = 1:10
                fprintf(file,'%s, ',num2str(ACrit(i,pointer)));
                pointer = pointer+1;
            end
            
            fprintf(file,'\n%s ',char(strcat({'Sum (E): '},num2str(ACritSum(i,(pointer-1)/10)))));   
            fprintf(file,'\n%s: ',num2str(sum(ACrit(i,pointer-10:pointer-1))));            
            pointer = pointer-10;
            fprintf(file,'\n%s (S): ',char(drums(pointer)));
            for k = 1:10
                fprintf(file,'%s,',num2str(SCrit(i,pointer)));
                pointer = pointer+1;
            end
            fprintf(file,'\n');
        end
        fprintf(file,'\n\n\n');
    end
    
    fclose(file);
 
end


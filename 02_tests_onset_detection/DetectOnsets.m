function onsets = DetectOnsets(y, threshold, window_size, lock_size, reference_factor_1, reference_factor_2)
    
 
    if nargin < 6
        reference_factor_1 = 1;
    end
    if nargin < 5
        reference_factor_2 = 0.5;
    end
    if nargin < 4
        lock_size = 8;
    end
    if nargin < 3
        window_size = 512;  %window size in samples
    end
    
    %overlap = 4;   %window overlap size
    
    y = abs(y);

    N = floor(length(y)/window_size);    %number of windows
    max_values = zeros(1,N);             %array to push max values of the analysis
    min_values = zeros(1,N);             %array to push min values of the analysis
    onsets = [];

    start = 1;
    stop = window_size;
    reference_size = 1;
    distance = 0;
    lock = 0;
    
    for i=1:N
      %define window
      window = y(start:stop);

      %get min and max peaks
      [max_value, max_idx] = max(window);
      max_values(i) = max_value;
      min_values(i) = min(window);  
      
      %detect onset
      if i>reference_size+1          

          min_reference = mean(min_values(i-reference_size-1:i-1))*reference_factor_1;
          max_reference = mean(max_values(i-reference_size-1:i-1))*reference_factor_1;
                  
          if (min_reference > threshold) min_reference = -threshold; end
          if (max_reference < threshold) max_reference = threshold; end  

          if (min_values(i) < min_reference && max_values(i) > max_reference && lock == 0) 
             onsets = [onsets, start+max_idx]; 
             reference_size=1;
             distance=0;
             lock = lock_size;
          else
              distance=distance+1;
              reference_size = ceil(distance*reference_factor_2);
          end
          if lock > 0
              lock = lock -1;
          end
          
      end

      %set new start and stop value
      start = window_size*i+1;
      stop = window_size*(i+1); 
    end
    
    size(onsets)
end




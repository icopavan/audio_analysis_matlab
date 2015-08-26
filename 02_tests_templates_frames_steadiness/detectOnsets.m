function onsets = detectOnsets(y, window_size, lock_size, reference_denominator, treshold)
    
    if nargin < 5
        treshold = 0.05;
    end
    if nargin < 4
        reference_denominator = 2.5;
    end
    if nargin < 3
        lock_size = 10;
    end
    if nargin < 2
        window_size = 128;  %window size in samples
    end
    
    %overlap = 4;   %window overlap size

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

      [min_value, min_idx] = min(window);
      [max_value, max_idx] = max(window);

      %get min and max peaks
      min_values(i) = min(window);
      max_values(i) = max(window);
      
      %detect onset
      if i>reference_size 
          min_reference = -treshold;
          max_reference = treshold;
          for k=1:reference_size
            min_reference = min_reference + min_values(i-k);  
            max_reference = max_reference + max_values(i-k);  
          end
          min_reference = min_reference/reference_size;
          max_reference = max_reference/reference_size;

          if (min_values(i) < min_reference && max_values(i) > max_reference && lock == 0) 
             onsets = [onsets, start+max_idx]; 
             reference_size=1;
             distance=0;
             lock = lock_size;
          else
              distance=distance+1;
              reference_size = ceil(distance/reference_denominator);
          end
          if lock > 0
              lock = lock -1;
          end
      end

      %set new start and stop value
      start = window_size*i+1;
      stop = window_size*(i+1); 
    end
end




function test(window_size, lock_size, reference_factor_1, reference_factor_2)
%TRAIN Summary of this function goes here
%   Detailed explanation goes here

    if nargin < 4
        reference_factor_1 = 1;
    end
    if nargin < 3
        reference_factor_2 = 0.5;
    end
    if nargin < 2
        lock_size = 8;
    end
    if nargin < 1
        window_size = 512;  %window size in samples
    end
    
   [ testData, fs ] = getData();
   plotCount = 1;
   mkdir('results'); 
   date = datestr(now,'yymmddHHMMSS');


    for i=1:length(testData)

       y=testData{i}; 
       
       mean_value = mean(y(1:1024));
       
       y=y-mean_value;
    
       threshold = max(y(1:1024))*5;
       
       recordTime = length(y)/fs;
       
       OD=OnsetDetector(threshold, window_size, lock_size, reference_factor_1, reference_factor_2);
       OD.start(recordTime,fs);
       
       N = floor(length(y)/window_size);    %number of windows
       
       %detect all onsets in y
       start = 1;
       stop = window_size;
       for j=1:N
          %define window
          frame = y(start:stop);
          
          %detect onset
          onset=OD.detectOnset(frame);         
          
          %set new start and stop value
          start = window_size*j+1;
          stop = window_size*(j+1);
       end
       
       %get all onsets
       onsets = OD.onsets();
       
       %draw onsets
       fig=DrawOnsets( plotCount, y, fs, onsets );
       plotCount=plotCount+1;

       filename = strcat('results/',date,'_',num2str(window_size),'_',num2str(lock_size),'_',num2str(reference_factor_1),'_',num2str(reference_factor_2),'_',num2str(i)); 
       
       %saveas(fig,filename);
       print(fig,'-dpdf','-r300',strcat(filename, '.pdf'));
       print(fig,'-dpng','-r300',strcat(filename, '.png'));

   end
end


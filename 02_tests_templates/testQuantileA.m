function [ Results ] = testQuantileA( A, AMax, AMin, windowSize, hz)
%TESTQUANTILE Summary of this function goes here
%   Detailed explanation goes here
   
    if nargin < 5
        hz = 22050;        
    end
    
    nbins = round(windowSize/44100*hz);
    
       

    %% calculate ACrit (bins which are not between AMin and AMax
    Results = zeros(1,length(AMax(:,1)));    
    for i = 1:length(AMax(:,1))  
       %plot
       set(0,'Units','pixels') 
%        fs=44100;
%        h1 = figure(); 
%     
%         f = 0:length(A)-1;                              % frequency scale - scale from 0 to length(y)-1
%         f = f*fs/length(A);
% 
%         plot(f,abs(A(1:length(A)))), grid;
% 
%         hold on       
%         plot(f,abs(AMin(i,1:length(A))),'Color','g');
%         plot(f,abs(AMax(i,1:length(A))),'Color','r');
%         hold off
%         axis([0 fs/2 0 1]);
%         xlim([40,10000]);
%         xlabel('f [Hz] \rightarrow'), ylabel('|A(f) \rightarrow|'); 
        
        
        hits = 0;  
        %for j=1:windowSize/d
        for j=1:nbins
            if (A(j)<AMin(i,j) || A(j)>AMax(i,j))  
                hits = hits + 1;
            end
        end
        Results(i) = hits;        
    end
    
%     %% compare with min and max tresholds
%     ResultsTresh=zeros(size(minTresh));
%     for i = 1:length(maxTresh(:,1))   
%        for j = 1:length(ResultsACrit(:,1))
%           if ResultsACrit(j)>=minTresh(i,j) && ResultsACrit(j)<=maxTresh(i,j) 
%               ResultsTresh(i,j)=1;
%           end
%        end
%     end
%     
%     %% sum
%     ResultTreshSum=zeros(length(ResultsTresh(:,1)),1);
%     for i = 1:length(ResultsTresh(:,1))
%         ResultTreshSum(i)=sum(ResultsTresh(i,:));
%     end
end


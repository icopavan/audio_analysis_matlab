function [ Results ] = testQuantileAD( A, AMax, AMin, windowSize, hz)
%TESTQUANTILE Summary of this function goes here
%   Detailed explanation goes here

    % limits frequncy domain
    if nargin < 5
        hz = 22050;        
    end
    nbins = round(windowSize/44100*hz);

    %% calculate ACrit (bins which are not between AMin and AMax
    Results = zeros(1,length(AMax(:,1)));    
    for i = 1:length(AMax(:,1))  
        
        
%      %plot
%      set(0,'Units','pixels') 
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
        
        
        
        ACrit = 0;  
        for j=1:nbins
            distance=0;
            if A(j)<AMin(i,j)
               distance = AMin(i,j)-A(j);
            elseif A(j)>AMax(i,j)
               distance = A(j)-AMax(i,j);
            end
            ACrit = ACrit + distance;
        end
        Results(i) = ACrit;        
    end
    
end


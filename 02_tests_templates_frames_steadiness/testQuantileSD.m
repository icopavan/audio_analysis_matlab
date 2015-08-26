function [ Results ] = testQuantileSD( A, S, SMean, SMin, SMax, windowSize, hz)
%TESTQUANTILE Summary of this function goes here
%   Detailed explanation goes here
   
    if nargin < 7
        hz = 22050;        
    end
    
    nbins = round(windowSize/44100*hz);
    
    
   % [pks,locsPks] = findpeaks(A(1:nbins), 'MinPeakHeight', max(A(1:nbins))/5);
    [pks,locsPks] = findpeaks(A(1:nbins), 'MinPeakHeight', max(A(3:nbins))/5);
    Results = zeros(1,length(SMax(:,1)));   
    

    for i = 1:length(SMax(:,1))  
        distance=0;
        for j=1:length(pks)        
            loc = locsPks(j);
%             if S(loc)<SMin(i,loc)
%                distance = distance + (SMin(i,loc)-S(loc));
%             elseif S(loc)>SMax(i,loc)
%                distance = distance + (S(loc)-SMax(i,loc));
%             end
%             if S(loc)>SMax(i,loc)
%                distance = distance + (S(loc)-SMax(i,loc));
%             end
%              if S(loc)<SMin(i,loc)
%                 distance = distance + 1;
%              elseif S(loc)>SMax(i,loc)
%                 distance = distance + 1;
%              end
            distance = distance + abs(S(loc)-SMean(i,loc));
        end
       distance=distance/length(pks);

        for j=3:nbins
%             if S(j)<SMin(i,j)
%                distance = distance + (SMin(i,j)-S(j));
%             elseif S(j)>SMax(i,j)
%                distance = distance + (S(j)-SMax(i,j));
%             end

%            distance = distance + abs(S(j)-SMean(i,j));
        end
        Results(i) = distance;        
    end
end


function [ Results ] = testQuantileAD( A, AMax, AMin, windowSize)
%TESTQUANTILE Summary of this function goes here
%   Detailed explanation goes here

    % limits frequncy domain
    denom=32;
    peakThreshold = 1;

    %% calculate distance from min/max at peak positions
    [pks,locsPks] = findpeaks(A(1:windowSize/denom,1));
    Results = zeros(1,length(AMax(:,1)));    
    for i = 1:length(AMax(:,1))  
        ACrit = 0;  
        for j=1:length(pks)            
            loc = locsPks(j);
            distance=0;
            if A(loc)<AMin(i,loc)
               distance = AMin(i,loc)-A(loc);
            elseif A(loc)>AMax(i,loc)
               distance = A(loc)-AMax(i,loc);
            end
            ACrit = ACrit + distance;
        end
        ACrit=ACrit/length(pks);
        Results(i) = ACrit;        
    end
    
end


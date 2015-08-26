function [ Results ] = testQuantileADMean( A, AMean, windowSize)
%TESTQUANTILE Summary of this function goes here
%   Detailed explanation goes here


    set(0,'Units','pixels') 

    % limits frequncy domain
    denom=16;

    %% calculate ACrit (bins which are not between AMin and AMax
    Results = zeros(1,length(AMean(:,1)));    
    for i = 1:length(AMean(:,1))  
        ACrit = 0;  
        for j=1:windowSize/denom
            distance=abs(A(j)-AMean(i,j));
            ACrit = ACrit + distance;
        end
        Results(i) = ACrit;        
    end
    
end


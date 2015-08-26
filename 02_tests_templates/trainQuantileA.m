function [ minTresh, maxTresh ] = trainQuantileA( A, n, AMax, AMin )
%TRAINQUANTILEA Summary of this function goes here
%   Detailed explanation goes here

    % zeros arrays for results
    minTresh = zeros(length(AMax(:,1)));
    maxTresh = zeros(length(AMax(:,1)));
    
    for i=n:n:length(A(:,1))  
        for j=1:n
            
            %get testframe
            ATtest = A(i+j-n,:);    
            
            % compare ATest to template
            for k = 1:length(AMax(:,1)) 
                ACrit = 0;  
                for p=1:length(A)-1
                    if (ATtest(p+1)<AMin(k,p) || ATtest(p+1)>AMax(k,p))  
                        ACrit = ACrit + 1;
                    end
                end

                %min acrit
                if minTresh(i/n,k)==0
                    minTresh(i/n,k)=ACrit;
                end
                minTresh(i/n,k) = min([ACrit,minTresh(i/n,k)]);                
                %max acrit
                maxTresh(i/n,k) = max([ACrit,maxTresh(i/n,k)]);
                if maxTresh(i/n,k)==0
                    maxTresh(i/n,k)=ACrit;
                end
            end
        end
    end

end


function [AMin, AMax, AMean, Peaks] = createTemplates( A, n, qmin, qmax, peakThresholdDenom )
%CREATETEMPLATE Summary of this function goes here
% Author - Katrin Hewer
% creation date - 20014-11-08

    %% define variables
    if nargin < 5
       peakThresholdDenom = 5; 
    end
    if nargin < 3
       qmin=0.01; 
    end
    if nargin < 4
       qmax=0.99; 
    end
    
    % get size    
    sizeA = size(A);

    %% templates
    AMin = zeros(sizeA(1)/n,sizeA(2));
    AMax = zeros(sizeA(1)/n,sizeA(2));
    AMean = zeros(sizeA(1)/n,sizeA(2));
    Peaks = zeros(sizeA(1)/n,sizeA(2));
    locDrum = 0;
    for i=1:n:sizeA(1)
        
        Atmp = A(i:i+n-1,:);
        locDrum = locDrum+1;
        
        % quantile
        AMax(locDrum,:) = quantile(Atmp, qmax);
        AMin(locDrum,:) = quantile(Atmp, qmin);
        
        % mean
        AMean(locDrum,:) = mean(Atmp);
        
        %count peaks 
        for j=1:n
            [pks,locsPeaks] = findpeaks(Atmp(j,:), 'MinPeakHeight', max(Atmp(j,:))/peakThresholdDenom);
            for k=1:length(locsPeaks)
                Peaks(locDrum,locsPeaks(k)) = Peaks(locDrum,locsPeaks(k))+1;                
            end
            %normalization - sum of all peaks should be 100
%             sumPeaks = sum(Peaks(locDrum,:));
%             peakFactor = 100/sumPeaks;
%             Peaks(locDrum,:)=Peaks(locDrum,:).*peakFactor;
        end
    end
end


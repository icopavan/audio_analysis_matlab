function [FMin, FMax, FMean, Peaks] = createTemplate( file_in, n, peakThresholdDenom )
%CREATETEMPLATE Summary of this function goes here
% Author - Katrin Hewer
% creation date - 20014-11-08

    %% define variables
    if nargin < 3
       peakThresholdDenom = 5; 
    end
    
    % read file
    F = csvread(file_in);
    % get size    
    sizeF = size(F);
       
    %% normalisation
    for i=1:sizeF(1)
       F(i,2:sizeF(2))=F(i,2:sizeF(2))./mean(F(i,2:sizeF(2))); 
    end
    
    
    %% templating
    FMin = zeros(sizeF(1)/n,sizeF(2));
    FMax = zeros(sizeF(1)/n,sizeF(2));
    FMean = zeros(sizeF(1)/n,sizeF(2));
    Peaks = zeros(sizeF(1)/n,sizeF(2));
    locDrum = 0;
    for i=1:n:sizeF(1)-n
        
        Ftmp = F(i:i+n,2:sizeF(2));
        drum = Ftmp(1,1);
        locDrum = locDrum+1;
        
        % quantile
        FMax(locDrum,1) = drum;
        FMin(locDrum,1) = drum;
        FMax(locDrum,2:sizeF(2)) = quantile(Ftmp, 0.99);
        FMin(locDrum,2:sizeF(2)) = quantile(Ftmp, 0.01);
        
        % mean
        FMean(locDrum,1) = drum;
        FMean(locDrum,2:sizeF(2)) = mean(Ftmp);
        
        %count peaks  
        Peaks(locDrum,1) = drum;
        for j=1:n
            [pks,locsPeaks] = findpeaks(Ftmp(j,:), 'MinPeakHeight', max(Ftmp(j,:))/peakThresholdDenom);
            for k=1:length(locsPeaks)
                Peaks(locDrum,locsPeaks(k)) = Peaks(locDrum,locsPeaks(k))+1;
            end
        end
    end
end


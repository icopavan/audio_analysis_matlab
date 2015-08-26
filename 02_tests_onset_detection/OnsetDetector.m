classdef OnsetDetector < handle
    %ONSETDETECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess=private)
        threshold;
        windowSize;
        lockSize;
        referenceFactor1;
        referenceFactor2;
        
        onsets;     % saves all onsets
        maxValues;  % array to push max values of the analysis
        minValues;  % array to push min values of the analysis
        
        pointer;    % pointer on frames array
        
        referenceSize;
        distance;
        lock;
    end
    
    methods
        function obj=OnsetDetector(threshold, windowSize, lockSize, referenceFactor1, referenceFactor2)
            if nargin < 5
                referenceFactor1 = 1;
            end
            if nargin < 4
                referenceFactor2 = 0.5;
            end
            if nargin < 3
                lockSize = 8;
            end
            if nargin < 2
                windowSize = 512;  %window size in samples
            end
            
            obj.threshold=threshold;
            obj.windowSize=windowSize;
            obj.lockSize=lockSize;
            obj.referenceFactor1=referenceFactor1;
            obj.referenceFactor2=referenceFactor2;
        end
        
        function start(obj, recordTime, fs)
            nFrames = ceil(recordTime/(obj.windowSize/fs));
            obj.maxValues = zeros(1,nFrames);            
            obj.minValues = zeros(1,nFrames); 
            obj.pointer = 0;
            
            obj.referenceSize = 1;
            obj.distance = 0;
            obj.lock = 0;
            
            obj.onsets = [];
        end
        
        function onset=detectOnset(obj,frame)
            %
            onset=0;
            
            %
            obj.pointer = obj.pointer+1;
            
            %
           [maxValue, maxIdx] = max(frame);
            obj.minValues(obj.pointer) = min(frame);
            obj.maxValues(obj.pointer) = maxValue;
            
            
            %detect onset
            if obj.pointer>obj.referenceSize+1 
              minReference = mean(obj.minValues(obj.pointer-obj.referenceSize-1:obj.pointer-1))*obj.referenceFactor1;
              maxReference = mean(obj.maxValues(obj.pointer-obj.referenceSize-1:obj.pointer-1))*obj.referenceFactor1;

              if (minReference > obj.threshold) minReference = -obj.threshold; end
              if (maxReference < obj.threshold) maxReference = obj.threshold; end  

              if (obj.minValues(obj.pointer) < minReference && obj.maxValues(obj.pointer) > maxReference && obj.lock == 0) 
                 onset = obj.pointer*obj.windowSize+maxIdx; 
                 obj.onsets = [obj.onsets, onset];
                 obj.referenceSize=1;
                 obj.distance=0;
                 obj.lock = obj.lockSize;
              else
                  obj.distance=obj.distance+1;
                  obj.referenceSize = ceil(obj.distance*obj.referenceFactor2);
              end
              if obj.lock > 0
                  obj.lock = obj.lock -1;
              end            
            end
            
        end
        
        function onsets=get.onsets(obj)
           onsets = obj.onsets; 
        end
        
    end
    
end


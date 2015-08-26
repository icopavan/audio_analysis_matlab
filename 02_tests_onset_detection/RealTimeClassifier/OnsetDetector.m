classdef OnsetDetector < handle
    %ONSETDETECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        windowSize;
        lockSize;
        referenceDenom;
        treshold;
        
        frames;     % array of recorded frames
        maxValues;  % array to push max values of the analysis
        minValues;  % array to push min values of the analysis
        pointer;    % pointer on frames array
        
        referenceSize;
        distance;
        lock;
    end
    
    methods
        function obj=OnsetDetector(windowSize, lockSize, referenceDenom, treshold)
            if nargin < 4
                treshold = 0.05;
            end
            if nargin < 3
                referenceDenom = 2.5;
            end
            if nargin < 2
                lockSize = 10;
            end
            
            obj.windowSize=windowSize;
            obj.lockSize=lockSize;
            obj.referenceDenom=referenceDenom;
            obj.treshold=treshold;
        end
        
        function prepareDetection(obj,recordTime, fs)
            nFrames=ceil(recordTime/(obj.windowSize/fs));
            obj.frames = zeros(obj.windowSize,nFrames);
            obj.maxValues = zeros(1,nFrames);            
            obj.minValues = zeros(1,nFrames); 
            obj.pointer = 0;
            
            obj.referenceSize = 1;
            obj.distance = 0;
            obj.lock = 0;
        end
        
        function onset=detectOnset(obj,frame)
            %
            onset=0;
            
            %
            obj.pointer = obj.pointer+1;
            obj.frames(:,obj.pointer)=frame;
            
            %
            obj.minValues(obj.pointer) = min(frame);
            obj.maxValues(obj.pointer) = max(frame);
            
            %detect onset
            if obj.pointer>obj.referenceSize 
                minReference = -obj.treshold;
                maxReference = obj.treshold;
                for i=1:obj.referenceSize
                    minReference = minReference + obj.minValues(obj.pointer-i);  
                    maxReference = maxReference + obj.maxValues(obj.pointer-i);  
                end
                minReference = minReference/obj.referenceSize;
                maxReference = maxReference/obj.referenceSize;

                if (obj.minValues(i) < minReference && obj.maxValues(i) > maxReference && obj.lock == 0) 
                   onset=1;
                   %obj.onsets = [obj.onsets, start+max_idx]; 
                   obj.referenceSize=1;
                   obj.distance=0;
                   obj.lock = obj.lockSize;
                else
                    obj.distance=obj.distance+1;
                    obj.referenceSize = ceil(obj.distance/obj.referenceDenom);
                end
                if obj.lock > 0
                    obj.lock = obj.lock -1;
                end             
            end
            
        end
    end
    
end


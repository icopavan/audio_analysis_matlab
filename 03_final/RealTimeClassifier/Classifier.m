classdef Classifier<handle
    %CLASSIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fs;       %sampling rate in Hz
        bitrate;  %sampling resolution in bit
        windowSize;
    end
    
    methods
        function obj=Classifier(windowSize, fs, bitrate)           
            if nargin < 3
                bitrate = 16;
            end
            if nargin < 2
                fs = 44100;
            end
            if nargin < 1
                windowSize = 2048;
            end
            obj.windowSize = windowSize;
            obj.fs = fs;
            obj.bitrate = bitrate;
        end
        function drum=getDrum(obj)
            y=obj.record();
            drum=obj.classify(y);
        end
    end
    
    methods(Access=private)
        function y=record(obj)
           t=obj.windowSize/obj.fs;
           recObj = audiorecorder(obj.fs,16,1);  
           recordblocking(recObj, t);    
           y = getaudiodata(recObj);
           y = y(1:obj.windowSize);
        end
        function drum=classify(obj,y)
           drum='drum';
        end
       
    end
    
end


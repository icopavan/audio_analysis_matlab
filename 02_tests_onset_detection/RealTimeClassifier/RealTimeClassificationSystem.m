classdef RealTimeClassificationSystem
    %ONSETDETECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
      fs;       %sampling rate in Hz
      bitrate;  %sampling resolution in bit
      windowSize;
      onsetDetector;
      classifier;
    end
    
    methods
        function obj=RealTimeClassificationSystem(onsetDetector, classifier, windowSize, fs, bitrate)            
            if nargin < 5
                bitrate = 16;
            end
            if nargin < 4
                fs = 44100;
            end
            if nargin < 3
                windowSize = 256;
            end
            if nargin < 2
                classifier=Classifier();
            end
            if nargin < 1
                onsetDetector=OnsetDetector(windowSize);
            end
            obj.onsetDetector=onsetDetector;
            obj.classifier = classifier;
            obj.windowSize=windowSize;
            obj.fs = fs;
            obj.bitrate = bitrate;            
        end
            
        function startStream(obj, recordTime)  
            obj.onsetDetector.prepareDetection(recordTime,obj.fs);
            mic = dsp.AudioRecorder('SamplesPerFrame',obj.windowSize,'NumChannels',1);
            
            %stream processing loop
            tic;
            while toc < recordTime
               %read frame from mic
               frame=step(mic);
               %view audio spectrum
               onset=obj.onsetDetector.detectOnset(frame);
               if onset>0
                fprintf('onset')                
                % classify 
                %job=createJob(obj.classifier.getDrum(y));
                myCluster = parcluster;
                job = createJob(myCluster);
                task = createTask(job, @obj.classifier.getDrum, 1, {});
                task.FinishedFcn = @getDrumCallback;
                submit(job);
                %wait(job);
                %delete(job);
               else
                fprintf('.')
               end
            end
            
            % terminate            
            release(mic);
            %clear obj.frames
            clear obj.onsetDetector;
            
        end  
        
        function getDrumCallback(task, ~)
            'callback'
        end
    end
    
end


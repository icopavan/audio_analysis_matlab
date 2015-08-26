function FeatureExtractor(action)
    %%Drum Sound FeatureExtractor - FeatureExtractor
    %   Fourier Transform with frame function on splitted microphone line in
    %   signals in real time

    %   Author: K. Hewer
    %   contact: katrinh1987@web.de
    %   created: 25/3/14
    %   last modified: 25/3/14

    %   contains source code from 
    %       The MathWorks, Inc. SIGDEMO1 Interactive DFT of a signal
    %       Martin Werner - Digitale Signalverarbeitung mit MATLAB® - 5. durchgesehene und aktualisierte Auflage - Programmbeispiel 6-1 Audiosignal, DFT-Spektrum und Spektrogramm

    %   possible actions:
    %     'start'
    %     'setWindowSize'
    %     'setOverlapLength'
    %     'getFiles'
    %     'setDir'
    %     'close'

    if nargin<1,
        action='start';
    end;

    global FeatureExtractor_DAT

    if strcmp(action,'start'), 

        %========================================
        % initialize default values

        % onset detection
        % FeatureExtractor_DAT.onset_frame_size = 128;
        % FeatureExtractor_DAT.onset_lock_size = 10;
        % FeatureExtractor_DAT.onset_reference_denominator = 2.5;

        % feature extraction
        FeatureExtractor_DAT.frame_size = 1024;
        FeatureExtractor_DAT.onset_delay = 0;
        FeatureExtractor_DAT.FileNames =[];
        FeatureExtractor_DAT.filesPath = '\';
        FeatureExtractor_DAT.dir = '';
        FeatureExtractor_DAT.plot_count = 1;

        %====================================
        % Graphics

        scnsize = get(0,'ScreenSize');
        figWdt = 200;

        FIG1 = figure(1);
        set(FIG1, 'Position', [40 80 figWdt scnsize(4)-160]);

        %====================================
        % Information for all buttons
        top=0.95;
        bottom=0.05;
        left=0.05;
        labelWid=0.9;
        labelHt=0.025;
        btnWid=0.9;
        btnHt=0.04;
        %Spacing between the label and the button for the same command
        btnOffset=0.003;
        %Spacing between the button and the next command's label
        spacing=0.03;

        %====================================
        %The CONSOLE frame
        frmBorder=0.02;
        yPos=0.05-frmBorder;
        frmPos=[left-frmBorder yPos btnWid+2*frmBorder 0.9+2*frmBorder];
        uicontrol( ...
            'Style','frame', ...
            'Units','normalized', ...
            'Position',frmPos);    

        %====================================
        %sampling rate popup button  
        elTop=0;  
        yLabelPos=top-elTop*(btnHt+labelHt+spacing);

        %Generic label information
        uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position',[left yLabelPos-labelHt labelWid labelHt], ...
            'HorizontalAlignment','left', ...
            'String','Frame size');

        %Generic popup button information
        frame_size_dropdown = uicontrol( ...
            'Style','popup', ...
            'Units','normalized', ...
            'Position',[left yLabelPos-labelHt-btnHt-btnOffset btnWid btnHt], ...
            'String',' 8| 16| 32| 64| 128| 256| 512| 1024| 2048| 4096| 8192', ...
            'Value',8, ...
            'Callback','FeatureExtractor(''setWindowSize'')');

      %====================================
        %record Time editable text box
        elTop=elTop+1;   
        yLabelPos=top-elTop*(btnHt+labelHt+spacing);

        %Generic label information
        uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position',[left yLabelPos-labelHt labelWid labelHt], ...
            'HorizontalAlignment','left', ...
            'String','Onset delay');

        %Generic popup button information
        onset_delay_dropdown = uicontrol( ...
            'Style','popup', ...
            'Units','normalized', ...
            'Position',[left yLabelPos-labelHt-btnHt-btnOffset btnWid btnHt], ...
            'String',' 0| 8| 16| 32| 64| 128| 256| 512| 1024| 2048| 4096| 8192', ...
            'Value',1, ...
            'Callback','FeatureExtractor(''setOnsetDelay'')');
        
        %====================================
        %set directory
        elTop=elTop+1;  
        yLabelPos=top-(elTop)*(btnHt+labelHt+spacing);

        %Button
        uicontrol( ...
            'Style','push', ...
            'Units','normalized', ...
            'Position',[left yLabelPos-btnHt-btnOffset btnWid  btnHt], ...
            'String','Choose directory', ...
            'Callback','FeatureExtractor(''setDir'')');  

        %directory field
        elTop=elTop+0.5; 
        yLabelPos=top-(elTop)*(btnHt+labelHt+spacing);
        directory_field = uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position', [left yLabelPos-btnHt-btnOffset btnWid  btnHt], ...
            'HorizontalAlignment','left', ...
            'BackgroundColor','w',...
            'enable', 'off',...
            'String', ''); 
        
        %====================================
        %set file
        elTop=elTop+0.5;  
        yLabelPos=top-(elTop)*(btnHt+labelHt+spacing);

        %Button
        yLabelPos=top-(elTop)*(btnHt+labelHt+spacing);
        uicontrol( ...
            'Style','push', ...
            'Units','normalized', ...
            'Position',[left yLabelPos-btnHt-btnOffset btnWid  btnHt], ...
            'String','Select files', ...
            'Callback','FeatureExtractor(''getFiles'')');         
        
        %files
        elTop=elTop+0.5;
        yLabelPos=top-(elTop)*(btnHt+labelHt+spacing);
        files_field = uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position', [left yLabelPos-btnHt*10-btnOffset btnWid  btnHt*10], ...
            'HorizontalAlignment','left', ...
            'BackgroundColor','w',...
            'enable', 'off',...
            'String', '');

       %====================================
        %analyse button
        uicontrol( ...
            'Style','push', ...
            'Units','normalized', ...
            'Position',[left bottom+(2*labelHt)+spacing btnWid 2*labelHt], ...
            'String','Analyse', ...
            'Callback','FeatureExtractor(''analyse'')');    

        %========================================
        %The CLOSE button
        uicontrol('Style','Pushbutton', ...
            'Units','normalized',...
            'Position',[left bottom btnWid 2*labelHt], ...
            'Callback','FeatureExtractor(''close'')','String','Close');     

        %========================================
        %save fields global
        FeatureExtractor_DAT.onset_delay_dropdown = onset_delay_dropdown;
        FeatureExtractor_DAT.frame_size_dropdown = frame_size_dropdown; 
        FeatureExtractor_DAT.directory_field = directory_field;
        FeatureExtractor_DAT.files_field = files_field;


    elseif strcmp(action,'setWindowSize'),
        frame_size_dropdown = FeatureExtractor_DAT.frame_size_dropdown;
        values = get(frame_size_dropdown,'String');
        frame_size = values(get(frame_size_dropdown,'Value'),:);
        FeatureExtractor_DAT.frame_size = str2double(frame_size); 


    elseif strcmp(action,'setOnsetDelay'),
        onset_delay_dropdown = FeatureExtractor_DAT.onset_delay_dropdown;
        values = get(onset_delay_dropdown,'String');
        onset_delay = values(get(onset_delay_dropdown,'Value'),:);
        FeatureExtractor_DAT.onset_delay = str2double(onset_delay);  

    elseif strcmp(action, 'setDir'),    
        dir = uigetdir;
        FeatureExtractor_DAT.dir = dir;
        set(FeatureExtractor_DAT.directory_field, 'String', dir);
        
    elseif strcmp(action,'getFiles'),
        
        [FileNames,filesPath,FilterIndex] = uigetfile({ ...
            '*.wav'}, ...
            FeatureExtractor_DAT.filesPath, ...
            'MultiSelect','on');       
          
        if isequal(FileNames,0); 
            return; 
        end
        
        FeatureExtractor_DAT.FileNames = FileNames;
        FeatureExtractor_DAT.filesPath = filesPath;
        set(FeatureExtractor_DAT.files_field, 'String', FileNames);
       
        
    elseif strcmp(action,'analyse'),    
        %------------------------------------------ 
        %get variables
        frame_size = FeatureExtractor_DAT.frame_size;
        onset_delay = FeatureExtractor_DAT.onset_delay  
        FileNames = FeatureExtractor_DAT.FileNames;
        filesPath = FeatureExtractor_DAT.filesPath; 
        dir = FeatureExtractor_DAT.dir;       
        
        if isequal(FileNames,0); 
            return; 
        end           
          
        Features = {};
        plot_count = FeatureExtractor_DAT.plot_count;
        numfiles = size(FileNames,2);   
        
        for ii = 1:numfiles  
            
            %------------------------------------------
            %read audio file 
            audiofile = fullfile(filesPath,FileNames{ii});
            [y,fs] = audioread(audiofile);                   % read audio signal   

            
            %------------------------------------------ 
            % create strings
            FilenameParts = strsplit(FileNames{ii},'.');
            filename = strrep(char(FilenameParts(1)),' - Kopie','');
            newFileName = strcat(filename,'_',num2str(frame_size),'_',num2str(onset_delay));   
            newFilePath = strcat(dir, '\','audio_analysis','\',num2str(fs),'_',num2str(frame_size),'_',num2str(onset_delay));   
            
            tmp_headline = strrep(filename,'play_','play ');
            tmp_headline = strrep(tmp_headline,'_snare_on',' (snare on)#');
            tmp_headline = strrep(tmp_headline,'_snare_off',' (snare off)#');
            tmp_headline = strrep(tmp_headline,'_',', ');
            tmp_headline = strsplit(tmp_headline,'#');
            headline1 = char(tmp_headline(1));
            headline2 = strcat(headline1,{', frame size: '},num2str(frame_size));  
            %headline = strcat(tmp_headline,{', '},num2str(frame_size),{', '},num2str(onset_delay))            
            drums = strsplit(filename,'_');
            
            drum_string_elements = strrep(drums(:,2:size(drums, 2)-3),'_',', ');            
            drum_string = '';
            size_drum_string_elements = size(drum_string_elements);
            for j = 1:size_drum_string_elements(2)
                drum_string = strcat(drum_string, drum_string_elements(j), {' '});
            end
            
            %------------------------------------------ 
            %create folder    
            mkdir(strcat(dir, '\','audio_analysis'));
            mkdir(newFilePath);
            

            %------------------------------------------
            % detect onsets

            % function DetectOnsets(y, frame_size, lock_size, reference_denominator)
            % default values: no default, 128, 10, 2.5
            onsets = DetectOnsets(y);
            %onsets = DetectOnsets(y, 128, 3, 2.5);
            %onsets = DetectOnsets(y, 64, 8, 1.6);


            %------------------------------------------
            %get features
           % [F, size_P, Max_peaks, Max_peaks_per_interval, Mean_peak, Frames, A, rms_ges, rms_i1, rms_i2, rms_rate_i1, rms_rate_i2, Peaks_frames, peak_shift_c2, peak_shift_c3, Mean_Peaks_frames, mean_peak_shift_c2, mean_peak_shift_c3, mean_peak_shift_delta, s] = GetFeatures(y, onsets(1)+onset_delay, frame_size);

            %------------------------------------------
            %add features to feature matrix  

           % NewFeatures = { char(drum_string), Max_peaks(1,1), Max_peaks(1,2), Max_peaks(1,3), Max_peaks(2,1), Max_peaks(2,3), Max_peaks(3,1), Max_peaks(3,3), Max_peaks_per_interval(1,1), Max_peaks_per_interval(1,2), Max_peaks_per_interval(1,3), Max_peaks_per_interval(1,4), Max_peaks_per_interval(1,5), Max_peaks_per_interval(1,6), Max_peaks_per_interval(1,7), Max_peaks_per_interval(1,8), Max_peaks_per_interval(1,9), Max_peaks_per_interval(1,10), Mean_peak(1), Mean_peak(2), size_P, rms_rate_i1, rms_rate_i2, Peaks_frames(1,1), Peaks_frames(1,3), Peaks_frames(2,1), Peaks_frames(2,3), Peaks_frames(3,1), Peaks_frames(3,3), peak_shift_c2(1), peak_shift_c2(2), peak_shift_c3(1), peak_shift_c3(2), Mean_Peaks_frames(1,1), Mean_Peaks_frames(1,3), Mean_Peaks_frames(2,1), Mean_Peaks_frames(2,3), Mean_Peaks_frames(3,1), Mean_Peaks_frames(3,3), mean_peak_shift_c2(1), mean_peak_shift_c2(2), mean_peak_shift_c3(1), mean_peak_shift_c3(2), mean_peak_shift_delta(1), mean_peak_shift_delta(2), s};
           % Features = [Features; NewFeatures];
            
            
            %------------------------------------------
            %plot            
            F =[];
            plot_count = plot_count + 1;
            [ h1, h2, h3 ] = DrawFft( plot_count, y, fs, F, onsets(1)+onset_delay, frame_size, headline1 );            
            plot_count = plot_count + 3;
            %h4 = DrawOnset( plot_count, y, fs, onsets(1)+onset_delay, frame_size, headline2);  
            plot_count = plot_count + 1;
            %h5 = DrawFrames2( plot_count, fs, F, Max_peaks(1,1:2), Max_peaks(2,1:2), Max_peaks(3,1:2), rms_ges, rms_i1, rms_i2, Frames, Peaks_Frames(1,1:2), Peaks_Frames(2,1:2), Peaks_Frames(3,1:2), frame_size, headline2 );
            h5 = DrawFrames( plot_count, fs, Frames, headline2 );

            %------------------------------------------
            FeatureExtractor_DAT.plot_count = plot_count;
            
            %------------------------------------------
            %save figures            
            saveas(h1,strcat(newFilePath,'\',newFileName,'_plot_01.pdf'));
            saveas(h1,strcat(newFilePath,'\',newFileName,'_plot_01.png'));
            saveas(h2,strcat(newFilePath,'\',newFileName,'_plot_02.pdf'));
            saveas(h2,strcat(newFilePath,'\',newFileName,'_plot_02.png'));
            saveas(h3,strcat(newFilePath,'\',newFileName,'_plot_03.pdf'));
            saveas(h3,strcat(newFilePath,'\',newFileName,'_plot_03.png'));
            %saveas(h4,strcat(newFilePath,'\',newFileName,'_plot_04.pdf'));
            %saveas(h4,strcat(newFilePath,'\',newFileName,'_plot_04.png'));
            saveas(h5,strcat(newFilePath,'\',newFileName,'_plot_05.pdf'));
            saveas(h5,strcat(newFilePath,'\',newFileName,'_plot_05.png'));
            
            %------------------------------------------
            %close figures
            
            close(figure(h1));
            close(figure(h2));
            close(figure(h3));
           % close(figure(h4));
            close(figure(h5));
        end 
        
        datafile = fopen(strcat(newFilePath,'\00_features.txt'),'at');
        
        

        formatSpec = '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n';        
        
        FeatureNames = {'drums', 'peak 1 (frequency)', 'peak 1 (amplitude)', 'peak 1 (amplitude in %)', 'peak 2 (frequency)', 'peak 2 (amplitude in %)', 'peak 3 (frequency)', 'peak 3 (amplitude in %)', 'max peak i1', 'max peak i2', 'max peak i3', 'max peak i4', 'max peak i5', 'max peak i6', 'max peak i7', 'max peak i8', 'max peak i9', 'max peak i10', 'mean_peak_frequency', 'mean_peak_amplitude', 'number of peaks', 'rms rate i1', 'rms rate i2', 'peak frame 1 (frequency)', 'peak frame 1 (amplitude in %)', 'peak frame 2 (frequency)', 'peak frame 2 (amplitude in %)', 'peak frame 3 (frequency)', 'peak frame 3 (amplitude in %)', 'peak_shift frame 1-2 (frequency)', 'peak_shift frame 1-2 (amplitude in %)', 'peak_shift frame 2-3 (frequency)', 'peak_shift frame 2-3 (amplitude in %)', 'mean peaks frame 1 (frequency)', 'mean peaks frame 1 (amplitude in %)', 'mean peaks frame 2 (frequency)', 'mean peaks frame 2 (amplitude in %)', 'mean peaks frame 3 (frequency)', 'mean peaks frame 3 (amplitude in %)', 'mean peak shift frames 1-2 (frequency)', 'mean peak shift frames 1-2 (amplitude in %)', 'mean peak shift frames 2-3 (frequency)', 'mean peak shift frames 2-3 (amplitude in %)', 'mean peak shift delta (frequency)', 'mean peak shift delta (amplitude in %)', 'steadiness'};
        fprintf(datafile,formatSpec,FeatureNames{1,:});
        
        formatSpec = '%s\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\t%2.2f\n';
        [nrows,ncols] = size(Features);
        for row = 1:nrows
            fprintf(datafile,formatSpec,Features{row,:});
        end
        fclose(datafile);
        
    elseif strcmp(action,'close'),   
         for i = 1:FeatureExtractor_DAT.plot_count
            close(figure(i));
         end
        clear global FeatureExtractor_DAT; 
    end   
end
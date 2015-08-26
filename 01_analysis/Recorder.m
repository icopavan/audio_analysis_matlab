function Recorder(action, drum)
    %Drum Sound Analyser - Recorder
    %   Records drumsound audiofiles for further analysis and saves them to
    %   filesystem

    %   Author: K. Hewer
    %   contact: katrinh1987@web.de
    %   created: 25/3/14
    %   last modified: 25/3/14

    %   contains source code from 
    %       The MathWorks, Inc. SIGDEMO1 Interactive DFT of a signal

    %   possible actions:
    %     'start'
    %     'setFs'
    %     'setT'
    %     'setDrums'
    %     'setDir'
    %     'setFilename'
    %     'record'
    %     'close'

    if nargin<1,
        action='start';
    end;

    global Recorder_DAT

    if strcmp(action,'start'), 

        %========================================
        % initialize default values
        dir = '';
        fs = 44100;                          % sampling frequency in Hz
        t = 1;                               % length of one interval signal in sec / sampling rate in seconds
        drums.bass = false;
        drums.snare = false;
        drums.hihat = false;
        drums.hihat_open = false;
        drums.tom1 = false;
        drums.tom2 = false;
        drums.tom3 = false;
        drums.crash = false;
        drums.ride = false;  
        drums.snareon = false;    

        % save global variables
        Recorder_DAT.dir = dir;
        Recorder_DAT.fs = fs;
        Recorder_DAT.t = t;
        Recorder_DAT.drums = drums;

        %====================================
        % Graphics

        scnsize = get(0,'ScreenSize');
        figWdt = 200;

        FIG1 = figure(1);
        set(FIG1, 'Position', [40 80 figWdt scnsize(4)-160])

        %====================================
        % Information for all buttons
        top=0.95;
        bottom=0.05;
        left = 0.05;
        labelWid=0.9;
        labelHt=0.025;
        btnWid = 0.9;
        btnHt=0.04;
        % Spacing between the label and the button for the same command
        btnOffset=0.003;
        % Spacing between the button and the next command's label
        spacing=0.03;

        %====================================
        % The CONSOLE frame
        frmBorder=0.02;
        yPos=0.05-frmBorder;
        frmPos=[left-frmBorder yPos btnWid+2*frmBorder 0.9+2*frmBorder];
        uicontrol( ...
            'Style','frame', ...
            'Units','normalized', ...
            'Position',frmPos);

        %====================================
        % set directory
        elTop=0;  
        yLabelPos=top-(elTop)*(btnHt+labelHt+spacing);
        labelStr=' Directory';
        % Generic label information
        labelPos=[left yLabelPos-labelHt labelWid labelHt];
        uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position',labelPos, ...
            'HorizontalAlignment','left', ...
            'String',labelStr);

        % directory field
        directory_field = uicontrol( ...
            'Style','edit', ...
            'Units','normalized', ...
            'Position', [left yLabelPos-labelHt-btnHt-btnOffset btnWid  btnHt], ...
            'HorizontalAlignment','left', ...
            'BackgroundColor','w',...
            'enable', 'off',...
            'String', '');

        % Button
        elTop=elTop+0.5; 
        yLabelPos=top-(elTop)*(btnHt+labelHt+spacing);
        uicontrol( ...
            'Style','push', ...
            'Units','normalized', ...
            'Position',[left yLabelPos-labelHt-btnHt-btnOffset btnWid  btnHt], ...
            'String','choose', ...
            'Callback','Recorder(''setDir'')');   

        %====================================
        % sampling rate popup button
        elTop=elTop+1;    
        yLabelPos=top-(elTop)*(btnHt+labelHt+spacing);
        labelStr=' Sampling rate';
        popupStr= ' 8.000 hz| 22.000 hz| 44.100 hz';
        callbackStr= 'Recorder(''setFs'')'; 

        % Generic label information
        labelPos=[left yLabelPos-labelHt labelWid labelHt];
        uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position',labelPos, ...
            'HorizontalAlignment','left', ...
            'String',labelStr);

        % Generic popup button information
        btnPos=[left yLabelPos-labelHt-btnHt-btnOffset btnWid btnHt];
        fs_dropdown = uicontrol( ...
            'Style','popup', ...
            'Units','normalized', ...
            'Position',btnPos, ...
            'String',popupStr, ...
            'Value',3, ...
            'Callback',callbackStr);

      %====================================
        % record Time editable text box
        elTop=elTop+1;
        yLabelPos=top-(elTop)*(btnHt+labelHt+spacing);
        labelPos=[left yLabelPos-labelHt labelWid labelHt];
        uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position', labelPos, ...
            'HorizontalAlignment','left', ...
            'String','record time in sec');

        btnPos=[left  yLabelPos-labelHt-btnHt-btnOffset ...
                btnWid  btnHt];
        recordtime_field = uicontrol( ...
            'Style','edit', ...
            'Units','normalized', ...
            'Position', btnPos, ...
            'BackgroundColor','w',...
            'String', t,...
            'Callback','Recorder(''setT'')');


        %====================================
        % The BASS checkbox
        elTop=elTop+1;
        yLabelPos=top-(elTop)*(btnHt+labelHt+spacing);
        labelPos=[left+0.1 yLabelPos-labelHt 0.4 labelHt];
        uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position', labelPos, ...
            'HorizontalAlignment','left', ...
            'String','Bassdrum');

        boxPos=[left yLabelPos-labelHt 0.1 labelHt];
        uicontrol( ...
            'Style','checkbox', ...
            'Units','normalized', ...
            'Position', boxPos,...
            'Callback','Recorder(''setDrum'',''bass'')');

        %====================================
        % The SNARE checkbox
        elTop=elTop+0.25;
        yLabelPos=top-(elTop)*(btnHt+labelHt+spacing);
        labelPos=[left+0.1 yLabelPos-labelHt 0.4 labelHt];
        uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position', labelPos, ...
            'HorizontalAlignment','left', ...
            'String','Snaredrum');

        boxPos=[left yLabelPos-labelHt 0.1 labelHt];
        uicontrol( ...
            'Style','checkbox', ...
            'Units','normalized', ...
            'Position', boxPos,...
            'Callback','Recorder(''setDrum'',''snare'')');

        %====================================
        % The HIHAT checkbox
        elTop=elTop+0.25;
        yLabelPos=top-(elTop)*(btnHt+labelHt+spacing);
        labelPos=[left+0.1 yLabelPos-labelHt 0.4 labelHt];
        uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position', labelPos, ...
            'HorizontalAlignment','left', ...
            'String','Hihat');

        boxPos=[left yLabelPos-labelHt 0.1 labelHt];
        uicontrol( ...
            'Style','checkbox', ...
            'Units','normalized', ...
            'Position', boxPos,...
            'Callback','Recorder(''setDrum'',''hihat'')');

        %====================================
        % The HIHAT OPEN checkbox
        elTop=elTop+0.25;
        yLabelPos=top-(elTop)*(btnHt+labelHt+spacing);
        labelPos=[left+0.1 yLabelPos-labelHt 0.4 labelHt];
        uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position', labelPos, ...
            'HorizontalAlignment','left', ...
            'String','Hihat opened');

        boxPos=[left yLabelPos-labelHt 0.1 labelHt];
        uicontrol( ...
            'Style','checkbox', ...
            'Units','normalized', ...
            'Position', boxPos,...
            'Callback','Recorder(''setDrum'',''hihat_open'')');

        %====================================
        % The TOM1 checkbox
        elTop=elTop+0.25;
        yLabelPos=top-(elTop)*(btnHt+labelHt+spacing);
        labelPos=[left+0.1 yLabelPos-labelHt 0.4 labelHt];
        uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position', labelPos, ...
            'HorizontalAlignment','left', ...
            'String','Tom 1');

        boxPos=[left yLabelPos-labelHt 0.1 labelHt];
        uicontrol( ...
            'Style','checkbox', ...
            'Units','normalized', ...
            'Position', boxPos,...
            'Callback','Recorder(''setDrum'',''tom1'')');

        %====================================
        % The TOM2 checkbox
        elTop=elTop+0.25;
        yLabelPos=top-elTop*(btnHt+labelHt+spacing);
        labelPos=[left+0.1 yLabelPos-labelHt 0.4 labelHt];
        uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position', labelPos, ...
            'HorizontalAlignment','left', ...
            'String','Tom 2');

        boxPos=[left yLabelPos-labelHt 0.1 labelHt];
        uicontrol( ...
            'Style','checkbox', ...
            'Units','normalized', ...
            'Position', boxPos,...
            'Callback','Recorder(''setDrum'',''tom2'')');

        %====================================
        % The TOM3 checkbox
        elTop=elTop+0.25;
        yLabelPos=top-elTop*(btnHt+labelHt+spacing);
        labelPos=[left+0.1 yLabelPos-labelHt 0.4 labelHt];
        uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position', labelPos, ...
            'HorizontalAlignment','left', ...
            'String','Tom 3');

        boxPos=[left yLabelPos-labelHt 0.1 labelHt];
        uicontrol( ...
            'Style','checkbox', ...
            'Units','normalized', ...
            'Position', boxPos,...
            'Callback','Recorder(''setDrum'',''tom3'')');

        %====================================
        % The CRASH checkbox
        elTop=elTop+0.25;
        yLabelPos=top-elTop*(btnHt+labelHt+spacing);
        labelPos=[left+0.1 yLabelPos-labelHt 0.4 labelHt];
        uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position', labelPos, ...
            'HorizontalAlignment','left', ...
            'String','Crash Cymbal');

        boxPos=[left yLabelPos-labelHt 0.1 labelHt];
        uicontrol( ...
            'Style','checkbox', ...
            'Units','normalized', ...
            'Position', boxPos,...
            'Callback','Recorder(''setDrum'',''crash'')');

        %====================================
        % The RIDE checkbox
        elTop=elTop+0.25;
        yLabelPos=top-elTop*(btnHt+labelHt+spacing);
        labelPos=[left+0.1 yLabelPos-labelHt 0.4 labelHt];
        uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position', labelPos, ...
            'HorizontalAlignment','left', ...
            'String','Ride Cymbal');

        boxPos=[left yLabelPos-labelHt 0.1 labelHt];
        uicontrol( ...
            'Style','checkbox', ...
            'Units','normalized', ...
            'Position', boxPos,...
            'Callback','Recorder(''setDrum'',''ride'')');

        %====================================
        % The SNARE ON checkbox
        elTop=elTop+0.5;
        yLabelPos=top-elTop*(btnHt+labelHt+spacing);
        labelPos=[left+0.1 yLabelPos-labelHt 0.4 labelHt];
        uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position', labelPos, ...
            'HorizontalAlignment','left', ...
            'String','Snare on');

        boxPos=[left yLabelPos-labelHt 0.1 labelHt];
        uicontrol( ...
            'Style','checkbox', ...
            'Units','normalized', ...
            'Position', boxPos,...
            'Callback','Recorder(''setDrum'',''snareon'')');

       %====================================
       % The START button
        uicontrol( ...
            'Style','push', ...
            'Units','normalized', ...
            'Position',[left bottom+(2*labelHt)+spacing btnWid 2*labelHt], ...
            'String','Record', ...
            'Callback','Recorder(''record'')');    

        %========================================
        % The CLOSE button
        uicontrol('Style','Pushbutton', ...
            'Units','normalized',...
            'Position',[left bottom btnWid 2*labelHt], ......
            'String','Close',...
            'Callback','Recorder(''close'')');     

        %========================================
        % save fields global
        Recorder_DAT.directory_field = directory_field;
        Recorder_DAT.fs_dropdown = fs_dropdown;
        Recorder_DAT.recordtime_field = recordtime_field; 


    elseif strcmp(action,'setDrum'),
       play_drum = Recorder_DAT.drums.(drum);
       if play_drum
           play_drum = false;
       else
           play_drum = true;
       end
       Recorder_DAT.drums.(drum) = play_drum;
       Recorder_DAT.drums;

    elseif strcmp(action,'setT'),
        recordtime_field = Recorder_DAT.recordtime_field;
        Recorder_DAT.t = str2double(get(recordtime_field,'String'));

    elseif strcmp(action, 'setFs'),
        fs_dropdown = Recorder_DAT.fs_dropdown;
        fs = 41000;
        v = get(fs_dropdown,'Value');
        if (v==1),
            fs = 8000;
        elseif (v==2),
            fs = 22000;
        end;
        Recorder_DAT.fs = fs;

    elseif strcmp(action, 'setDir'),    
        dir = uigetdir;
        Recorder_DAT.dir = dir;
        set(Recorder_DAT.directory_field, 'String', dir);

    elseif strcmp(action,'setFilename'),   
        drums = Recorder_DAT.drums;
        filename = 'play';
        if drums.bass
            filename = strcat(filename,'_bass');
        end
        if drums.snare
            filename = strcat(filename,'_snare');
        end
        if drums.hihat
            filename = strcat(filename,'_hihat');
        end
        if drums.hihat_open
            filename = strcat(filename,'_hihat_open');
        end
        if drums.tom1
            filename = strcat(filename,'_tom1');
        end
        if drums.tom2
            filename = strcat(filename,'_tom2');
        end
        if drums.tom3
            filename = strcat(filename,'_tom3');
        end
        if drums.crash
            filename = strcat(filename,'_crash');
        end
        if drums.ride
            filename = strcat(filename,'_ride');
        end   
        if drums.snareon
            filename = strcat(filename,'_snare_on');
        else
            filename = strcat(filename,'_snare_off');
        end       

        filename = strcat(filename,'_',datestr(now,'HHMMSS'),'.wav');

        Recorder_DAT.filename = filename;

    elseif strcmp(action,'record'),    

        %------------------------------------------ 
        % set filename 
        Recorder('setFilename');


        %------------------------------------------ 
        % get variables
        fs = Recorder_DAT.fs;  
        t = Recorder_DAT.t;    
        dir = Recorder_DAT.dir;  
        filename = Recorder_DAT.filename;    


        %------------------------------------------ 
        %create folder    
        date = datestr(now,'yy_mm_dd');  
        mkdir(dir,'drum_analysis'); 
        mkdir(strcat(dir,'/','drum_analysis'),num2str(fs));
        mkdir(strcat(dir,'/','drum_analysis','/',num2str(fs)), date);
        mkdir(strcat(dir,'/','drum_analysis','/',num2str(fs),'/',date), 'wav');
        audiofile = strcat(dir,'/','drum_analysis','/',num2str(fs),'/',date,'/wav/',filename);  


        %------------------------------------------ 
        % record sound

        % prepare audio recording
        recObj = audiorecorder(fs,16,1); 

        % record and save wav file
        recordblocking(recObj, t);    
        sig = getaudiodata(recObj);  
        
        %------------------------------------------ 
        %create audio file
        audiowrite(audiofile, sig, fs);                % write audio signal   

        %------------------------------------------ 
        %play finished sound
        [y,fs] = audioread('metronom.wav'); 
        sound = audioplayer(y, fs);
        play(sound);

    elseif strcmp(action,'close'),    
        close(gcf);
        clear global Recorder_DAT; 
    end
end
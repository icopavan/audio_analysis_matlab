function TrainingSystem(action)
    %Drum Sound Analyser - Training
    %   ...

    %   Author: K. Hewer
    %   contact: katrinh1987@web.de
    %   created: 31/10/14
    %   last modified: 31/10/14

    %   possible actions:
    %     'start'
    %     'setDrum'
    %     'setDrumsetName'
    %     'record'
    %     'close'
    
    global TrainingSystem_DAT
    
    if nargin<1,
        action='start';
    end;
    
    if strcmp(action,'start'), 
        %% initialize default values
        
        TrainingSystem_DAT.drumsetName = 'default';
        TrainingSystem_DAT.fs = 44100;
        TrainingSystem_DAT.t = 5;
        TrainingSystem_DAT.drums = {'bass','snare','tom1','tom2','tom3','hihat_closed','hihat_opened','crash','ride','ridebell'};
        TrainingSystem_DAT.drum = '';
        
        
        %% create interface
        
        %% set dimension variables
        % window
        scnsize = get(0,'ScreenSize');

        h = figure(1);
        set(h, 'Position', [40 80 200 400])
        
        %buttons and labels
        top=0.95;
        bottom=0.05;
        left = 0.05;
        labelWid=0.9;
        labelHt=0.03;
        btnWid = 0.9;
        btnHt=0.07;
        btnOffset=0.02;
        spacing=0.05;
        
        %% CONSOLE frame
        frmBorder=0.02;
        yPos=0.05-frmBorder;
        frmPos=[left-frmBorder yPos btnWid+2*frmBorder 0.9+2*frmBorder];
        uicontrol( ...
            'Style','frame', ...
            'Units','normalized', ...
            'Position',frmPos);
        
        %% DIRECTORY
        elTop=0;  
        yLabelPos=top-(elTop)*(btnHt+labelHt+spacing);
        
        % label
        labelPos=[left yLabelPos-labelHt labelWid labelHt];
        uicontrol( ...
            'Style','text', ...
            'Units','normalized', ...
            'Position',labelPos, ...
            'HorizontalAlignment','left', ...
            'String','Drumset name:');
        
        % textfield
        TrainingSystem_DAT.drumsetNameField = uicontrol( ...
            'Style','edit', ...
            'Units','normalized', ...
            'Position', [left yLabelPos-labelHt-btnHt-btnOffset btnWid  btnHt], ...
            'HorizontalAlignment','left', ...
            'BackgroundColor','w',...
            'String', '', ...
            'Callback','TrainingSystem(''setDrumsetName'')');
                 
        %% DRUMS radiobuttons 
        ht = 0.4;
        yLabelPos=top-ht-0.15;
        pos=[left yLabelPos 0.9 ht];
        
        bg = uibuttongroup('visible','off','parent',h,'Units','normalized','Position',pos);
        
        cbHt = 1/length(TrainingSystem_DAT.drums);
        for i=1:length(TrainingSystem_DAT.drums)
            pos=[0 1-i*cbHt 1 cbHt];
            uicontrol('Style','radiobutton',...
                'Units','normalized',...
                'String',TrainingSystem_DAT.drums(i),...
                'Value',i,...
                'pos',pos,...
                'parent',bg);
        end
        set(bg,'SelectionChangeFcn',@setDrum);
        set(bg,'SelectedObject',[]);  % No selection
        set(bg,'Visible','on');
        
       %% START button
        uicontrol( ...
            'Style','push', ...
            'Units','normalized', ...
            'Position',[left bottom+(2*labelHt)+spacing btnWid btnHt], ...
            'String','Record', ...
            'Callback','TrainingSystem(''record'')');    

        %% CLOSE button
        uicontrol('Style','Pushbutton', ...
            'Units','normalized',...
            'Position',[left bottom btnWid btnHt], ......
            'String','Close',...
            'Callback','TrainingSystem(''close'')');  
    end
    
    if strcmp(action,'setDrumsetName'),  
        drumsetNameField = TrainingSystem_DAT.drumsetNameField;
        TrainingSystem_DAT.drumsetName = get(drumsetNameField,'String');
    end
    
    if strcmp(action,'record'), 
        %% get variables
        fs = TrainingSystem_DAT.fs;  
        t = TrainingSystem_DAT.t;    
        drumsetName = TrainingSystem_DAT.drumsetName;
        drumsetPath = strcat('drumsets/',drumsetName);
        drum = TrainingSystem_DAT.drum;
        
        mkdir('drumsets');
        mkdir(drumsetPath);
        
        %% record sound
        % prepare audio recording
        recObj = audiorecorder(fs,16,1); 

        % record and save wav file
        recordblocking(recObj, t);    
        y = getaudiodata(recObj);
        filename = strcat(drumsetPath,'\',drum,datestr(now,'_yymmdd_HHMMSS'),'.wav');
        audiowrite(char(filename), y, fs);
         
        %% write y to file
        %yFilePath = strcat(dir,'\y.csv');
        %dlmwrite('y.txt',y,'-append',...
        %'delimiter',' ','roffset',1);
        %type('y.txt')
        
        %% analyse data
        drum_idx = find(ismember(TrainingSystem_DAT.drums,TrainingSystem_DAT.drum));
        F = prepareTrainingData(y,drum_idx);
        
        % write y to file
        FFilePath = strcat(drumsetPath,'\F.csv');
        dlmwrite(char(FFilePath),F,'-append',...
            'delimiter',',','roffset',0);
        
    end
    
    if strcmp(action,'close'),    
        close(gcf);
        clear global TrainingSystem_DAT; 
    end
    
    function setDrum(source,eventdata)
        TrainingSystem_DAT.drum = get(eventdata.NewValue, 'String');        
    end
    
end
function audioanalysis(action)
%Audio Signal Analysis
%   Fourier Transform with window function on splitted microphone line in
%   signals in real time

%   Author: K. Hewer
%   contact: katrinh1987@web.de
%   created: 25/3/14
%   last modified: 25/3/14

%   contains source code from The MathWorks, Inc. SIGDEMO1 Interactive DFT of a signal

%   possible actions:
%       'start'
%       'close'
%       'setwindow'
%       'setrecordtime'
%       'setintervalize'
%       'setnumberofinterval'
%       'record'


if nargin<1,
    action='start';
end;

global AUDIOANALYSIS_DAT

if strcmp(action,'start'),

    %====================================
    % Graphics initialization
    oldFigNumber = watchon;
    figNumber = figure;
    set(figNumber, ...
        'NumberTitle','off', ...
        'Name','Discrete Fourier Transform', ...
        'Units','normalized');      
    
    %====================================
    % Information for all buttons
    labelColor=192/255*[1 1 1];
    top=0.95;
    bottom=0.05;
    yInitLabelPos=0.90;
    left = 0.78;
    labelWid=0.18;
    labelHt=0.05;
    btnWid = 0.18;
    btnHt=0.07;
    % Spacing between the label and the button for the same command
    btnOffset=0.003;
    % Spacing between the button and the next command's label
    spacing=0.05;
 
    %====================================
    % The CONSOLE frame
    frmBorder=0.02;
    yPos=0.05-frmBorder;
    frmPos=[left-frmBorder yPos btnWid+2*frmBorder 0.9+2*frmBorder];
    h=uicontrol( ...
        'Style','frame', ...
        'Units','normalized', ...
        'Position',frmPos);

    %====================================
    % The WINDOW command popup button
    btnNumber=1;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
    labelStr=' Window';
    popupStr= ' rectangle| triangular| hanning| hamming| chebyshev| kaiser';
    callbackStr= 'audioanalysis(''setwindow'')';

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
    winHndl = uicontrol( ...
        'Style','popup', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',popupStr, ...
        'Callback',callbackStr);

  %====================================
    % The Record TIME editable text box
    btnNumber=2;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
    labelPos=[left yLabelPos-labelHt labelWid labelHt];
    recordtime_text = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position', labelPos, ...
        'String','record time in sek');

    btnPos=[left+0.02  yLabelPos-labelHt-btnHt-btnOffset ...
            0.5*btnWid+frmBorder  btnHt];
    recordtime_field = uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position', btnPos, ...
        'BackgroundColor','w',...
        'String',' 5',...
        'Callback','audioanalysis(''setrecordtime'')');

  %====================================
    % The INTERVAL SIZE editable text box
    btnNumber=3;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
    labelPos=[left yLabelPos-labelHt labelWid labelHt];
    interval_text = uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position', labelPos, ...
        'String','interval size in sek');

    btnPos=[left+0.02  yLabelPos-labelHt-btnHt-btnOffset ...
            0.5*btnWid+frmBorder  btnHt];
    interval_field = uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position', btnPos, ...
        'BackgroundColor','w',...
        'String',' 1',...
        'Callback','audioanalysis(''setintervalsize'')');

   %====================================
    % The START button
    uicontrol( ...
        'Style','push', ...
        'Units','normalized', ...
        'Position',[left bottom+(2*labelHt)+spacing btnWid 2*labelHt], ...
        'String','Start', ...
        'Callback','audioanalysis(''record'')');    
    
    %========================================
    % The CLOSE button
    close_button=uicontrol('Style','Pushbutton', ...
        'Units','normalized',...
        'Position',[left bottom btnWid 2*labelHt], ...
        'Callback','audioanalysis(''close'')','String','Close');     
    
    %========================================
    % create initial values for plot
    Fs = 8000;                      % sampling frequency in Hz
    iT = 1;                         % length of one interval signal in sec / sampling rate in seconds
    rT = 5;                         % record time in sec
    t = 0:1/Fs:iT-1/Fs;             % time vector
    nfft = 2^nextpow2(Fs);          % n-point DFT
    numUniq = ceil((nfft+1)/2);     % half point
    f = (0:numUniq-1)'*Fs/nfft;     % frequency vector (one sided)
    
    min_dB = -40;                   % freq. domain lower axis limit    
    
    % prepare audio recording
    recObj = audiorecorder(Fs,8,1);
    
    % create axes for time domain and frequency domain plot
    ax_freq=axes('Position',[.12 .14 .6 .3],'XLim',...
             [0 1/(2*iT)],'YLim',[min_dB 50]);
    
    axis([0 1/(2*iT)  min_dB 50]);
    grid on;
    ylabel('Magnitude (dB)');
    xlabel('Frequency (Hertz)');

    ax_time=axes('Position',[.12 .58 .6 .3],'XLim',[0 iT],'YLim',[-1 1]);
    axis([0 iT -1 1]);
    grid on;
    ylabel('Waveform');
    xlabel('Time (Seconds)');
    
    watchoff(oldFigNumber);
    
    % save fields and variables global
    AUDIOANALYSIS_DAT.interval_field = interval_field;
    AUDIOANALYSIS_DAT.recordtime_field = recordtime_field;
    AUDIOANALYSIS_DAT.iT = iT;
    AUDIOANALYSIS_DAT.rT = rT;
    AUDIOANALYSIS_DAT.nfft = nfft;
    AUDIOANALYSIS_DAT.recObj = recObj; 
    

elseif strcmp(action,'setrecordtime'),
    fprintf('setrecordtime \n');
    recordtime_field = AUDIOANALYSIS_DAT.recordtime_field;
    AUDIOANALYSIS_DAT.rT = str2double(get(recordtime_field,'String')); 
    
    
elseif strcmp(action,'setintervalsize'),
    fprintf('setintervalsize \n');
    interval_field = AUDIOANALYSIS_DAT.interval_field;
    AUDIOANALYSIS_DAT.iT = str2double(get(interval_field,'String')); 
    
    
elseif strcmp(action,'record'),    
    
    % get variables
    recObj = AUDIOANALYSIS_DAT.recObj;
    iT = AUDIOANALYSIS_DAT.iT;
    rT = AUDIOANALYSIS_DAT.rT;
    nfft = AUDIOANALYSIS_DAT.nfft; 
    
    fprintf('start recording with iT = %d and rT = %d \n', iT, rT);
        
    %record rT
    recordblocking(recObj, rT);
    sig = getaudiodata(recObj);
    audiowrite('test.wav', sig, 8000);
    
    %for i=1:rT/iT
    %    fprintf(' . ');  
    %    recordblocking(recObj, iT);
    %
    %    audioanalysis('redraw');
    %end  
    
    fprintf('\n recording finished \n');

elseif strcmp(action,'redraw'),
    fprintf('redraw');
    
elseif strcmp(action,'setwindow'),
    % u = get(gcf,'userdata');
    winHndl = ADDIT_DAT;
    in1 = get(winHndl,'Value');
    in2 = 30;
    N=AUDIOANALYSIS_DAT{3};

    if (in1==1),
        window = boxcar(N);
    elseif (in1==2),
        window = triang(N);
    elseif (in1==3),
        window = hanning(N);
    elseif (in1==4),
        window = hamming(N);
    elseif (in1==5),
        window = chebwin(N,30);
    elseif (in1==6),
        window = kaiser(N,4);
    end;

    AUDIOANALYSIS_DAT{15}=window;
    % set(gcf,'userdata',u);
    audioanalysis('redraw');
    if (AUDIOANALYSIS_DAT{12}~=-1),
        audioanalysis('showwind');
    end;
    
elseif strcmp(action,'close'),
    
    close(gcf);
    clear global AUDIOANALYSIS_DAT; 
    
end


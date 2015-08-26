function audioanalysis2(action,drum)
%Audio Signal Analysis
%   Fourier Transform with window function on splitted microphone line in
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
%     'close'
%     'setwindow'
%     'setrecordtime'
%     'setfftlength'
%     'setoverlaplength'
%     'setdrum'

if nargin<1,
    action='start';
end;

global audioanalysis2_DAT

if strcmp(action,'start'), 
    
    %========================================
    % initialize default values
    Fs = 8000;                          % sampling frequency in Hz
    T = 1;                              % length of one interval signal in sec / sampling rate in seconds
    fft_length = 512;                      
    window = hamming(fft_length);          
    window_string = 'hamming';
    overlap = 0.5;                        % overlap of the fft blocks, default 50%
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
    
    % prepare audio recording
    recObj = audiorecorder(Fs,8,1);   
    
    % save global variables
    audioanalysis2_DAT.T = T;
    audioanalysis2_DAT.fft_length = fft_length;
    audioanalysis2_DAT.window = window;
    audioanalysis2_DAT.window_string = window_string;
    audioanalysis2_DAT.overlap = overlap;
    audioanalysis2_DAT.recObj = recObj;
    audioanalysis2_DAT.drums = drums;
    
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
    btnHt=0.06;
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
    % The WINDOW command popup button
    btnNumber=1;    
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
    labelStr=' Window';
    popupStr= ' rectangle| triangular| hanning| hamming| chebyshev| kaiser';
    callbackStr= 'audioanalysis2(''setwindow'')';

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
    window_dropdown = uicontrol( ...
        'Style','popup', ...
        'Units','normalized', ...
        'Position',btnPos, ...
        'String',popupStr, ...
        'Value',4, ...
        'Callback',callbackStr);

  %====================================
    % The Record TIME editable text box
    btnNumber=2;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
    labelPos=[left yLabelPos-labelHt labelWid labelHt];
    uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position', labelPos, ...
        'HorizontalAlignment','left', ...
        'String','record time in sek');

    btnPos=[left  yLabelPos-labelHt-btnHt-btnOffset ...
            btnWid  btnHt];
    recordtime_field = uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position', btnPos, ...
        'BackgroundColor','w',...
        'String', T,...
        'Callback','audioanalysis2(''setrecordtime'')');

  %====================================
    % The FFT LENGTH editable text box
    btnNumber=3;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
    labelPos=[left yLabelPos-labelHt labelWid labelHt];
    uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position', labelPos, ...
        'HorizontalAlignment','left', ...
        'String','FFT length');

    btnPos=[left  yLabelPos-labelHt-btnHt-btnOffset ...
            btnWid  btnHt];
    fftlength_field = uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position', btnPos, ...
        'BackgroundColor','w',...
        'String', fft_length,...
        'Callback','audioanalysis2(''setfftlength'')');

  %====================================
    % The OVERLAP editable text box
    btnNumber=4;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
    labelPos=[left yLabelPos-labelHt labelWid labelHt];
    uicontrol( ...
        'Style','text', ...
        'Units','normalized', ...
        'Position', labelPos, ...
        'HorizontalAlignment','left', ...
        'String','Overlap length');

    btnPos=[left  yLabelPos-labelHt-btnHt-btnOffset ...
            btnWid  btnHt];
    overlaplength_field = uicontrol( ...
        'Style','edit', ...
        'Units','normalized', ...
        'Position', btnPos, ...
        'BackgroundColor','w',...
        'String', overlap,...
        'Callback','audioanalysis2(''setoverlaplength'')');
    
    %====================================
    % The BASS checkbox
    btnNumber=5;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
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
        'Callback','audioanalysis2(''setdrum'',''bass'')');
    
    %====================================
    % The SNARE checkbox
    btnNumber=5.25;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
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
        'Callback','audioanalysis2(''setdrum'',''snare'')');
    
    %====================================
    % The HIHAT checkbox
    btnNumber=5.5;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
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
        'Callback','audioanalysis2(''setdrum'',''hihat'')');
    
    %====================================
    % The HIHAT OPEN checkbox
    btnNumber=5.75;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
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
        'Callback','audioanalysis2(''setdrum'',''hihat_open'')');
    
    %====================================
    % The TOM1 checkbox
    btnNumber=6;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
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
        'Callback','audioanalysis2(''setdrum'',''tom1'')');
    
    %====================================
    % The TOM2 checkbox
    btnNumber=6.25;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
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
        'Callback','audioanalysis2(''setdrum'',''tom2'')');
    
    %====================================
    % The TOM3 checkbox
    btnNumber=6.5;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
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
        'Callback','audioanalysis2(''setdrum'',''tom3'')');
    
    %====================================
    % The CRASH checkbox
    btnNumber=6.75;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
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
        'Callback','audioanalysis2(''setdrum'',''crash'')');
    
    %====================================
    % The RIDE checkbox
    btnNumber=7;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
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
        'Callback','audioanalysis2(''setdrum'',''ride'')');
    
    %====================================
    % The SNARE ON checkbox
    btnNumber=7.35;
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
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
        'Callback','audioanalysis2(''setdrum'',''snareon'')');

   %====================================
    % The START button
    uicontrol( ...
        'Style','push', ...
        'Units','normalized', ...
        'Position',[left bottom+(2*labelHt)+spacing btnWid 2*labelHt], ...
        'String','Start', ...
        'Callback','audioanalysis2(''record'')');    
    
    %========================================
    % The CLOSE button
    uicontrol('Style','Pushbutton', ...
        'Units','normalized',...
        'Position',[left bottom btnWid 2*labelHt], ...
        'Callback','audioanalysis2(''close'')','String','Close');     
    
    %========================================
    % save fields global
    audioanalysis2_DAT.recordtime_field = recordtime_field; 
    audioanalysis2_DAT.fftlength_field = fftlength_field;
    audioanalysis2_DAT.overlaplength_field = overlaplength_field;
    audioanalysis2_DAT.window_dropdown = window_dropdown;
    

elseif strcmp(action,'setdrum'),
   play_drum = audioanalysis2_DAT.drums.(drum);
   if play_drum
       play_drum = false;
   else
       play_drum = true;
   end
   audioanalysis2_DAT.drums.(drum) = play_drum;  
    
elseif strcmp(action,'setrecordtime'),
    recordtime_field = audioanalysis2_DAT.recordtime_field;
    audioanalysis2_DAT.T = str2double(get(recordtime_field,'String')); 
    
    
elseif strcmp(action,'setfftlength'),
    fftlength_field = audioanalysis2_DAT.fftlength_field;
    audioanalysis2_DAT.fft_length = str2double(get(fftlength_field,'String')); 
    
    
elseif strcmp(action,'setoverlaplength'),
    overlaplength_field = audioanalysis2_DAT.overlaplength_field;
    audioanalysis2_DAT.overlap = str2double(get(overlaplength_field,'String')); 
    
    
elseif strcmp(action,'record'),       
    % get variables
    recObj = audioanalysis2_DAT.recObj;
    T = audioanalysis2_DAT.T;   
    
    fft_length = audioanalysis2_DAT.fft_length;             
    window = audioanalysis2_DAT.window;            
    overlap = audioanalysis2_DAT.overlap;
        
    % record and save wav file
    recordblocking(recObj, T);    
    sig = getaudiodata(recObj);
    
    %create file name
    window_string = audioanalysis2_DAT.window_string;
    drums = audioanalysis2_DAT.drums;
    drum_string = 'play';
    drum_string2 = '';
    if drums.bass
        drum_string = strcat(drum_string,'_bass');
        drum_string2 = strcat(drum_string2,' bass,');
    end
    if drums.snare
        drum_string = strcat(drum_string,'_snare');
        drum_string2 = strcat(drum_string2,' snare,');
    end
    if drums.hihat
        drum_string = strcat(drum_string,'_hihat');
        drum_string2 = strcat(drum_string2,' hihat,');
    end
    if drums.hihat_open
        drum_string = strcat(drum_string,'_hihat_open');
        drum_string2 = strcat(drum_string2,' hihat open,');
    end
    if drums.tom1
        drum_string = strcat(drum_string,'_tom1');
        drum_string2 = strcat(drum_string2,' tom 1,');
    end
    if drums.tom2
        drum_string = strcat(drum_string,'_tom2');
        drum_string2 = strcat(drum_string2,' tom 2,');
    end
    if drums.tom3
        drum_string = strcat(drum_string,'_tom3');
        drum_string2 = strcat(drum_string2,' tom 3,');
    end
    if drums.crash
        drum_string = strcat(drum_string,'_crash');
        drum_string2 = strcat(drum_string2,' crash,');
    end
    if drums.ride
        drum_string = strcat(drum_string,'_ride');
        drum_string2 = strcat(drum_string2,' ride,');
    end   
    if drums.snareon
        drum_string = strcat(drum_string,'_snare_on');
        drum_string2 = strcat(drum_string2,' snare on');
    else
        drum_string = strcat(drum_string,'_snare_off');
        drum_string2 = strcat(drum_string2,' snare off');
    end       
    date = datestr(now,'yy_mm_dd');
    time = datestr(now,'HHMMSS');    
    mkdir(date);
    mkdir(date,drum_string);
    filename = strcat(date,'/',drum_string,'/',time,'_',window_string,'_',num2str(fft_length),'_',num2str(overlap),'.wav');     
    audiowrite(filename, sig, 8000);                % write audio signal        
    [y,fs] = audioread(filename);                   % read audio signal     
    N = floor(length(y)/fft_length);
    Y = zeros(overlap*N,fft_length/2);              % reset        
    Y = fft(y);                                     % spectral analysis
    %YY = abs(Y)/max(abs(Y));
    f=0:length(y)-1;                                % frequency scale - scale from 0 to length(y)-1
    f=f*fs/length(y);    
    t = 0:length(y)-1;                              % time scale
    t = t/fs; 
    
    %------------------------------------------------
    
    %write peaks to file
    
    [pks,locs] = findpeaks(abs(Y), 'MinPeakHeight', max(abs(Y))/10);
    %M = sortrows([pks,f(locs)']);
    M = sortrows([pks,f(locs)']);
    %M(M(:,1)>4000,:)=[];
    M(M(:,2)>4000,:)=[];
    %M=M(1:100,:); %limit number of peaks
    csvwrite(strcat(date,'/',drum_string,'/',time,'_',window_string,'_',num2str(fft_length),'_',num2str(overlap),'.csv'), M);
    
    %------------------------------------------------
    % graphics    
    set(0,'Units','pixels') 
    scnsize = get(0,'ScreenSize');
    figWdt = 500; 
    
    %------------------------------------------------ 
    FIG2 = figure(2);    
    set(FIG2, 'Position', [260 80 figWdt scnsize(4)-160])    
    subplot(3,1,1), plot(t,y), grid;    
    title(drum_string2);
    xlabel('t [s] \rightarrow'), ylabel('y(t)  \rightarrow');      
    subplot(3,1,2), plot(f,abs(Y)), grid
    %axis([0 fs/2 0 1]);
    xlim([0,4000]);
    xlabel('f [Hz] \rightarrow'), ylabel('|Y(f) \rightarrow|');    
    subplot(3,1,3), plot(f,abs(Y)), grid
    %axis([0 fs/2 0 1]);
    xlim([0,500]);
    xlabel('f [Hz] \rightarrow'), ylabel('|Y(f) \rightarrow|');    
    
    %------------------------------------------------    
    % short term spectral analysis  
    NY = floor(length(y)/(fft_length*(1-overlap))); % number of dft spectra
    MY = fft_length/2;                              % number of dft coeffizients per dft spectrum
    Y = zeros(NY,MY);
    start = 1; 
    stop = start + fft_length - 1; 
    k = 0;
    
    while stop<=length(y)
        k = k + 1;
        YY = fft(window.*y(start:stop))';
        Y(k,:) = abs(YY(1:MY));
        start = start + fft_length*(1-overlap);
        stop = start + fft_length - 1;
    end
    
    % graphics
    FIG3 = figure(3);    
    %Y = Y/max(max(Y));
    t = 1:NY;                                       % time scale
    t = t*(fft_length*(1-overlap))/fs;    
    f = 0:1:MY-1;                                   % frequency scale    
    f = fs*f/fft_length;         
    waterfall(f,t,Y);
   	shading interp;
    view(40,40);
    xlabel(' f [Hz] \rightarrow'), ylabel(' t [s] \rightarrow')
    zlabel('magnitudes of short term dft spectra \rightarrow')
    title(['play ',drum_string2,' - ',window_string,' window, fft length ',num2str(fft_length),', overlap length ',num2str(overlap)]);
    
    %------------------------------------------------    
    FIG4 = figure(4);      
    i = length(find(f <= 500));                     % shorten array
    Y = Y(:,1:i);
    f = f(1:i);    
    waterfall(f,t,Y);
    view(40,40);
    xlabel(' f [Hz] \rightarrow'), ylabel(' t [s] \rightarrow')
    zlabel('magnitudes of short term dft spectra \rightarrow')
    title(['play ',drum_string2,' - ',window_string,' window, fft length ',num2str(fft_length),', overlap length ',num2str(overlap)]);
    xlim([0,500]); 
    
    %------------------------------------------
    % MATLAB built-in spectrogram
    FIG5 = figure(5);    
    spectrogram(y,window,fft_length/2,0:20:4000,fs,'yaxis');
    %specgram(y,fft_length,fs,hamming(fft_length),fft_length/overlap);
    title(['play ',drum_string2,' - ',window_string,' window, fft length ',num2str(fft_length),', overlap length ',num2str(overlap)]);
    
    %------------------------------------------------
    FIG6 = figure(6);
    spectrogram(y,window,fft_length/2,0:20:500,fs,'yaxis');
    title(['play ',drum_string2,' - ',window_string,' window, fft length ',num2str(fft_length),', overlap length ',num2str(overlap)]);       
    
    %------------------------------------------
    %save figures
    saveas(FIG2,strcat(date,'/',drum_string,'/',time,'_',window_string,'_',num2str(fft_length),'_',num2str(overlap),'_plot_01.png'));
    saveas(FIG3,strcat(date,'/',drum_string,'/',time,'_',window_string,'_',num2str(fft_length),'_',num2str(overlap),'_plot_02.png'));
    saveas(FIG4,strcat(date,'/',drum_string,'/',time,'_',window_string,'_',num2str(fft_length),'_',num2str(overlap),'_plot_03.png'));
    saveas(FIG5,strcat(date,'/',drum_string,'/',time,'_',window_string,'_',num2str(fft_length),'_',num2str(overlap),'_plot_04.png'));
    saveas(FIG6,strcat(date,'/',drum_string,'/',time,'_',window_string,'_',num2str(fft_length),'_',num2str(overlap),'_plot_05.png'));

elseif strcmp(action,'redraw'),
    fprintf('redraw');
    
elseif strcmp(action,'setwindow'),
    fft_length = audioanalysis2_DAT.fft_length;    
    window_dropdown = audioanalysis2_DAT.window_dropdown;    
    window_string = '';    
    v = get(window_dropdown,'Value');
    if (v==1),
        window = boxcar(fft_length);
        window_string = 'boxcar';
    elseif (v==2),
        window = triang(fft_length);
        window_string = 'triang';
    elseif (v==3),
        window = hanning(fft_length);
        window_string = 'hanning';
    elseif (v==4),
        window = hamming(fft_length);
        window_string = 'hamming';
    elseif (v==5),
        window = chebwin(fft_length,30);
        window_string = 'chebwin';
    elseif (v==6),
        window = kaiser(fft_length,4);
        window_string = 'kaiser';
    end;
    audioanalysis2_DAT.window=window;
    audioanalysis2_DAT.window_string=window_string;
    
elseif strcmp(action,'close'),    
    close(figure(2));
    close(figure(3));
    close(figure(4));
    close(figure(5));
    close(figure(6));
    close(gcf);
    clear global audioanalysis2_DAT; 
    
end
function audioanalysis3(action,drum)
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

global audioanalysis3_DAT

if strcmp(action,'start'), 
    
    %========================================
    % initialize default values
    Fs = 44100;                          % sampling frequency in Hz
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
    
    % save global variables
    audioanalysis3_DAT.T = T;
    audioanalysis3_DAT.fft_length = fft_length;
    audioanalysis3_DAT.window = window;
    audioanalysis3_DAT.window_string = window_string;
    audioanalysis3_DAT.overlap = overlap;
    audioanalysis3_DAT.drums = drums;
    
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
    % set window popup button
    btnNumber=1;    
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
    labelStr=' Window';
    popupStr= ' rectangle| triangular| hanning| hamming| chebyshev| kaiser';
    callbackStr= 'audioanalysis3(''setwindow'')';

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
    % sampling rate popup button
    btnNumber=2;    
    yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
    labelStr=' Sampling rate';
    popupStr= ' 8.000 hz| 22.000 hz| 44.100 hz';
    callbackStr= 'audioanalysis3(''setFs'')'; 

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
    btnNumber=3;
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
        'Callback','audioanalysis3(''setrecordtime'')');

  %====================================
    % The FFT LENGTH editable text box
    btnNumber=4;
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
        'Callback','audioanalysis3(''setfftlength'')');

  %====================================
    % The OVERLAP editable text box
    btnNumber=5;
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
        'Callback','audioanalysis3(''setoverlaplength'')');
    
    %====================================
    % The BASS checkbox
    btnNumber=6;
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
        'Callback','audioanalysis3(''setdrum'',''bass'')');
    
    %====================================
    % The SNARE checkbox
    btnNumber=6.25;
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
        'Callback','audioanalysis3(''setdrum'',''snare'')');
    
    %====================================
    % The HIHAT checkbox
    btnNumber=6.5;
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
        'Callback','audioanalysis3(''setdrum'',''hihat'')');
    
    %====================================
    % The HIHAT OPEN checkbox
    btnNumber=6.75;
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
        'Callback','audioanalysis3(''setdrum'',''hihat_open'')');
    
    %====================================
    % The TOM1 checkbox
    btnNumber=7;
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
        'Callback','audioanalysis3(''setdrum'',''tom1'')');
    
    %====================================
    % The TOM2 checkbox
    btnNumber=7.25;
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
        'Callback','audioanalysis3(''setdrum'',''tom2'')');
    
    %====================================
    % The TOM3 checkbox
    btnNumber=7.5;
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
        'Callback','audioanalysis3(''setdrum'',''tom3'')');
    
    %====================================
    % The CRASH checkbox
    btnNumber=7.75;
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
        'Callback','audioanalysis3(''setdrum'',''crash'')');
    
    %====================================
    % The RIDE checkbox
    btnNumber=8;
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
        'Callback','audioanalysis3(''setdrum'',''ride'')');
    
    %====================================
    % The SNARE ON checkbox
    btnNumber=8.35;
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
        'Callback','audioanalysis3(''setdrum'',''snareon'')');

   %====================================
    % The START button
    uicontrol( ...
        'Style','push', ...
        'Units','normalized', ...
        'Position',[left bottom+(2*labelHt)+spacing btnWid 2*labelHt], ...
        'String','Start', ...
        'Callback','audioanalysis3(''record'')');    
    
    %========================================
    % The CLOSE button
    uicontrol('Style','Pushbutton', ...
        'Units','normalized',...
        'Position',[left bottom btnWid 2*labelHt], ...
        'Callback','audioanalysis3(''close'')','String','Close');     
    
    %========================================
    % save fields global
    audioanalysis3_DAT.recordtime_field = recordtime_field; 
    audioanalysis3_DAT.fftlength_field = fftlength_field;
    audioanalysis3_DAT.overlaplength_field = overlaplength_field;
    audioanalysis3_DAT.window_dropdown = window_dropdown;
    audioanalysis3_DAT.Fs = Fs;
    

elseif strcmp(action,'setdrum'),
   play_drum = audioanalysis3_DAT.drums.(drum);
   if play_drum
       play_drum = false;
   else
       play_drum = true;
   end
   audioanalysis3_DAT.drums.(drum) = play_drum;  
    
elseif strcmp(action,'setrecordtime'),
    recordtime_field = audioanalysis3_DAT.recordtime_field;
    audioanalysis3_DAT.T = str2double(get(recordtime_field,'String')); 
    
    
elseif strcmp(action,'setfftlength'),
    fftlength_field = audioanalysis3_DAT.fftlength_field;
    audioanalysis3_DAT.fft_length = str2double(get(fftlength_field,'String')); 
    
    
elseif strcmp(action,'setoverlaplength'),
    overlaplength_field = audioanalysis3_DAT.overlaplength_field;
    audioanalysis3_DAT.overlap = str2double(get(overlaplength_field,'String')); 
    
    
elseif strcmp(action,'record'),    
    %------------------------------------------ 
    % get variables
    Fs = audioanalysis3_DAT.Fs;  
    T = audioanalysis3_DAT.T;   
    fft_length = audioanalysis3_DAT.fft_length;             
    window = audioanalysis3_DAT.window;    
    window_string = audioanalysis3_DAT.window_string;
    overlap = audioanalysis3_DAT.overlap;
    drums = audioanalysis3_DAT.drums;  
    
    
    %------------------------------------------ 
    %get strings
    [audiofile, drum_string, drum_string2, date, time] = CreateStrings( window_string, drums, Fs );
    %TODO: dapt strings and ordner structure
    
    %------------------------------------------ 
    % record sound
    
    % prepare audio recording
    recObj = audiorecorder(Fs,8,1); 
    
    % record and save wav file
    recordblocking(recObj, T);    
    sig = getaudiodata(recObj);    
    
    %create audio file
    audiowrite(audiofile, sig, Fs);                % write audio signal   

    
    %------------------------------------------
    %read audio file      
    [y,fs] = audioread(audiofile);                   % read audio signal     
    
    
    %------------------------------------------
    % detect onsets
    
    % function DetectOnsets(y, window_size, lock_size, reference_denominator)
    % default values: no default, 128, 10, 2.5
    onsets = DetectOnsets(y);
    %onsets = DetectOnsets(y, 128, 3, 2.5);
    %onsets = DetectOnsets(y, 64, 8, 1.6);
    
    
    %------------------------------------------
    %get features
    window_size = fft_length;
    [F, peak_1, peak_2, peak_3, frames, A, rms_ges, rms_i1, rms_i2, rms_rate_i1, rms_rate_i2, peak_c1, peak_c2, peak_c3, s] = GetFeatures(y, fs, onsets(1), window_size);

    
    %------------------------------------------
    %write features to file   
    
    csv_path = strcat(date,'/','features.csv');
    Features = [drum_string, peak_1, peak_2, peak_3, rms_ges, rms_i1, rms_i2, rms_rate_i1, rms_rate_i2, peak_c1, peak_c2, peak_c3, s];   
    %csvwrite(csv_path, Features);
    dlmwrite(csv_path,Features,'-append');
    
    
    %------------------------------------------
    %plot
    %[h,plot_count] = DrawOnsets( plot_count, y, fs, onsets );
    [ h1, h2, h3, h4, h5 ] = DrawFft( 4, y, fs, window_size, 0, window, drum_string2, window_string );
    h6 = DrawOnset( 2, y, fs, onsets(1), window_size );
    h7 = DrawFrames( 3, fs, F, peak_1, peak_2, peak_3, rms_ges, rms_i1, rms_i2, frames, peak_c1, peak_c2, peak_c3, 512 );
    
    %------------------------------------------
    %save figures
    saveas(h1,strcat(date,'/',drum_string,'/',time,'_',window_string,'_',num2str(fft_length),'_',num2str(overlap),'_plot_01.png'));
    saveas(h2,strcat(date,'/',drum_string,'/',time,'_',window_string,'_',num2str(fft_length),'_',num2str(overlap),'_plot_02.png'));
    saveas(h3,strcat(date,'/',drum_string,'/',time,'_',window_string,'_',num2str(fft_length),'_',num2str(overlap),'_plot_03.png'));
    saveas(h4,strcat(date,'/',drum_string,'/',time,'_',window_string,'_',num2str(fft_length),'_',num2str(overlap),'_plot_04.png'));
    saveas(h5,strcat(date,'/',drum_string,'/',time,'_',window_string,'_',num2str(fft_length),'_',num2str(overlap),'_plot_05.png'));
    saveas(h6,strcat(date,'/',drum_string,'/',time,'_',window_string,'_',num2str(fft_length),'_',num2str(overlap),'_plot_06.png'));
    saveas(h7,strcat(date,'/',drum_string,'/',time,'_',window_string,'_',num2str(fft_length),'_',num2str(overlap),'_plot_07.png'));

elseif strcmp(action,'redraw'),
    fprintf('redraw');
    
elseif strcmp(action,'setwindow'),
    fft_length = audioanalysis3_DAT.fft_length;    
    window_dropdown = audioanalysis3_DAT.window_dropdown;    
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
    audioanalysis3_DAT.window=window;
    audioanalysis3_DAT.window_string=window_string;

elseif strcmp(action, 'setFs'),
    Fs = 41000;
    v = get(fs_dropdown,'Value');
    if (v==1),
        Fs = 8000;
    elseif (v==2),
        Fs = 22000;
    end;
    
    audioanalysis3_DAT.Fs=Fs; 
    
elseif strcmp(action,'close'),    
    close(figure(2));
    close(figure(3));
    close(figure(4));
    close(figure(5));
    close(figure(6));
    close(gcf);
    clear global audioanalysis3_DAT; 
    
end
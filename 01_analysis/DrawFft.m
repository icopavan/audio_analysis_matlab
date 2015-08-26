function [ h1, h2, h3 ] = DrawFft( plot_count, y, fs, A, onset, fft_length, headline )
%DRAWFFT Summary of this function goes here
%   Detailed explanation goes here
    
%...
       
    %------------------------------------------------
    % graphics    
    set(0,'Units','pixels') 
    scnsize = get(0,'ScreenSize');
    figWdt = 500; 
    
    
    %------------------------------------------------  
    t = 0:length(y)-1;                              % time scale
    t = t/fs;
    
    frame_start = t(onset);
    frame_end = t(onset+fft_length);
    
    h1 = figure(plot_count); 
    %subplot(3,1,1), plot(t,y), grid;  
    plot(t,y); 
    hold on    
       %line([0;max(t)],[0;0],'Color','r'); 
       % line([frame_start;frame_start],[min(y)+min(y)/4;max(y)+max(y)/4],'Color','r');  
       % line([frame_end;frame_end],[min(y)+min(y)/4;max(y)+max(y)/4],'Color','r');  
    hold off
    title(headline);
    xlabel('t [s] \rightarrow'), ylabel('y(t)  \rightarrow');    
    set(h1, 'Position', [0 0 1000 300])
    set(gcf,'PaperPositionMode','auto')
    saveas(h1,'wave.pdf');
    %F = zeros(size(y));
    %F = fft(y);
    %f = 0:length(A)/2-1;                              % frequency scale - scale from 0 to length(y)-1
    %f = f*fs/length(A);
   
    %subplot(3,1,2), plot(f,abs(A(1:length(A)/2))), grid
    %axis([0 fs/2 0 1]);
    %xlim([40,10000]);
    %xlabel('f [Hz] \rightarrow'), ylabel('|A(f) \rightarrow|'); 
    
    %subplot(3,1,3), plot(f,abs(A(1:length(A)/2))), grid
    %axis([0 fs/2 0 1]);
    %xlim([40,1000]);
    %xlabel('f [Hz] \rightarrow'), ylabel('|A(f) \rightarrow|');    
    
    %------------------------------------------------
    % spectrogram    
    % S = spectrogram(X,WINDOW,NOVERLAP,NFFT,Fs)    
    
    frame_size = 2048;
    window = hamming(frame_size);
    
    plot_count = plot_count+1;
    h2 = figure(plot_count);      
    spectrogram(y,window,frame_size/2,40:10:10000,fs,'yaxis');
    title(headline);
    
    %------------------------------------------------   
    plot_count = plot_count+1;
    h3 = figure(plot_count);
    spectrogram(y,window,frame_size/2,40:10:1000,fs,'yaxis');
    title(headline);     

end


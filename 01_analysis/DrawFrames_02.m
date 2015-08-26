
function h = DrawFrames(  plot_count, fs, F, peak_1, peak_2, peak_3, RMS_ges, RMS_i1, RMS_i2, frames, peak_c1, peak_c2, peak_c3, window_size, headline )
%DRAWFRAMES Summary of this function goes here
%   Detailed explanation goes here
     
    f1=0:window_size*3-1;                                  % frequency scale - scale from 0 to length(y)-1
    f1=f1*fs/(window_size*3);

    f2=0:window_size-1;                                  
    f2=f2*fs/window_size;
    
    h=figure(plot_count);
    
    subplot(5,2,1);
    title(headline);
    hold on
        plot(f1,abs(F));
        plot(f1(peak_1(1)),peak_1(2),'.','MarkerEdgeColor','r');
        plot(f1(peak_2(1)),peak_2(2),'.','MarkerEdgeColor','r');
        plot(f1(peak_3(1)),peak_3(2),'.','MarkerEdgeColor','r'); 
        line([0;750],[RMS_ges;RMS_ges],'Color','r');   
        line([0;750],[RMS_i1;RMS_i1],'Color','g');    
    hold off
    xlim([0,750]); 

    subplot(5,2,2);
    
    hold on
        plot(f1,abs(F));
        plot(f1(peak_1(1)),peak_1(2),'.','MarkerEdgeColor','r');
        plot(f1(peak_2(1)),peak_2(2),'.','MarkerEdgeColor','r');
        plot(f1(peak_3(1)),peak_3(2),'.','MarkerEdgeColor','r');
        line([0;4000],[RMS_ges;RMS_ges],'Color','r');   
        line([0;750],[RMS_i1;RMS_i1],'Color','g');   
        line([750;4000],[RMS_i2;RMS_i2],'Color','g');  
        xlim([0,4000]);
    hold off
    
    max_peaks = [peak_c1; peak_c2; peak_c3];
    for k=1:3
        subplot(5,2,2*k+3);
        hold on
            plot(f2,abs(frames(:,k)));
            plot(f2(max_peaks(k,1)),max_peaks(k,2),'.','MarkerEdgeColor','r');      
        hold off
        xlim([0,750]); 
    end
    for k=1:3
        %plot
        subplot(5,2,2*k+4);     
        hold on
            plot(f2,abs(frames(:,k)));
            plot(f2(max_peaks(k,1)),max_peaks(k,2),'.','MarkerEdgeColor','r');  
        hold off
        xlim([0,4000]);
    end
end


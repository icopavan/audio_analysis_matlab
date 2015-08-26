function h = DrawOnset( plot_count, y, fs, onset, window_size, headline )
%DRAWONSET Summary of this function goes here
%   Detailed explanation goes here
    
    window_size = window_size/4;

    h=figure(plot_count);
    t=0:1/fs:(length(y)-1)/fs;          %time scaling    
   
    plot(t,y);
    xlabel('t [s] \rightarrow'), ylabel('y(t)  \rightarrow');    
    title(headline);
    hold on
       onset1 = t(onset);
       onset2 = t(onset+window_size);
       onset3 = t(onset+2*window_size);
       onset4 = t(onset+3*window_size);
       line([onset1;onset1],[min(y)+min(y)/4;max(y)+max(y)/4],'Color','r'); 
       line([onset2;onset2],[min(y)+min(y)/4;max(y)+max(y)/4],'Color','g'); 
       line([onset3;onset3],[min(y)+min(y)/4;max(y)+max(y)/4],'Color','g'); 
       line([onset4;onset4],[min(y)+min(y)/4;max(y)+max(y)/4],'Color','g'); 
    hold off
end


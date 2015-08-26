function h = DrawOnsets( plot_count, y, fs, onsets )
%DRAWONSET Summary of this function goes here
%   Detailed explanation goes here

    t=0:1/fs:(length(y)-1)/fs;          %time scaling
    
    h=figure(plot_count);
    hold on
       plot(t,y);
       xlabel('t [s] \rightarrow'), ylabel('y(t)  \rightarrow'); 
       for i=1:length(onsets)
        onset = t(onsets(i));
        line([onset;onset],[min(y)+min(y)/4;max(y)+max(y)/4],'Color','r');  
       end
    hold off

end
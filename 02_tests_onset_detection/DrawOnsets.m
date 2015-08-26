function h = DrawOnsets( plotCount, y, fs, onsets )
%DRAWONSET Summary of this function goes here
%   Detailed explanation goes here

    t=0:1/fs:(length(y)-1)/fs;          %time scaling
    
    h=figure(plotCount);
    set(h, 'Position', [200, 200, 1000, 200]);
    
    set(h, 'Units', 'centimeters')
    set(h, 'PaperUnits','centimeters');

    pos = get(h,'Position');

    % Set paper size to be same as figure size
    set(h, 'PaperSize', [25 5]);
    set(gca, 'LineWidth', 1, 'FontSize', 10);

    % Set figure to start at bottom left of paper
    % This ensures that figure and paper will match up in size
    set(h, 'PaperPositionMode', 'manual');
    set(h, 'PaperPosition', [0 0 25 5]);
    
    
    hold on
       plot(t,y);
       xlabel('t [s] \rightarrow'), ylabel('y(t)  \rightarrow'); 
       for i=1:length(onsets)
        onset = t(onsets(i));
        line([onset;onset],[min(y)+min(y)/4;max(y)+max(y)/4],'Color','r','LineWidth',1);  
       end
    hold off

end

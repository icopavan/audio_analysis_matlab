
function h = DrawFrames(  plot_count, fs, frames, headline )
%DRAWFRAMES Summary of this function goes here
%   Detailed explanation goes here

    size_frames = size(frames);
    frame_count = size_frames(:,2)
    frame_size = size_frames(:,1)

    f=0:frame_size-1;                                  
    f=f*fs/frame_size;
    
    h=figure(plot_count);
    
    title(headline);
    
    for k=1:frame_count
        subplot(frame_count,2,2*k-1), plot(f,abs(frames(:,k))), grid; 
        xlim([40,10000]); 
    end
    for k=1:frame_count
        subplot(frame_count,2,2*k), plot(f,abs(frames(:,k))), grid; 
        xlim([40,1000]);
    end
end


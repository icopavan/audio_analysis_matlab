function [audiofile, drum_string, drum_string2, date, time] = CreateStrings( window_string, drums, Fs )
%CREATEFILENAME Summary of this function goes here
%   Detailed explanation goes here
    
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
    audiofile = strcat(date,'/',drum_string,'/',time,'_',num2str(Fs),'_',window_string,'.wav');  
end


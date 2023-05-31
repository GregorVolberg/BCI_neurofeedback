function [key_code, rotAngle] = get_Response()

    
%    while ~pressed && ((GetSecs - FlipTime) < timeOut)
    [pressed, timeVector] = KbQueueCheck; 
%    end
    
if pressed
    indices = find(timeVector); % find > 0, i.e. responses
    [~, i]  = sort(timeVector(indices)); % sort by time
    KEYvec  = indices(i); % key codes, sort ascending by time
%    RTvec   = timeVector(indices(i)); % response time relative to last KbFlush, sort ascending by time, 
    key_code = KEYvec(1)
    %RT       = RTvec(1) - FlipTime;
        if ismember(KbName('ESCAPE'), KEYvec) % stop experiment if ESC is pressed
           sca; end
    if key_code == 89 
      rotAngle =  270;
      elseif key_code == 77
       rotAngle =  90;
    end
elseif ~pressed
%    RT = NaN;
    key_code = NaN;
    rotAngle = 180;
end
%KbQueueFlush(); pressed = 0; % flush queue
end
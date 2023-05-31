function [pixelIncrementRow, esc_pressed, rotAngle] = get_BCICarResponse(timeVector)

    indices = find(timeVector); % find > 0, i.e. responses
    [~, i]  = sort(timeVector(indices)); % sort by time
    KEYvec  = indices(i); % key codes, sort ascending by time
    key_code = KEYvec(1);
    esc_pressed = ismember(KbName('ESCAPE'), KEYvec); % stop experiment if ESC is pressed
    if key_code == 89 % 'y', left
      rotAngle =  135;
      pixelIncrementRow = 2;
      elseif key_code == 77 % 'm', right
       rotAngle =  225;
       pixelIncrementRow = 3;
     elseif key_code == 27 % 'ESC'
       esc_pressed = true;
       rotAngle =  180;
       pixelIncrementRow = 1;
    end
end

%% SSVEP
% jetzt bei 120 Hz
% 1 frame = 1/120 = 0.0083 s
% mit 10.909 Hz (11 frames)
% und 15 Hz (8 frames) präsentieren
% kgV : 88 frames = 0.7333 s
% 6 mal präsentieren; sind 11*6 = 66 reversals für hohe frewquenz, 8*6 = 48
% reversals für niedrige frequenz
% davor 0.733 zusätzlich; marker erst nach erstem Präsentationsdurchlauf
clear allmis miss0 change_startline alll

subjectnr    = '01'; % zwei digits  

textsize_pt = 35;
numoftrials = 20;

frames_hf = 8;
frames_lf = 11;
repeatcompletesequence = 3; %3*(8*11)*2 = 528 frames (4.4 sec); davon die letzten 440 (3.667 sec) auswerten.
% am Besten: 440 frames = 3.6667 sec (vielfaches von 88, also auch von 8
% und 11); freq-Auflösung 1/3.67 =  0.2727 Hz; 40*0.2727 sind genau 10.9091
% Hz, 55*0.2727 sind genau 15 Hz
markercodes=[4,16,20,64,68];

secpause1 = 5; % Pause zwischen Trials, vor beep
secpause2 = 2; % Pause zwischen Trials, nach beep

instrText = 'Leertaste für Start!';

% Vieweing and device parameters
% 550 by 440 mm screen
% 700 mm viewing distance
% size of pixel @ 1280 by 1024: 0.43 mm
pixelsize = 0.43; % Größe eines Pixels in Millimeter
Blickdistanz = 700; % Blickdistanz in Millimetern

% central fixation dot
centcirclesize_deg = 0.1; % Size of central fixation circle
centcirclesize_pix = round((2*(tan(2*pi/360*(centcirclesize_deg/2))*Blickdistanz))/pixelsize); % in pixels 

% 1 deg below/above hoprizintal bzw right/left from vertical midline
distfromcenter = 1; % vorher 4 
grid_pix = round((2*(tan(2*pi/360*(distfromcenter/2))*Blickdistanz))/pixelsize); % in pixels 

% define beep for error feedback
beepdur = 0.2; % beep duration in seconds
beep = sin(1:8192*beepdur); % 8192 Hz default sampling rate

% for checkergrapheme
squaresize = 40; %in pixel
checkernum = 8; % must be even

isReady = Datapixx('Open');
trigTrain = zeros(1,4);
Datapixx('StopAllSchedules'); % stop running schedules
Datapixx('RegWrRd');    % Synchronize DATAPixx registers to local register cache

% We'll make sure that all the TTL digital outputs are low before we start
Datapixx('SetDoutValues', 0);
Datapixx('RegWrRd');

try
    Priority(1);
    HideCursor;
    [window,rect]=Screen('OpenWindow',0); % 0 on laptop
    [width, height]=Screen('WindowSize', window);
    hz=Screen('NominalFrameRate', window);

    % define PTB presenation times
    centdot   = [width/2-centcirclesize_pix/2, height/2-centcirclesize_pix/2, width/2+centcirclesize_pix/2, height/2+centcirclesize_pix/2];
    
    %colors
    white=WhiteIndex(window); % pixel value for white
    black=BlackIndex(window); % pixel value for black
    gray = round((white - black)/2);
    lightgray = white - round((white - black)/4);

    % presentation trains for hf / lf condition
    hftrain = repmat([repmat(white, 1, frames_hf), repmat(black, 1, frames_hf)], 1, frames_lf * repeatcompletesequence);
    lftrain = repmat([repmat(white, 1, frames_lf), repmat(black, 1, frames_lf)], 1, frames_hf * repeatcompletesequence);

    TastenCodes = [32, 27]; % [y, m, ESC];
    TastenVector = zeros(1,256); TastenVector(TastenCodes) = 1;
    
    leftside   = width/2-(squaresize*checkernum/2)   + [0:squaresize:squaresize*checkernum-1];
    rightside  = width/2-(squaresize*checkernum/2) + [squaresize:squaresize:squaresize*checkernum];
    horiz_mids = (leftside + rightside)/2;
    upperside  = height/2-(squaresize*checkernum/2)   + [0:squaresize:squaresize*checkernum-1];
    lowerside  = height/2-(squaresize*checkernum/2) + [squaresize:squaresize:squaresize*checkernum];
    verti_mids = (upperside + lowerside)/2+squaresize;

        
a = repmat(leftside, 1,8);
b = [repmat(upperside(1),1,8), repmat(upperside(2),1,8), repmat(upperside(3),1,8), repmat(upperside(4),1,8), ...
    repmat(upperside(5),1,8), repmat(upperside(6),1,8), repmat(upperside(7),1,8), repmat(upperside(8),1,8)]; 
c = repmat(rightside, 1,8);
d = [repmat(lowerside(1),1,8), repmat(lowerside(2),1,8), repmat(lowerside(3),1,8), repmat(lowerside(4),1,8), ...
    repmat(lowerside(5),1,8), repmat(lowerside(6),1,8), repmat(lowerside(7),1,8), repmat(lowerside(8),1,8)]; 
sqrs = [a;b;c;d];

blacksq = [0,0,0]; whitesq = [255 255 255];
sqrcol1 = repmat([repmat([whitesq;blacksq]', 1,4), repmat([blacksq;whitesq]', 1,4)],1,4);
sqrcol2 = abs(sqrcol1-255);

horizont_x = [leftside(1), rightside(end)];
horizont_y = [upperside, lowerside(end)];

for hh=1:numel(horizont_y)
    hlines(1, hh*2-1:hh*2) = horizont_x;
    hlines(2, hh*2-1:hh*2) = horizont_y(hh);
end

vertical_x = [leftside, rightside(end)];
vertical_y = [upperside(1), lowerside(end)];

for vv=1:numel(vertical_x)
    vlines(1, vv*2-1:vv*2) = vertical_x(vv);
    vlines(2, vv*2-1:vv*2) = vertical_y;
end

linewidth = 10;
    
    KbQueueCreate([],TastenVector);
    Screen('FillRect',window,gray);
    Screen('TextSize', window, 40); %fontsize 
    Screen('TextFont', window, 'Helvetica');
    DrawFormattedText(window, instrText, 'center', 'center', black);
    Screen('Flip', window);
    KbQueueFlush;
    KbQueueWait; % also starts queue
        

% First Screen, draw fixpoint
Screen('FillRect',window,gray);
Screen('FillOval', window, black, centdot); %rect: left, top, right, bottom
Screen('Flip', window);

    
%% trial loop
Screen('FillOval', window, black, centdot); %rect: left, top, right, bottom
[a1]=Screen('Flip', window);

tmp = Shuffle(1:20);
change_startline = tmp(1:10); clear tmp; % ob hfgraph 1 und 3 oder 2 und 4 sind

for trial=1:numoftrials
    strt = GetSecs();
    
        % offscreen windows
    allwin(1) = Screen('OpenOffscreenWindow', window, gray);
    allwin(2) = Screen('OpenOffscreenWindow', window, gray);
    allwin(3) = Screen('OpenOffscreenWindow', window, gray);
    allwin(4) = Screen('OpenOffscreenWindow', window, gray);

 
        %% prepare OffScreenWindows
        % allwin(1): all black
        % hier freq zuordnen und markerwert
    whatframe = nan(1,length(hftrain));
    whatframe(hftrain == 0   & lftrain == 0)       = 1; % all black    
    whatframe(hftrain == 255 & lftrain == 255)     = 2; % all white
    whatframe(hftrain == 255 & lftrain == 0)       = 3; % hf white, lf black
    whatframe(hftrain == 0   & lftrain == 255)     = 4; % lf white, hf black    
    
    if ~ismember(trial, change_startline)
        line1 = [51, 50, 51, 50, 51, 50, 51, 50]; % 51=hf, 50 = lf
    else
        line1 = [50, 51, 50, 51, 50, 51, 50, 51];
    end
    
    line2 = [line1(2:8), line1(1)];
    line3 = [line1(3:8), line1(1:2)];
    line4 = [line1(4:8), line1(1:3)];
    line5 = [line1(5:8), line1(1:4)];
    line6 = [line1(6:8), line1(1:5)];
    line7 = [line1(7:8), line1(1:6)];
    line8 = [line1(8), line1(1:7)];
    alllines = [line1; line2; line3; line4;line5;line6; line7;line8];
    % nicht immer in der hauptdiagonale!
    hfwhite = ismember(alllines, 51)*255;
    lfwhite = ismember(alllines, 50)*255;
    
    alll{trial}=alllines;
    
    colvectorhf = reshape(hfwhite', 1,size(hfwhite,1) * size(hfwhite,2));
    colmathf = repmat(colvectorhf,3,1);
    colvectorlf = reshape(lfwhite', 1, size(lfwhite,1)*size(lfwhite,2));
    colmatlf = repmat(colvectorlf,3,1);
    
        %all black
    Screen('FillRect', allwin(1), gray); %clear text and redraw later with correct coordinates
    Screen('FillRect', allwin(1), 0, sqrs);
    Screen('DrawLines', allwin(1), hlines, linewidth, gray);
    Screen('DrawLines', allwin(1), vlines, linewidth, gray);
    Screen('FillOval', allwin(1), black, centdot); %rect: left, top, right, bottom
    
    %all white 
    Screen('FillRect', allwin(2), gray); %clear text and redraw later with correct coordinates
    Screen('FillRect', allwin(2), 255, sqrs);
    Screen('DrawLines', allwin(2), hlines, linewidth, gray);
    Screen('DrawLines', allwin(2), vlines, linewidth, gray);
    Screen('FillOval', allwin(2),  black, centdot); %rect: left, top, right, bottom
    % hf white. lf black 
    Screen('FillRect', allwin(3), gray); %clear text and redraw later with correct coordinates
    Screen('FillRect', allwin(3), colmathf, sqrs);
    Screen('DrawLines', allwin(3), hlines, linewidth, gray);
    Screen('DrawLines', allwin(3), vlines, linewidth, gray);
    Screen('FillOval', allwin(3),  black, centdot); %rect: left, top, right, bottom
    % lf white. hf black 
    Screen('FillRect', allwin(4), gray); %clear text and redraw later with correct coordinates
    Screen('FillRect', allwin(4), colmatlf, sqrs);
    Screen('DrawLines', allwin(4), hlines, linewidth, gray);
    Screen('DrawLines', allwin(4), vlines, linewidth, gray);
    Screen('FillOval', allwin(4),  black, centdot); %rect: left, top, right, bottom

            WaitSecs(GetSecs + secpause1 - strt); % 6 seconds from trial start 
            sound(beep);
            WaitSecs(secpause2);

            markval = zeros(1,numel(whatframe)); 
            trigTrain(3) = markercodes(5); 
            Datapixx('WriteDoutBuffer', trigTrain);
            Datapixx('SetDoutSchedule', 0, [1, 2], length(trigTrain));
            Datapixx('StartDoutSchedule');
            
            mis = nan(1,numel(whatframe));
            Screen('Flip',window); % macht Waitblanking
            Datapixx('RegWrRdVideoSync'); % schreibt zu Beginn des nächsten Flips; das Bild sieht man aber erst am ENDE des nächsten Flips (Beginn übernächsten)
            % daher marker erst im frame nach dem relevanten frame
            [trsh1 trsh2 trsh3 miss0a] = Screen('Flip',window); % schreibt also hier marker
            for frm = 1:numel(whatframe)
            Screen('DrawTexture', window, allwin(whatframe(frm)));
            [trsh1 trsh2 trsh3 mis(frm)]=Screen('Flip',window);
            end
            allmis{trial}=mis;
            miss0(trial) = miss0a;
            
            [pressed, timevec] = KbQueueCheck;
            [KEYvec, RTvec] = GetBehavioralPerformance(timevec);
            KEYvec = find(timevec);
            if ismember(27, KEYvec) %ESC-taste
                sca;
                break;
            end
       
Screen('FillRect', window, gray); %clear text and redraw later with correct coordinates
Screen('FillOval', window, black, centdot); %rect: left, top, right, bottom
Screen('Flip', window);

Screen('Close', allwin(4));
Screen('Close', allwin(3));
Screen('Close', allwin(2));
Screen('Close', allwin(1)); clear allwin
end

WaitSecs(secpause1);



catch
    Screen('CloseAll');
    fprintf('We''ve hit an error.\n');
    psychrethrow(psychlasterror);
    fprintf('This last text never prints.\n');
end
WaitSecs(1);
KbQueueStop;
KbQueueRelease;

Datapixx('Close');
save(['S', subjectnr, '_block5.mat'], 'allmis', 'miss0', 'change_startline', 'alll');

sca;
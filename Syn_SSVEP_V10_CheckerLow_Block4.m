%% SSVEP
% jetzt bei 120 Hz
% 1 frame = 1/120 = 0.0083 s
% mit 10.909 Hz (11 frames)
% und 15 Hz (8 frames) präsentieren
% kgV : 88 frames = 0.7333 s
% 6 mal präsentieren; sind 11*6 = 66 reversals für hohe frewquenz, 8*6 = 48
% reversals für niedrige frequenz
% davor 0.733 zusätzlich; marker erst nach erstem Präsentationsdurchlauf

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

    xdim = repmat(horiz_mids, 1,8);
    ydim = [repmat(verti_mids(1),1,8), repmat(verti_mids(2),1,8), repmat(verti_mids(3),1,8), repmat(verti_mids(4),1,8), ...
        repmat(verti_mids(5),1,8), repmat(verti_mids(6),1,8), repmat(verti_mids(7),1,8), repmat(verti_mids(8),1,8)]; 
    graphdims = [xdim;ydim];
   
    
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



for trial=1:numoftrials
    strt = GetSecs();
    % offscreen windows
%     Screen('TextSize', allwin(2), textsize_pt); %fontsize 
%     Screen('TextFont', allwin(2), 'Helvetica');
%     Screen('TextStyle', allwin(2), 1); 
%     allwin(3) = Screen('OpenOffscreenWindow', window, gray);
%     Screen('TextSize', allwin(3), textsize_pt); %fontsize 
%     Screen('TextFont', allwin(3), 'Helvetica');
%     Screen('TextStyle', allwin(3), 1); 
%     allwin(4) = Screen('OpenOffscreenWindow', window, gray);
%     Screen('TextSize', allwin(4), textsize_pt); %fontsize 
%     Screen('TextFont', allwin(4), 'Helvetica');
%     Screen('TextStyle', allwin(4), 1); 
allwin(1) = Screen('OpenOffscreenWindow', window, gray);
allwin(2) = Screen('OpenOffscreenWindow', window, gray);

Screen('FillRect', allwin(1), gray); %clear text and redraw later with correct coordinates
Screen('FillRect', allwin(1), sqrcol1, sqrs);
Screen('FillOval', allwin(1), gray, centdot); %rect: left, top, right, bottom

Screen('FillRect', allwin(2), gray); %clear text and redraw later with correct coordinates
Screen('FillRect', allwin(2), sqrcol2, sqrs);
Screen('FillOval', allwin(2), gray, centdot); %rect: left, top, right, bottom

    whatframe = nan(1,length(lftrain));
    whatframe(lftrain == 0)       = 1; 
    whatframe(lftrain == 255)     = 2; % all white

            WaitSecs(GetSecs + secpause1 - strt); % 6 seconds from trial start 
            sound(beep);
            WaitSecs(secpause2);

            markval = zeros(1,numel(whatframe)); 
            trigTrain(3) = markercodes(4); 
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

            clear trsh1 trsh2 trsh3

            
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
save(['S', subjectnr, '_block4.mat'], 'allmis', 'miss0');
sca;
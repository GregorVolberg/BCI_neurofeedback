% =======================
% function[] = BCIcar()
% 1/60 = 0.016667 s
% 11 frame =  1000/(11/60) = 5.4545 Hz (harmonics separated)
% 7 frames =  1000/(7/60)  = 8.5714
% =======================
function [] = SSVEP_Markus()

expname = 'SSVEP_Markus.mat';    

rctSize       = 400;
%rctFromCenter = 150;
%rctFromBottom = 100;

% frequencies    
f1 = 1000/(11/60); 
f2 = 1000/(7/60);
phi0    = 0;
% t = 0:1/60:1
% % for demo
% swave   = sin(2*pi*f1*t+phi0)
% lumwave = (swave + 1)/2
% plot(lumwave)
% swave   = sin(2*pi*f2*t+phi0)
% lumwave = (swave + 1)/2
% hold on; plot(lumwave)

Screen('Preference', 'SkipSyncTests', 1);

% set up paths, responses, monitor, ...
rootDir = pwd;
addpath([rootDir, '/func']);
rawdir = [rootDir, '/raw'];
vp = input('Code für Teilnehmer/in (drei Zeichen, z. B. S01)? ', 's');
     if length(vp)~=3 
        error ('Wrong input!'); end


outfilename = [vp, '_', expname];

isOctave = check_octave;
if isOctave
rawdir = [rootDir, '/raw/'];
else 
rawdir = [rootDir, '\raw\'];
end
if ~exist(rawdir, 'dir')
mkdir(rawdir);    
end

%[vp, response_mapping, instruct] = get_experimentInfo(run_mode, rootDir);
[TastenVector] = prepare_responseKeys; % manual responses
MonitorSelection = 3; % Dell Notebook is 6
MonitorSpecs = getMonitorSpecs(MonitorSelection); % subfunction, gets specification for monitor

patternSelect = 2; %1 = uniform, 2 = checker, 3 = grating 


try
    Priority(1);
    HideCursor;
    [win, ~] = Screen('OpenWindow', MonitorSpecs.ScreenNumber, 127); 

    Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [width, height] = Screen('WindowSize', win);
    hz = Screen('NominalFrameRate', win);
    
    
% % textures
% carTexture  = Screen('MakeTexture', win, car);
% rockTexture = Screen('MakeTexture', win, rock);
% treeTexture = Screen('MakeTexture', win, tree);
% fireTexture = Screen('MakeTexture', win, fire);

% Construct and start response queue
    KbQueueCreate([],TastenVector);
    KbQueueStart;
    

driverRect = [width/2 - rctSize/2, height/2 - rctSize/2, ...
                 width/2 + rctSize/2, height/2 + rctSize/2]';

% checker
lefttop = driverRect(1:2);
siz = rctSize;
numCheckers = 4;
left = lefttop(1):siz/numCheckers:(siz+lefttop(1));
top  = lefttop(2):siz/numCheckers:(siz+lefttop(2));
oneRow = [left(1:numCheckers); top(1:numCheckers); left(2:(numCheckers+1))-1; top(2:(numCheckers+1))-1];

allRows = [];
for m = 0:(numCheckers-1)
    newRow = oneRow + [siz/numCheckers 0 siz/numCheckers 0]' * m;
    allRows = [allRows, newRow];
end

checkertmp  = reshape(repmat([1 0], 1, (numCheckers^2)/2), numCheckers, numCheckers)'; 
checkerrev  = repmat([1 -1], 1, (numCheckers)/2);
checkerplus = repmat([0 1], 1, (numCheckers)/2);
checkerCol1 = reshape((checkertmp.* checkerrev' + checkerplus')', 1, numCheckers^2);
checkerCol2 = abs(checkerCol1 + -1);
             
switch patternSelect
    case 1
        pattern = driverRect;
        lumVec  = 1; 
    case 2
        pattern = allRows;
        lumVec = checkerCol1;
end

    frame_number = 0;   
    
    Screen('Flip', win);
    WaitSecs(1);
    
     KbQueueFlush(); pressed = 0;
    
    %obstacleRun = obstacleRect;
    while 1
     frame_number = frame_number +1;
     % Flicker patches
%     colLeft = get_luminance_from_sine(f1, frame_number/60, phi0);
%     Screen('FillRect', win, colLeft*255, driverRect);
     %colRight = get_luminance_from_sine(f2, frame_number/60, phi0);
     colRight = get_luminance_from_sine_new(f2, frame_number/60, phi0, patternSelect);
     Screen('FillRects', win, lumVec*colRight*255, pattern);
     % manual or brain response
     [pressed, timeVector] = KbQueueCheck; 
     if pressed
     [pixelIncrementRow, esc_pressed, rotationAngle] = get_BCICarResponse(timeVector);
     if esc_pressed
       break; end
     end
     Screen('Flip', win);
     end
   
        
    SSVEP_Markus            = [];
    SSVEP_Markus.vp         = vp;
    SSVEP_Markus.date       = datestr(clock,30); 
    SSVEP_Markus.experiment = expname;
    SSVEP_Markus.hz         = hz;
    SSVEP_Markus.resolution = [width, height];
    SSVEP_Markus.pc         = getenv('COMPUTERNAME');
    SSVEP_Markus.isOctave   = isOctave;
        
    save([rawdir, outfilename], 'SSVEP_Markus', '-v7');
 
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end
Screen('CloseAll');
end

%% =================== subfunctions =========


function [escpress] = show_instruction(windowPointer, instTexture, run_mode, blocknum)
       if run_mode == 1
       Screen('Flip', windowPointer);
       Screen('DrawTexture', windowPointer, instTexture);
       Screen('Flip', windowPointer); 
       KbQueueFlush();
       [~, keyCode, ~] = KbStrokeWait();
       escpress = (find(keyCode) == KbName('ESCAPE'));
       elseif run_mode == 2
        escpress = 0;
       else
        error('Wrong runmode');
       end
       WaitSecs(0.2);
       Screen('Flip', windowPointer);
end



function [MonitorSpecs] = getMonitorSpecs(MonitorSelection)
switch MonitorSelection
    case 1 % Dell-Monitor EEG-Labor
    MonitorSpecs.width     = 530; % in mm
    MonitorSpecs.height    = 295; % in mm
    MonitorSpecs.distance  = 600;%810; % in mm
    MonitorSpecs.xResolution = 2560; % x resolution
    MonitorSpecs.yResolution = 1440;  % y resolution
    MonitorSpecs.refresh     = 120;  % refresh rate
    MonitorSpecs.PixelsPerDegree = round((2*(tan(2*pi/360*(1/2))*MonitorSpecs.distance))/(MonitorSpecs.width / MonitorSpecs.xResolution)); % pixel per degree of visual angle
    case 2 % alter Belinea-Monitor Bï¿½ro
    MonitorSpecs.width     = 390; % in mm
    MonitorSpecs.height    = 290; % in mm
    MonitorSpecs.distance  = 600; % in mm
    MonitorSpecs.xResolution = 1280; % x resolution
    MonitorSpecs.yResolution = 1024;  % y resolution
    MonitorSpecs.refresh     = 60;  % refresh rate
    MonitorSpecs.PixelsPerDegree = round((2*(tan(2*pi/360*(1/2))*MonitorSpecs.distance))/(MonitorSpecs.width / MonitorSpecs.xResolution)); % pixel per degree of visual angle
    case 3 % neuer Monitor Bï¿½ro, Dell P2210
    MonitorSpecs.width     = 470; % in mm
    MonitorSpecs.height    = 295; % in mm
    MonitorSpecs.distance  = 600; % in mm
    MonitorSpecs.xResolution = 1680; % x resolution
    MonitorSpecs.yResolution = 1050;  % y resolution
    MonitorSpecs.refresh     = 60;  % refresh rate
    MonitorSpecs.PixelsPerDegree = round((2*(tan(2*pi/360*(1/2))*MonitorSpecs.distance))/(MonitorSpecs.width / MonitorSpecs.xResolution)); % pixel per degree of visual angle
    MonitorSpecs.ScreenNumber    = 2;
    case 4 % Monitor Home Office, LG 24BK750Y-B, 24-inch
    MonitorSpecs.width     = 530; % in mm
    MonitorSpecs.height    = 295; % in mm
    MonitorSpecs.distance  = 600; % in mm
    MonitorSpecs.xResolution = 1920; % x resolution
    MonitorSpecs.yResolution = 1080;  % y resolution
    MonitorSpecs.refresh     = 60;  % refresh rate
    MonitorSpecs.PixelsPerDegree = round((2*(tan(2*pi/360*(1/2))*MonitorSpecs.distance))/(MonitorSpecs.width / MonitorSpecs.xResolution)); % pixel per degree of visual angle
    MonitorSpecs.ScreenNumber    = 1;
    case 5 % Alex Notebook HP Elitebook 850 6G
    MonitorSpecs.width     = 345; % in mm
    MonitorSpecs.height    = 195; % in mm
    MonitorSpecs.distance  = 600; % in mm
    MonitorSpecs.xResolution = 1920; % x resolution
    MonitorSpecs.yResolution = 1080;  % y resolution
    MonitorSpecs.refresh     = 60;  % refresh rate
    MonitorSpecs.PixelsPerDegree = round((2*(tan(2*pi/360*(1/2))*MonitorSpecs.distance))/(MonitorSpecs.width / MonitorSpecs.xResolution)); % pixel per degree of visual angle
    MonitorSpecs.ScreenNumber    = 0;
        case 6 % Dell-Latitude 6320
    MonitorSpecs.width     = 290; % in mm
    MonitorSpecs.height    = 165; % in mm
    MonitorSpecs.distance  = 600;%810; % in mm
    MonitorSpecs.xResolution = 1366; % x resolution
    MonitorSpecs.yResolution = 768;  % y resolution
    MonitorSpecs.refresh     = 60;  % refresh rate
    MonitorSpecs.PixelsPerDegree = round((2*(tan(2*pi/360*(1/2))*MonitorSpecs.distance))/(MonitorSpecs.width / MonitorSpecs.xResolution)); % pixel per degree of visual angle
    MonitorSpecs.ScreenNumber    = 0;
end
end

% function [vp, response_mapping, instruct] = get_experimentInfo(run_mode)
% if run_mode == 1
%   vp = input('\nParticipant (three characters, e.g. S01)? ', 's');
%     if length(vp)~=3 
%        error ('Wrong input!'); end
%     response_mapping = str2num(input('\nResponse mapping?\n1: y = rund, m = spitz\n2: y = spitz, m = rund\n', 's'));    
%       if ~ismember(response_mapping, [1, 2])
%         error('\nUnknown mapping!'); end
% else
%       vp = 'tmp';
%       response_mapping = 1;
% end
% 
% switch response_mapping
%     case  1
%         instruct = imread('instruction_mapping1.png');
%     case  2
%         instruct = imread('instruction_mapping2.png');
% end
% instruct = 255-instruct; instruct(instruct == 255) = 127;
% end




function [TastenVector] = prepare_responseKeys()
KbName('UnifyKeyNames');
TastenCodes  = KbName({'y','m', 'ESCAPE'}); 
TastenVector = zeros(1,256); TastenVector(TastenCodes) = 1;
end

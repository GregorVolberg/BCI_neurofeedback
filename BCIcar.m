% =======================
% function[] = RFPc(run_mode)
% 1/60 = 0.016667 s
% 11 frame =  1000/(11/60) = 5.4545 Hz (harmonics separated)
% 7 frames =  1000/(7/60)  = 8.5714
% =======================



function[outmat] = BCIcar()

f1 = 1000/(11/60); 
f2 = 1000/(7/60);
phi0    = 0;
##t = 0:1/60:1
####% for demo
##swave   = sin(2*pi*f1*t+phi0)
##lumwave = (swave + 1)/2
##plot(lumwave)
##swave   = sin(2*pi*f2*t+phi0)
##lumwave = (swave + 1)/2
##hold on; plot(lumwave)

Screen('Preference', 'SkipSyncTests', 1);

% set up paths, responses, monitor, ...
rootDir = pwd;
addpath([rootDir, '/func']);

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

try
    Priority(1);
    HideCursor;
    [win, ~] = Screen('OpenWindow', MonitorSpecs.ScreenNumber, 127); 

    %Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [width, height] = Screen('WindowSize', win);
    hz = Screen('NominalFrameRate', win);
    
   
    Screen('Flip', win);
    Screen('TextSize', win, 25); %fontsize 34
    Screen('TextFont', win, 'Helvetica');

    % Construct and start response queue
    KbQueueCreate([],TastenVector);
    KbQueueStart;

%    get_luminance_from_sine(f1, 0/60, phi0)
    
%    blocknum = 0;
%    instTexture = Screen('MakeTexture', win, instruct);
%    escpress = show_instruction(win, instTexture, run_mode, blocknum);
    
    % block loop
    escpress=0;
    % left top right bottom
    rctSize = 100;
    rctFromCenter = 50;
    rctFromBottom = 100;
    rectLeft  = [width/2 - rctFromCenter - rctSize, height - rctFromBottom - rctSize, ...
                width/2 - rctFromCenter, height - rctFromBottom]';
    rectRight = [width/2 + rctFromCenter, height - rctFromBottom - rctSize, ...
                 width/2 + rctFromCenter + rctSize, height - rctFromBottom]';
                
    
    frame_number = 0;   
    
    
     FlipTime = Screen('Flip', win);
     WaitSecs(1); 
    
     for frame_number = 0:300
     %frame_number=k;
     colLeft = get_luminance_from_sine(f1, frame_number/60, phi0);
     Screen('FillRect', win, colLeft*255, rectLeft);
     colRight = get_luminance_from_sine(f2, frame_number/60, phi0);
     Screen('FillRect', win, colRight*255, rectRight);
     Screen('Flip', win);
     end
   
     % get response
     %get_behavioralresponse(FlipTime, response_keys); % exit on ESC
     
    
 
        
    RFP = [];
    RFP.vp      = vp;
    RFP.mapping = response_mapping;
    RFP.date    = tstring;
    RFP.block   = blocknum;
    RFP.outmat  = outmat;
    RFP.experiment = 'RFPc';
    RFP.hz         = hz;
    RFP.resolution = [width, height];
    RFP.pc         = getenv('COMPUTERNAME');
    RFP.isOctave   = isOctave;
    
 
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end
Screen('CloseAll');
end

%% =================== subfunctions =========

function [key_code, RT, isRound] = get_behavioralresponse(FlipTime, response_keys)

    KbQueueFlush(); pressed = 0; % flush queue
    while ~pressed           
         [pressed, timevec] = KbQueueCheck; 
    end
[KEYvec, RTvec] = GetBehavioralPerformance(timevec); % get RT; see subfunction
key_code = KEYvec(1);
RT = RTvec(1) - FlipTime;
isRound = key_code == response_keys(1);
end


function [conmat] = get_conmat()
% 6 harmonics * 2 nodd * 2 bfreq * 3 audiofrq = 72; 
% bei 8 Durchg�ngen pro bedingung: 576 trials, 48 pro RFP*audio

nodd  = repelem([1 3 5 7 9 11], 96); % harmonics for sound wave
wavef = repmat(repelem([0.5, 1.5], 48), 1, 6); % off harmonics for spikeness
bfrq  = repmat(repelem([3, 4], 24), 1, 12); % freq of Rbase, 3 or 4
%frq   = repmat(repelem([15, 25],12), 1, 24); % freq of RFP, 20 or 30 % 20 
audi  = repmat(repelem([2000, 2200, 2400], 4), 1, 48); % audio frequency, 2000 2200 2400
conmat = [1:length(nodd); nodd; wavef; bfrq; audi]';
end


function [snd] = get_sound(type, duration, Freq, fade, Fs)

t         = (0:(1/Fs):duration-(1/Fs))';
fade_samp = length((0:(1/Fs):fade-(1/Fs)));
fadefunc  = ones(length(t), 1);
fadefunc(1:fade_samp) = linspace(0, 1, fade_samp);
fadefunc(end-fade_samp+1:end) = linspace(1, 0, fade_samp);

if type == 1
snd = sin(2*pi*Freq*t) .* fadefunc;
elseif type == 2
snd = sawtooth(2*pi*Freq*t, 1) .* fadefunc;
else 
    error('Unknown waveform specified in conmat');
end
snd = repmat(snd',2,1); % for PsychAudio
end

% function [snd] = generate_sounds(snd_order, duration, Freq, fade, betw_pause, Fs)
% % nur zwei sounds, sin und tria
% % order: 1 = sin zuerst, 2 = tria zuerst 
% % s_length = l�nge des sound samples, pro wellenform, in sec
% % freq: zB 2000, 2250, 2500
% % fade-in und fade-out, in sec
% % pause: pause zwischen sounds, in sec
% %Fs       = 44000;
% 
% t         = (0:(1/Fs):duration-(1/Fs))';
% fade_samp = length((0:(1/Fs):fade-(1/Fs)));
% fadefunc  = ones(length(t), 1);
% fadefunc(1:fade_samp) = linspace(0, 1, fade_samp);
% fadefunc(end-fade_samp+1:end) = linspace(1, 0, fade_samp);
% 
% sinwave = sin(2*pi*Freq*t) .* fadefunc;
% sawwave = sawtooth(2*pi*Freq*t, 1) .* fadefunc;
% paus    = zeros(Fs * betw_pause, 1);
% if snd_order == 1
%     snd = [sinwave; paus; sawwave];
% elseif snd_order == 2
%     snd = [sawwave; paus; sinwave];
% end
% 
% end


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

function [KEYvec, RTvec] = GetBehavioralPerformance(TimeVector)
indi=find(TimeVector); % wo ungleich 0, also responses
[~, i]=sort(TimeVector(indi)); % sortiere nach Zeit
KEYvec = indi(i); % key, aufsteigend nach Zeit
RTvec  = TimeVector(indi(i)); % rt, aufsteigend nach Zeit, relativ zum letzte KbEventFlush
% stop experiment if ESC is pressed
    if ismember(KbName('ESCAPE'), KEYvec) %ESC-taste
       sca; end
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
    case 2 % alter Belinea-Monitor B�ro
    MonitorSpecs.width     = 390; % in mm
    MonitorSpecs.height    = 290; % in mm
    MonitorSpecs.distance  = 600; % in mm
    MonitorSpecs.xResolution = 1280; % x resolution
    MonitorSpecs.yResolution = 1024;  % y resolution
    MonitorSpecs.refresh     = 60;  % refresh rate
    MonitorSpecs.PixelsPerDegree = round((2*(tan(2*pi/360*(1/2))*MonitorSpecs.distance))/(MonitorSpecs.width / MonitorSpecs.xResolution)); % pixel per degree of visual angle
    case 3 % neuer Monitor B�ro, Dell P2210
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

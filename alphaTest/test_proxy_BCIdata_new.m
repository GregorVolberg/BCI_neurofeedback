ftpath = 'C:\Users\Gregor\Documents\m-lib\fieldtrip-20210311';
addpath(ftpath); ft_defaults;


%hdrname = 'C:\Users\Gregor\Filr\Meine Dateien\BCI\sampleData\bakerbaker_0001.vhdr';
%hdrname = 'C:\Users\Gregor\Filr\Meine Dateien\BCI\freigabeBCI\OpenBCI-RAW-2021-03-15_12-36-14.txt'
hdrname = 'C:\Users\Gregor\Filr\Meine Dateien\BCI\sampleData\OpenBCI-RAW-2021-03-25_13-08-24_Value1.txt';
%eegname = 'C:\Users\Gregor\Filr\Meine Dateien\BCI\sampleData\bakerbaker_0001.eeg';

hdr = ft_read_header(hdrname);

% 1 FP1 = EXG0
% 2 FP2 = EXG1
% 3 FPZ = EXG2
% 4 FT7 = EXG3
% 5 FT8 = EXG4
% 6 F7 bzw. AF7 = EXG5
% 7 F8 bzw. AF8 = EXG6
% 8 Oz= EXG7
%Sample Index, EXG Channel 0, EXG Channel 1, EXG Channel 2, EXG Channel 3, EXG Channel 4, EXG Channel 5, EXG Channel 6, EXG Channel 7, Accel Channel 0, Accel Channel 1, Accel Channel 2, Other, Other, Other, Other, Other, Other, Other, Analog Channel 0, Analog Channel 1, Analog Channel 2, Timestamp, Timestamp (Formatted)
% 8*EXG
% 3*ACC
% 7*other
% 3*Analog = 21 Kanäle??
% in hdr.chantype sind Kanäle 1:8 'eeg'


cfg = [];
cfg.channel = {'1', '2', '3', '4','5', '6', '7', '8',}; %FP1 und FP2
cfg.source.headerfile  = hdrname;
cfg.target.datafile = 'buffer://localhost:1972';
cfg.speed = 1; %very important, slow down processing to actual sampling speed
ft_realtime_fileproxy(cfg);



% in a second session (second instance)
cfg = [];
cfg.channel = {'1', '2'};
cfg.foilim    = [8 12];
cfg.blocksize = 0.5; %number, size of the blocks/chuncks that are processed (default = 1 second)
cfg.dataset   = 'buffer://localhost:1972';
%ft_realtime_powerestimate(cfg);
gregor_realtime_powerestimate(cfg);


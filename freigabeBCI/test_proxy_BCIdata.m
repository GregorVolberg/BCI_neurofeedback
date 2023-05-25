ftpath = 'C:\Users\Gregor\Documents\m-lib\fieldtrip-20210311';
addpath(ftpath); ft_defaults;


hdrname = 'C:\Users\Gregor\Filr\Meine Dateien\BCI\sampleData\bakerbaker_0001.vhdr';
hdrname = 'C:\Users\Gregor\Filr\Meine Dateien\BCI\freigabeBCI\OpenBCI-RAW-2021-03-15_12-36-14.txt'
eegname = 'C:\Users\Gregor\Filr\Meine Dateien\BCI\sampleData\bakerbaker_0001.eeg';

hdr = ft_read_header(hdrname);

%Sample Index, EXG Channel 0, EXG Channel 1, EXG Channel 2, EXG Channel 3, EXG Channel 4, EXG Channel 5, EXG Channel 6, EXG Channel 7, Accel Channel 0, Accel Channel 1, Accel Channel 2, Other, Other, Other, Other, Other, Other, Other, Analog Channel 0, Analog Channel 1, Analog Channel 2, Timestamp, Timestamp (Formatted)
% in one Matlab session (first instance)
cfg = [];
cfg.channel = {'6', '7'};
%cfg.channel = {'EXG.Channel.0', 'EXG.Channel.1'};

%cfg.source.datafile = eegname;
cfg.source.headerfile  = hdrname;
cfg.target.datafile = 'buffer://localhost:1972';
cfg.speed = 1; %very important, slow down processing to actual sampling speed
ft_realtime_fileproxy(cfg);


% in a second session (second instance)
cfg = [];
cfg.channel = 'all';
cfg.dataset = 'buffer://localhost:1972';
cfg.demean = 'yes';
ft_realtime_signalviewer(cfg);


% OR

% in a second session (second instance)
cfg = [];
cfg.channel   = 'all';
cfg.foilim    = [1 30];
cfg.blocksize = 0.5; %number, size of the blocks/chuncks that are processed (default = 1 second)
cfg.dataset   = 'buffer://localhost:1972';
ft_realtime_powerestimate(cfg);



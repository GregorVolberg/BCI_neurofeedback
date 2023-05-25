ftpath = 'C:\Users\Gregor\Documents\m-lib\fieldtrip-20210311';
addpath(ftpath); ft_defaults;


hdrname = 'C:\Users\Gregor\Filr\Meine Dateien\BCI\sampleData\bakerbaker_0001.vhdr';
eegname = 'C:\Users\Gregor\Filr\Meine Dateien\BCI\sampleData\bakerbaker_0001.eeg';

hdr = ft_read_header(hdrname);

% in one Matlab session (first instance)
cfg = [];
cfg.channel = {'F3', 'F4'};
cfg.source.datafile = eegname;
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



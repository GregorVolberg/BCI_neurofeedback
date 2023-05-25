fpath = 'C:\Users\Gregor\Filr\Meine Dateien\BCI\';
ftpath = 'C:\Users\Gregor\Documents\m-lib\fieldtrip-20210311';
addpath(ftpath); ft_defaults;

% read OpenBCI data
hdr = ft_read_header([fpath, 'OpenBCI-RAW-2021-03-15_12-36-14.txt']);

cfg = [];
cfg.trialdef.triallength = Inf;
cfg.trialdef.ntrials     = 1;
cfg.dataset = [fpath, 'OpenBCI-RAW-2021-03-15_12-36-14.txt'];
cfg = ft_definetrial(cfg);

eeg = ft_preprocessing(cfg);

cfgv = [];
cfgv.viewmode = 'vertical';
ft_databrowser(cfgv, eeg);

% data are non-EEG?


% https://www.fieldtriptoolbox.org/getting_started/realtime/
% applications described on that page are only in ft-full, not ft-lite
% versions
% buffer.exe is in realtime/bin/win64
% sine2ft.exe and viewer.exe are in realtime/bin/win32

while true
hdr = ft_read_header('buffer://localhost:1972')
pause(1)
end


while true
hdr = ft_read_header('buffer://localhost:1972');
dat = ft_read_data('buffer://localhost:1972', 'begsample', 1, 'endsample', inf);
plot(dat');
pause(1)
end

% funktioniert beides
% in dat sind die trial-Daten


addpath('C:\Users\Gregor\Documents\m-lib\fieldtrip-20210311');
ft_defaults;

% Pfad auf Dateien anpassen
rawpath   = 'C:\Users\Gregor\Filr\Meine Dateien\BCI\pilot\raw\'; 
cleanpath = 'C:\Users\Gregor\Filr\Meine Dateien\BCI\pilot\clean\'; 
orgpath   = 'C:\Users\Gregor\Filr\Meine Dateien\BCI\pilot\org\'; 
 
dset  = {'OpenBCI-RAW-2021-05-17_21-22-27_Baseline.txt';
 'OpenBCI-RAW-2021-05-17_21-32-27_FB&BB.txt'; 
 'OpenBCI-RAW-2021-05-19_12-27-44_FB&BB.txt'}; 

for m = 1:3
%% segmente definieren
cfg=[];
cfg.trialdef.triallength = Inf;
cfg.trialdef.ntrials = 1;
cfg.dataset = [rawpath dset{m}];
cfg = ft_definetrial(cfg);

%% preproc; übernimmt die cfg-datei
cfg.demean   = 'yes';
cfg.channel  = {'1', '2', '3', '4', '5', '6', '7', '8'}; 
preproc = ft_preprocessing(cfg);

preproc.label = {'FP1', 'FP2', 'FPz', 'FT7', 'FT8', 'F7', 'F8', 'Oz'};


maxtime = max(preproc.time{1});
starttime = round((maxtime-180) / 2);
stoptime  = starttime + 180;
cfg=[];
cfg.latency = [starttime stoptime];
prep = ft_selectdata(cfg, preproc);



% cfg=[];
% cfg.viewmode = 'vertical';
% ft_databrowser(cfg, prep);
% 

cfgtf = [];
cfgtf.method = 'mtmfft';
cfgtf.taper  = 'hanning';
cfgtf.output = 'pow';
cfgtf.foi    = [2:0.05:20];
%cfgtf.foilim = [2 20];

frq = ft_freqanalysis(cfgtf, prep);

% cfgp = [];
% cfgp.parameter = 'powspctrm';
% for k = 1:8
% cfgp.channel  = preproc.label(k);;
% ft_singleplotER(cfgp, frq);
% end

cfgd=[]
cfgd.frequency = [8 12];
erg=ft_freqdescriptives(cfgd, frq);

cfgsel=[];
cfgsel.channel ={'FP1'; 'FP2'};
cfgsel.avgoverchan = 'yes';
cfgsel.freq = [8 12];
cfgsel.avgoverfreq = 'yes';
rg{m} = ft_selectdata(cfgsel, frq);

end




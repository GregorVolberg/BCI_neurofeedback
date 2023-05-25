addpath('C:\Users\Gregor\Documents\m-lib\fieldtrip-20210311');
ft_defaults;

% Pfad auf Dateien anpassen
rawpath   = 'C:\Users\Gregor\Filr\Meine Dateien\BCI\exp1\raw\'; 
cleanpath = 'C:\Users\Gregor\Filr\Meine Dateien\BCI\exp1\clean\'; 
orgpath   = 'C:\Users\Gregor\Filr\Meine Dateien\BCI\exp1\org\'; 
 
dset  = {'OpenBCI-RAW-2021-06-29_20-16-22_Clea_PC.txt';      
         'OpenBCI-RAW-2021-06-29_20-26-23_Clea_Laptop.txt';
         'OpenBCI-RAW-2021-06-29_20-45-24_Seb_PC.txt';
         'OpenBCI-RAW-2021-06-29_20-39-13_Seb_Laptop.txt'};   
   
%https://openbci.com/forum/index.php?p=/discussion/201/large-millivolt-data-values-fbeeg-full-band-eeg
% BCI is DC-recording with offset
% can be removed from continuous data with hp filter 0.5 Hz

%for m = 1:3
m=3
%% segmente definieren
cfg=[];
cfg.trialdef.triallength = Inf;
cfg.trialdef.ntrials = 1;
cfg.dataset = [rawpath dset{m}];
cfg = ft_definetrial(cfg);

%% preproc; übernimmt die cfg-datei
cfg.hpfilter = 'yes';
cfg.hpfreq   = 0.5;
cfg.lpfilter = 'yes';
cfg.lpfreq   = 35;
cfg.channel  = {'1', '2', '3', '4', '5', '6', '7', '8'}; 
preproc = ft_preprocessing(cfg);
preproc.label = {'FP1', 'FP2', 'FPz', 'FT7', 'FT8', 'F7', 'F8', 'Oz'};

cfg=[];
cfg.viewmode = 'vertical';
cfg.continuous = 'yes';
cfg.blocksize  = 300;
ft_databrowser(cfg, preproc);
%% alternativ Hilbert-Amplitude
cfg=[];
cfg.trialdef.triallength = Inf;
cfg.trialdef.ntrials = 1;
cfg.dataset = [rawpath dset{m}];
cfg = ft_definetrial(cfg);
preproc = ft_preprocessing(cfg);
cfg=[]
cfg.bpfilter   = 'yes';
cfg.bpfreq     = [10 13];
cfg.hilbert    = 'abs';
cfg.channel  = {'1', '2', '3', '4', '5', '6', '7', '8'}; 
p2 = ft_preprocessing(cfg, preproc);

cfg=[];
cfg.viewmode = 'vertical';
cfg.continuous = 'yes';
cfg.blocksize  = 300;
ft_databrowser(cfg, p2);


%% erst mal schauen ob railed
% cfg.reref = 'yes';
%cfg.refchannel = 'all'

% electrode position file sfp cownloaded from https://docs.openbci.com/docs/06Software/02-CompatibleThirdPartySoftware/Matlab

cfgtf = [];
cfgtf.method = 'mtmfft';
cfgtf.taper  = 'hanning';
cfgtf.output = 'pow';
cfgtf.foilim = [2 20];
frq = ft_freqanalysis(cfgtf, preproc);



cfgp = [];
cfgp.parameter = 'powspctrm';
for k = 1:8
cfgp.channel  = preproc.label(k);;
ft_singleplotER(cfgp, frq);
end


% according to https://docs.openbci.com/docs/04AddOns/01-Headwear/HeadBand
% the 8-elec setup is
%preproc.label = {'Fp1', 'Fp2', 'Fpz', 'TP7', 'TP8', 'P7', 'P8', 'Oz'};

% alternativ mit 2s trials
cfg=[];
cfg.trialdef.triallength = 2;
cfg.dataset = [rawpath dset{m}];
cfg = ft_definetrial(cfg);

%cfg.hpfilter = 'yes';
%cfg.hpfreq   = 0.5;
cfg.channel  = {'1', '2', '3', '4', '5', '6', '7', '8'}; 
preproc = ft_preprocessing(cfg);
preproc.label = {'FP1', 'FP2', 'FPz', 'FT7', 'FT8', 'F7', 'F8', 'Oz'};

cfgtf = [];
cfgtf.method = 'mtmfft';
cfgtf.taper  = 'hanning';
cfgtf.output = 'pow';
cfgtf.foilim = [2 20];
frq = ft_freqanalysis(cfgtf, preproc);

cfgp = [];
cfgp.parameter = 'powspctrm';
for k = 1:8
cfgp.channel  = preproc.label(k);;
ft_singleplotER(cfgp, frq);
end

for m = 1:4

cfg=[];
cfg.trialdef.triallength = Inf;
cfg.trialdef.ntrials = 1;
cfg.dataset = [rawpath dset{m}];
cfg = ft_definetrial(cfg);

cfg.hpfilter = 'yes';
cfg.hpfreq   = 0.5;
cfg.lpfilter = 'yes';
cfg.lpfreq   = 35;
cfg.channel  = {'1', '2', '3', '4', '5', '6', '7', '8'}; 
preproc = ft_preprocessing(cfg);
preproc.label = {'FP1', 'FP2', 'FPz', 'FT7', 'FT8', 'F7', 'F8', 'Oz'};

% filtern (--> ft_freqanalysis)
cfg = [];
cfg.output             = 'pow';
cfg.method             = 'wavelet';
cfg.foi                = [4:1:30];
cfg.width              = 7;
cfg.toi                = 0:0.2:300;
tfr = ft_freqanalysis(cfg, preproc); 

% baseline correction (--> ft_freqbaseline)
cfgbs = [];
cfgbs.baseline = [10 20];
cfgbs.baselinetype = 'relchange';
tfrb{m} = ft_freqbaseline(cfgbs, tfr);
end

cfgx=[];
cfgx.channel = 'FT8';
cfgx.xlim = [0 300]; % time limits
cfgx.ylim = [4 30];   % freq limits
cfgx.zlim = [-1.5 1.5]; % color scale

%figure;
for j = 1:4
%subplot(4,1,j);
ft_singleplotTFR(cfgx, tfrb{j});
end


maxtime = max(preproc.time{1});
starttime = round((maxtime-180) / 2);
stoptime  = starttime + 180;
cfg=[];
cfg.latency = [starttime stoptime];
prep = ft_selectdata(cfg, preproc);



% 


cfgd=[]
cfgd.frequency = [8 12];
erg=ft_freqdescriptives(cfgd, frq);

cfgsel=[];
cfgsel.channel ={'FP1'; 'FP2'};
cfgsel.avgoverchan = 'yes';
cfgsel.freq = [8 12];
cfgsel.avgoverfreq = 'yes';
rg{m} = ft_selectdata(cfgsel, frq);

%end




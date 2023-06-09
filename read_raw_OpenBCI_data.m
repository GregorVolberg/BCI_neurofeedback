%% 
addpath('../m-lib/fieldtrip-20230303'); ft_defaults;
orgpath   = './org/';
data  = 'OpenBCI-RAW-2023-05-23_10-51-08.txt';
data      = 'OpenBCI-RAW-2023-05-23_11-49-27.txt';
data      = 'OpenBCI-RAW-2023-05-23_alpha2.txt';

%% define segments
cfg = [];
cfg.dataset            = data;
cfg.trialdef.ntrials   = 1;
cfg = ft_definetrial(cfg);

%% preproc; Ã¼bernimmt die cfg-datei
cfg.channel   = 1:8;
%cfg.detrend   = 'yes';
%cfg.demean    = 'yes';
preproc       = ft_preprocessing(cfg);
preproc.label = {'Fp1', 'Fp2', 'Fpz', 'TP7', 'TP8', 'P7', 'P8', 'Oz'};

cfg = [];
cfg.hpfilter      = 'yes';
cfg.hpfreq = 3;
cfg.lpfilter      = 'yes';
cfg.lpfreq = 50;
ft_databrowser(cfg, preproc);


cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'all';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 6:2:30;                         % analysis 2 to 30 Hz in steps of 2 Hz
cfg.t_ftimwin    = 7./cfg.foi;   % length of time window = 0.5 sec
cfg.toi          = 2:0.1:40;                      % the time window "slides" from -0.5 to 1.5 in 0.05 sec steps
TFR = ft_freqanalysis(cfg, preproc);    % visual stimuli


cfg = [];
cfg.baseline     = [2 3];
cfg.baselinetype = 'relchange';
%TFRb = ft_freqbaseline(cfg, TFR);
cfg.channel      = 'Oz';
cfg.zlim         = [-10 10];
ft_singleplotTFR(cfg, TFR); title('Signal change');


%% fft
% https://www.fieldtriptoolbox.org/workshop/madrid2019/tutorial_freq/
cfgf = [];
cfgf.length  = 2;
cfgf.overlap = 0;
base_rpt1    = ft_redefinetrial(cfgf, preproc);

cfg2 = [];
cfg2.output  = 'pow';
cfg2.channel = 'all';
cfg2.method  = 'mtmfft';
cfg2.taper   = 'boxcar';
cfg2.foi     = 1:0.5:45; 
base_freq1   = ft_freqanalysis(cfg2, base_rpt1);

figure;
hold on;
plot(base_freq1.freq, mean(base_freq1.powspctrm(1:2,:)));
legend('2 sec window')
xlabel('Frequency (Hz)');
ylabel('absolute power (uV^2)');


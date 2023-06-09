%% 
addpath('../m-lib/fieldtrip-20230303'); ft_defaults;
orgpath   = './org/';
%data      = 'OpenBCI-RAW-2023-06-06_14-20-21low.txt';
%data      = 'OpenBCI-RAW-2023-06-06_14-21-48high.txt';
%data      = 'OpenBCI-RAW-2023-06-07_lfBuero.txt';
%data      = 'OpenBCI-RAW-2023-06-07_hfBuero.txt';
%data = 'OpenBCI-RAW-2023-06-07_EasycapLow.txt';
data = 'OpenBCI-RAW-2023-06-07_EasycapHigh.txt';


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
EasyCap = {'PO4', 'PO3', 'PO2', 'PO1', 'O4', 'O3', 'O2', 'O1'};
BCI= {'Fp1', 'Fp2', 'Fpz', 'O4', 'O2', 'O3', 'O1', 'Oz'};
preproc.label = EasyCap;
cfgsel = [];
cfgsel.latency = [25 30];
cfgsel.channel = 'O1';
seldat = ft_selectdata(cfgsel, preproc);

cfg2 = [];
cfg2.output  = 'pow';
cfg2.channel = 'all';
cfg2.method  = 'mtmfft';
cfg2.taper   = 'boxcar';
cfg2.foi     = 3:0.1:25; 
base_freq1   = ft_freqanalysis(cfg2, seldat);

figure;
hold on;
plot(base_freq1.freq, base_freq1.powspctrm);
%legend('0.1 sec window')
xlabel('Frequency (Hz)');
ylabel('absolute power (uV^2)');


timeDomain = preproc.trial{1}(1:8,:); % elecs 4:8
on = nearest(preproc.time{1}, 10);
inc = round(1/(1/(10/60) - (1/(11/60))) * 250); % for freq resolution 0.5455
tmp = timeDomain(:,on:on+inc*5);
%tmp = y1;
tukwin = tukeywin(size(tmp,2), 0.1);

Fs = 250;            % Sampling frequency
T = 1/Fs;             % Sampling period
L = inc;       % Length of signal % wir brauchen 1 mehr für akkurate freqauflösung
%t = (0:L-1)*T;        % Time vector
f = Fs*(0:(L/2))/L;   % frequency vector
%tukwin = tukeywin(numel(tmp), 0.1); %tukey win, rectangular window with first and last r/2 % points like a cosine
wocci = tmp .* repmat(tukwin, 1, size(tmp,1))';

Y1 = abs(fft(wocci', inc)); %wocci
P2 = Y1/L; %standardize
P1 = P2((1:L/2+1),:);             
             % standardize
            %P1 = P2(1:(L+1)/2);             %P1 = P2(1:L/2+1); %"produce even-valued signal ength P1"
P1(2:end-1,:) = 2*P1(2:end-1,:);
plot(f, P1)
fon = nearest(f, 2);
foff = nearest(f, 26);
plot(f(fon:foff), P1(fon:foff,:))




% cfg = [];
% %cfg.hpfilter      = 'yes';
% %cfg.hpfreq = 3;
% %cfg.lpfilter      = 'yes';
% %cfg.lpfreq = 50;
% ft_databrowser(cfg, preproc);


cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'all';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 2:0.1:20;                         % analysis 2 to 30 Hz in steps of 2 Hz
cfg.t_ftimwin    = 7./cfg.foi;   % length of time window = 0.5 sec
cfg.toi          = 2:0.5:30;                      % the time window "slides" from -0.5 to 1.5 in 0.05 sec steps
TFR = ft_freqanalysis(cfg, preproc);    % visual stimuli

% 5.45 und 8.57
cfg = [];
cfg.baseline     = [2 3];
cfg.baselinetype = 'relchange';
%TFRb = ft_freqbaseline(cfg, TFR);
cfg.channel      = {'O1'}%,'O1', 'O2', 'O3', 'O4'}; %, 'O1', 'O2', 'O3', 'O4'
cfg.zlim         = [-10 10];
cfg.xlim = [10 30];
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


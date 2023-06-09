%% 
addpath('../m-lib/fieldtrip-20230303'); ft_defaults;
orgpath   = './org/';
%data      = 'OpenBCI-RAW-2023-06-06_14-20-21low.txt';
%data      = 'OpenBCI-RAW-2023-06-06_14-21-48high.txt';
%data      = 'OpenBCI-RAW-2023-05-23_11-49-27.txt';
%data      = 'OpenBCI-RAW-2023-05-23_alpha2.txt';

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
preproc.label = {'Fp1', 'Fp2', 'Fpz', '04', '02', 'O3', 'O1', 'Oz'};

timeDomain = preproc.trial{1}(4:8,:); % elecs 4:8
%fft(preproctimedom, 500, 
%plot(abs(fft(preproc.trial{1})))

% f1 = 1000/(11/60); 
% f2 = 1000/(7/60);
% phi0    = 0;
% t = 0:1/60:1;
% swave   = sin(2*pi*f1*t+phi0);
% plot(swave);

harmonics = [0.5 1 2]; % repetition, base, 1st harmonic
f1 = (1/(11/60) * harmonics)'; 
f2 = (1/(7/60)  * harmonics)'; 
phi0    = 0;
t = 0:1/preproc.fsample:1;
y1   = sin(2*pi*f1*t+phi0);
y2   = sin(2*pi*f2*t+phi0);
plot(y1');

on = nearest(preproc.time{1}, 10);
% set data segment length so that it fits with 1/60!!
% fresolution = fsamplerate / Npoints;
%inc = round(1/(1/(10/60) - (1/(11/60))) * 250/2); % for freq resolution 0.5455
inc = round(1/(1/(10/60) - (1/(11/60))) * 250); % for freq resolution 0.5455
tmp = timeDomain(:,on:on+inc);
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



cfg2 = [];
cfg2.output  = 'pow';
cfg2.channel = 'all';
cfg2.method  = 'mtmfft';
cfg2.taper   = 'boxcar';
cfg2.foi     = 1:0.5:45; 
base_freq1   = ft_freqanalysis(cfg2, preproc);

figure;
hold on;
plot(base_freq1.freq, mean(base_freq1.powspctrm(4:8,:)));
legend('0.1 sec window')
xlabel('Frequency (Hz)');
ylabel('absolute power (uV^2)');


cfg = [];
%cfg.hpfilter      = 'yes';
%cfg.hpfreq = 3;
%cfg.lpfilter      = 'yes';
%cfg.lpfreq = 50;
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


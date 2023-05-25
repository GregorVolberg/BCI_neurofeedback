% sine tone with 10 Hz modulation

% generate square wave
% https://de.mathworks.com/help/signal/ref/square.html
% https://de.mathworks.com/help/signal/ref/sawtooth.html

duration = 5; % in s
fade_dur = 0.02;%
Freq     = 750; %in Hz
Freq2     = 1250; %in Hz
Fs       = 44000;
modulFrq = 10; %in Hz

t         = (0:(1/Fs):duration-(1/Fs))';
fade_samp = length((0:(1/Fs):fade_dur-(1/Fs)));
fadefunc  = ones(length(t), 1);
fadefunc(1:fade_samp) = linspace(0, 1, fade_samp);
fadefunc(end-fade_samp+1:end) = linspace(1, 0, fade_samp);
modfunc   = (sin(2*pi*modulFrq*t) + 1)/2;

sinwave = sin(2*pi*Freq*t) .* fadefunc;
sinmod  = sin(2*pi*Freq*t) .* fadefunc .* modfunc;
sinmod2 = sin(2*pi*Freq2*t) .* fadefunc .* modfunc;
ss= [sinmod; sinmod2];


sound(sinwave, Fs); %OK
sound(sinmod, Fs); %OK
sound(ss, Fs);
audiowrite('tenHz.wav', ss, Fs);



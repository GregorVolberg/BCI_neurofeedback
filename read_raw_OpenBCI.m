addpath('../m-lib/fieldtrip-20230303'); ft_defaults;
orgpath   = './org/';

d         =  dir('BrainFlow-*.csv');
fileList  = cellstr(char(d.name)); clear d

for k = 1:numel(fileList)
eegcell{k} = readmatrix(fileList{k}, 'Delimiter', '\t', 'DecimalSeparator', ','); 
end




ft_read_data(filelist{1}, 
elecfile   = [orgpath, '63equidistant_elec_GV.mat'];
layoutfile = [orgpath, '63equidistant_GreenleeLab_lay.mat'];
load(elecfile, 'elec');
load(layoutfile, 'lay');

erg = NaN(numel(fileList), 62, 8);
for vp  = 1:numel(fileList)
spot = load(fileList{vp});
erg(vp, : , :) = spot.perElec; % vp, chan, time
end
avgtopo = squeeze(mean(erg, 1));

% dummy timelock structure
dummyER = [];
dummyER.dimord = 'chan_time';
dummyER.label  = elec.label(1:62);
dummyER.avg    = avgtopo;
dummyER.time   = 0.1:0.1:0.8;

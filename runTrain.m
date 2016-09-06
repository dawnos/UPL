
% %%
% run startup.m;
% 
% %%
% data_dir = '~/Projects/ZED/D1-P1-L1';
% [filenames, transforms] = readImageFilenames(data_dir);
% 
% %%
% bank = generatePlaceBank(transforms);

%%
bank = bank(1);
for B = bank
  detectors = generateSeedDetectors(imread(filenames{B}), [64 64]);
end

%%


%%
run startup.m;


%%
data_dir = '~/Projects/datasets/ZED/D1-P1-L1';
[filenames, transforms] = readImageFilenames(data_dir);


%%
stereoCamParam = readZEDConf('./SN2906.conf');


%%
bank = generatePlaceBank(transforms);
bank = bank(5);

%%
detectors = cell(1,size(bank,1));
for i = 1:size(bank,1)
  
  placeId = bank(i);
  
  
  %% 1) train seed detectors
  [detector1, bbox1] = trainSeedDetectors(imread(filenames{placeId}), [64 64]);
  
    
  %% 2) test detectors in nearby images
  [detector2, bbox2, positions2, scores2, nearbyFilenames, nearbyTransforms, nearbyImages] = ...
    testDetectorsInNearbyImages(detector1, bbox1, filenames, transforms, placeId);
  
  
  %% 3) perform geometric tests for consistency
  [detector3, bbox3, positions3, scores3] = ...
    performGeometricTestsForConsistency(detector2, bbox2, positions2, scores2, ...
    filenames, nearbyFilenames, nearbyTransforms, nearbyImages, placeId, stereoCamParam);
  
end

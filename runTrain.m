
%%
run startup.m;


%%
data_dir = '~/Projects/datasets/ZED/D1-P1-L1';
[filenames, transforms, stereoCamParam] = readImageFilenames(data_dir);


%%
bank = generatePlaceBank(transforms);
bank = bank(5);

%%
detectors = cell(1,size(bank,1));
for i = 1:size(bank,1)
  
  placeId = bank(i);
  
  
  %% 1) train seed detectors
  [detector1, bbox1] = trainSeedDetectors(...
    imread(filenames{placeId}), [64 64]);
  
    
  %% 2) test detectors in nearby images
  [detector2, bbox2, positions2, scores2, ...
    nearbyFilenames, nearbyTransforms, nearbyImages] = ...
    testDetectorsInNearbyImages(...
    detector1, bbox1, filenames, transforms, placeId);
  
  
  %% 3) perform geometric tests for consistency
  [detector3, bbox3, positions3, scores3, locations] = ...
    performGeometricTestsForConsistency(...
    detector2, bbox2, positions2, scores2, ...
    nearbyFilenames, nearbyTransforms, nearbyImages, ...
    imread(filenames{placeId}), transforms{placeId},...
    stereoCamParam);
  
end

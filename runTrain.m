
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
  placeImage = imread(filenames{placeId});
  placeTransform = transforms{placeId};
  
  %% 1) train seed detectors
  [detector1] = trainSeedDetectors(...
    placeImage, [64 64]);
  
    
  %% 2) test detectors in nearby images
  [detector2, positions2, scores2, ...
    nearbyFilenames, nearbyTransforms, nearbyImages] = ...
    testDetectorsInNearbyImages(...
    detector1, filenames, transforms, placeId);
  
  
  %% 3) perform geometric tests for consistency
  [detector3, positions3, scores3, locations3] = ...
    performGeometricTestsForConsistency(...
    detector2, positions2, scores2, ...
    nearbyFilenames, nearbyTransforms, nearbyImages, ...
    placeImage, placeTransform,...
    stereoCamParam);

    %% 4.1) retrain
    detector41 = retrainDetectorsFromMultipleImages(...
        nearbyImages, positions3, [64 64]);
    
    %% 4.2)
    [detector42, positions42, scores42, ...
        nearbyFilenames, nearbyTransforms, nearbyImages] = ...
        testDetectorsInNearbyImages(...
        detector41, filenames, transforms, placeId);
    
    %% 4.3)
    [detector43, positions43, scores43, locations43] = ...
        performGeometricTestsForConsistency(...
        detector42, positions42, scores42, ...
        nearbyFilenames, nearbyTransforms, nearbyImages, ...
        placeImage, placeTransform,...
        stereoCamParam);
    
end

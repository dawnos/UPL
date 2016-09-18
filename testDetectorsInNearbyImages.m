
% Step 2
function [newDetector, newPositions, newScores, ...
    nearbyFilenames, nearbyTransforms, nearbyImages] = ...
  testDetectorsInNearbyImages(...
  detector, filenames, transforms, placeId)

  %% 1) find nearby images
  nearbyFilenames = {};
  nearbyImages = {};
  nearbyACFs = {};
  nearbyTransforms = {};
  for j = 1:size(transforms,1)
    if norm(transforms{placeId}(1:3,4) - transforms{j}(1:3,4)) < 1.0
      nearbyFilenames{end+1} = filenames{j};
      nearbyImages{end+1} = imread(nearbyFilenames{end});
      nearbyTransforms{end+1} = transforms{j};
      acf = chnsCompute(nearbyImages{end});
      nearbyACFs{end+1} = cat(3,acf.data{:});
    end
  end
  fprintf('%d nearby image(s) found\n', length(nearbyTransforms));
  
  %% 2)
  figure;
  positions = zeros(length(nearbyFilenames), size(detector,1), 2);
  scores = zeros(length(nearbyFilenames), size(detector,1));
  for nn = 1:length(nearbyFilenames)
    tic;
    for d = 1:size(detector,1)
      [positions(nn, d,:), scores(nn,d)] = ...
          detect(nearbyACFs{nn}, detector(d,:));
      positions(nn, d,:) = positions(nn, d,:) * 4;
    end
    subplot(ceil(length(nearbyFilenames) / 5), 5, nn);
    imshow(nearbyImages{nn}); hold on;
    plot(positions(nn,:,1), positions(nn,:,2), '*');
    fprintf('Detection on %s done in %f second(s)\n', ...
        nearbyFilenames{nn}, toc);
  end

  %% 3)
  % bboxid = 1:size(bbox,1);
  [~, notpass]=ind2sub(size(scores), find(scores(:,:)<-0.5));
  notpass = unique(notpass);
  pass = ones(size(positions,2),1);
  pass(notpass)=0;
  pass = find(pass == 1);
  newDetector = detector(pass, :);
  newPositions = positions(:,pass, :);
  newScores = scores(:,pass);
  % bboxid1 = bboxid(pass1);
  
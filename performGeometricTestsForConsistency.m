function  [newDetector, newBbox, newPositions, newScores] = ...
  performGeometricTestsForConsistency(...
  detector, ...
  bbox, ...
  positions, ...
  scores, ...
  filenames, ...
  nearbyFilenames, ...
  nearbyTransforms, ...
  nearbyImages, ...
  placeId,...
  stereoCamParam)


%%
K = stereoCamParam.CameraParameters1.IntrinsicMatrix;
if 1
  P0 = initialPointEstimation1(...
    bbox, positions, nearbyFilenames, K);
else
  % P0 = initialPointEstimation2(positions, nearbyTransforms, K);
end

%%
reprojerr = zeros(size(detector, 1),length(nearbyFilenames));
for j = 1:size(detector,1)
  fprintf('Geometric check: %d\n', j);
  if isempty(nonzeros(isnan(P0(:,j))))
    [p, ~, err] = lsqnonlin(@(p)projFunc(p, squeeze(positions(:,j,:)), nearbyTransforms,K), P0(:,j));
    % err = projFunc(p, squeeze(positions(:,j,:)), nearbyTransforms,A);
    err = reshape(err, [], 2);
    reprojerr(j,:) = sqrt(err(:,1) .^2 + err(:,2) .^ 2);
  else
    reprojerr(j,:) = NaN;
  end
end


%% 4)
geo_check = zeros(size(detector, 1),1);
for j = 1:size(detector,1)
  
  if isempty(find(reprojerr(j,:) > 16, 1)) && sum(reprojerr(j,:)) / length(nearbyFilenames) < 8
    geo_check(j) = 1;
  end
end
pass = find(geo_check == 1);
newDetector = detector(pass, :);
newPositions = positions(:,pass,:);
newScores = scores(:,pass);
newBbox = bbox(pass,:);

figure;
I = imread(filenames{placeId});
I = insertObjectAnnotation(I, 'rectangle', ...
  newBbox(:,1:4), cellstr(num2str(newBbox(:,5))), ...
  'Color', 'r', 'FontSize', 8);
imshow(I);

%%
figure;
for j = 1:size(newDetector,1)
  clf;
  for K = 1:length(nearbyFilenames)
    subplot(ceil(length(nearbyFilenames)/4), 4, K); hold on;
    imshow(nearbyImages{K});
    rectangle('Position', [newPositions(K,j,1) newPositions(K,j,2) 64 64], 'EdgeColor', 'r');
  end
  title(['landmark ' num2str(j, '%03d')]);
  print(['final/landmark_' num2str(j, '%03d')], '-dpng');
end


end


function P0 = initialPointEstimation1(bbox, positions, nearbyFilenames, A)

depth = zeros(size(positions,1), size(positions, 2));
nearbyDepths = cell(size(nearbyFilenames));
for i = 1:length(nearbyFilenames)
  fn = nearbyFilenames{i};
  fn = strrep(fn, 'image02', 'image04');
  fn = strrep(fn, 'jpg', 'png');
  nearbyDepths{i} = imread(fn);
  nearbyDepths{i} = double(nearbyDepths{i}(:,:,1))/1000;
  for j = 1:size(bbox,1)
    % depth(j,k) = mean(nonzeros(imcrop(nearbyDepths{j}, bbox1(k,:))));
    depth(i,j) = nearbyDepths{i}(bbox(j,2)+ceil(bbox(j,4)/2), bbox(j,1)+ceil(bbox(j,3)/2));
    if depth(i,j) == 0
      depth(i,j) = NaN;
    end
  end
end

p3d = zeros(size(positions, 1), size(positions, 2), 3);
p3d(:,:,1) = (positions(:,:,1) - A(1,3)) /A(1,1) .* depth;
p3d(:,:,2) = (positions(:,:,2) - A(2,3)) /A(2,2) .* depth;
p3d(:,:,3) = depth;
P0 = squeeze(sum(p3d,1))' / length(nearbyFilenames);

end


function P0 = initialPointEstimation2(positions, transforms, K)

P0 = [];
for i = 1:size(positions,2)
  A = [];
  b = [];
  for j = 1:length(transforms)
    T = inv(transforms{j});
    r1 = T(1,1:3);
    r2 = T(2,1:3);
    r3 = T(3,1:3);
    t1 = T(1,4);
    t2 = T(2,4);
    t3 = T(3,4);
    ux = (positions(j,i,1) - K(1,3)) / K(1,1);
    vy = (positions(j,i,2) - K(2,3)) / K(2,2);
    A = [A;r1-ux*r3;r2-vy*r3];
    b = [b;ux*t3-t1;vy*t3-t2];
  end
  P0 = [P0 A\b];
end

end


%%
run startup.m;

%%
data_dir = '~/Projects/ZED/D1-P1-L1';
% data_dir = '~/DataBlock/ZED/D1-P1-L1';
[filenames, transforms] = readImageFilenames(data_dir);

%%
zed = ini2struct('./SN2906.conf');
leftCamParam = cameraParameters('IntrinsicMatrix', [...
  str2double(zed.left_cam_vga.fx) 0 str2double(zed.left_cam_vga.cx)
  0 str2double(zed.left_cam_vga.fy) str2double(zed.left_cam_vga.cy)
  0 0 1
  ]);
rightCamParam = cameraParameters('IntrinsicMatrix', [...
  str2double(zed.right_cam_vga.fx) 0 str2double(zed.right_cam_vga.cx)
  0 str2double(zed.right_cam_vga.fy) str2double(zed.right_cam_vga.cy)
  0 0 1
  ]);
stereoCamParam = stereoParameters(leftCamParam, rightCamParam, eye(3), [str2double(zed.stereo.baseline) 0 0]);

%%
bank = generatePlaceBank(transforms);
bank = bank(5);

%%
detectors = cell(1,size(bank,1));

%%
for i = 1:size(bank,1)
  
  B = bank(i);
  
  % 1) train seed detectors
  [detector, bbox] = generateSeedDetectors(imread(filenames{B}), [64 64]);
  
    
  %% 2)
  
  % find nearby images
  nearbyFilenames = {};
  nearbyImages = {};
  nearbyACFs = {};
  nearbyTransforms = [];
  for j = 1:size(transforms,2)
    if norm(transforms(1:3,B) - transforms(1:3,j)) < 1.0
      nearbyFilenames{end+1} = filenames{j};
      nearbyImages{end+1} = imread(nearbyFilenames{end});
      nearbyTransforms = [nearbyTransforms transforms(:,j)];
      acf = chnsCompute(nearbyImages{end});
      nearbyACFs{end+1} = cat(3,acf.data{:});
    end
  end
  fprintf('%d nearby image(s) found\n', length(nearbyTransforms));
  
  %%
  figure;
  positions = zeros(length(nearbyFilenames), size(detector,1), 3);
  for nn = 1:length(nearbyFilenames)
    tic;
    % image = imread(nearbyFilenames{nn});
    % descriptor = computeDescriptor(image);
    for d = 1:size(detector,1)
      positions(nn, d,:) = detect(nearbyACFs{nn}, detector(d,:));
      positions(nn, d,1) = positions(nn, d,1) * 4;
      positions(nn, d,2) = positions(nn, d,2) * 4;
    end
    subplot(ceil(length(nearbyFilenames) / 5), 5, nn);
    imshow(nearbyImages{nn}); hold on;
    plot(positions(nn,:,1), positions(nn,:,2), '*');
    fprintf('Detection on %s done in %f second(s)\n', nearbyFilenames{nn}, toc);
  end

  %%
  [~, notpass1]=ind2sub(size(positions), find(positions(:,:,3)<0.0));
  notpass1 = unique(notpass1);
  pass1 = ones(size(positions,2),1);
  pass1(notpass1)=0;
  pass1 = find(pass1 == 1);
  detector1 = detector(pass1, :);
  positions1 = positions(:,pass1, :);
  bbox1 = bbox(pass1, :);
  
  
  %% 3.1)
  depth = zeros(size(positions1,1), size(positions1, 2));
  nearbyDepths = cell(size(nearbyFilenames));
  for j = 1:length(nearbyFilenames)
    fn = nearbyFilenames{j};
    fn = strrep(fn, 'image02', 'image04');
    fn = strrep(fn, 'jpg', 'png');
    nearbyDepths{j} = imread(fn);
    nearbyDepths{j} = double(nearbyDepths{j}(:,:,1))/1000;
    for k = 1:size(detector1,1)
      depth(j,k) = mean(nonzeros(imcrop(nearbyDepths{j}, bbox1(k,:))));
      % depth(j,k) = nearbyDepths{j}(bbox1(k,2)+bbox1(k,4), bbox1(k,1)+bbox1(k,3));
      if depth(j,k) == 0
        depth(j,k) = NaN;
      end
    end
  end
  pass2 = find(max(isnan(depth))==0);
  detector2 = detector1(pass2, :);
  positions2 = positions1(:,pass2, :);
  bbox2 = bbox1(pass2, :);
  depth = depth(:,pass2);
  
  %% 3.2)
  fx = leftCamParam.IntrinsicMatrix(1,1);
  fy = leftCamParam.IntrinsicMatrix(2,2);
  cx = leftCamParam.IntrinsicMatrix(1,3);
  cy = leftCamParam.IntrinsicMatrix(2,3);
  A = [fx 0 cx; 0 fy cy; 0 0 1];
  p3d = zeros(size(positions2, 1), size(positions2, 2), 3);
  p3d(:,:,1) = (positions2(:,:,1) - cx) /fx .* depth;
  p3d(:,:,2) = (positions2(:,:,2) - cy) /fy .* depth;
  p3d(:,:,3) = depth;
  
  %% 3.3)
  reprojerr = zeros(size(detector2, 1),length(nearbyFilenames));
  for j = 1:size(detector2,1)
    fprintf('geo check:%d\n', j);
    p0 = [0 0 0]';
    for k = 1:length(nearbyFilenames)
      p0 = p0 + squeeze(p3d(k,j,:));
    end
    p0 = p0 / length(nearbyFilenames);
    p = lsqnonlin(@(p)projFunc(p, reshape(positions2(:,j,1:2),2,[]), transforms(:,pass2),A), p0);
    
    err = projFunc(p, reshape(positions2(:,j,1:2),2,[]), transforms(:,pass2),A);
    err = reshape(err, [], 2);
    reprojerr(j,:) = sqrt(err(:,1) .^2 + err(:,2) .^ 2);
  end
  
  %% 3.4)
  geo_check = zeros(size(detector2, 1),1);
  for j = 1:size(detector2,1)
 
    if isempty(find(reprojerr(j,:) > 16, 1)) && sum(reprojerr(j,:)) / length(nearbyFilenames) < 8
      geo_check(j) = 1;
    end
  end
  pass3 = find(geo_check == 1);
  detector3 = detector2(pass3, :);
  bbox3 = bbox2(pass3,:);
  positions3 = positions2(:,pass3,:);
  figure;
  imshow(imread(filenames{B})); hold on;
  for j = 1:size(bbox3,1)
    rectangle('Position', bbox3(j,:), 'EdgeColor', 'r');
  end
  
  %% 3.5)
  figure;
  nearbyImages = cell(length(nearbyFilenames), 1);
  for j = 1:length(nearbyFilenames)
    nearbyImages{j} = imread(nearbyFilenames{j});
  end
  for j = 1:size(detector3,1)
    clf;
    for k = 1:length(nearbyFilenames)
      subplot(ceil(length(nearbyFilenames)/3), 3, k); hold on;
      imshow(nearbyImages{k});
      rectangle('Position', [positions3(k,j,1) positions3(k,j,2) 64 64], 'EdgeColor', 'r');
    end
    title(['landmark ' num2str(j, '%03d')]);
    print(['landmark_' num2str(j, '%03d')], '-dpng');
  end
  
end


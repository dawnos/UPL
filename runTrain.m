
%%
run startup.m;

%%
data_dir = '~/Projects/ZED/D1-P1-L1';
% data_dir = '~/DataBlock/ZED/D1-P1-L1';
[filenames, transforms] = readImageFilenames(data_dir);

%%
bank = generatePlaceBank(transforms);
bank = bank(5);

%%
detectors = cell(1,size(bank,1));
for i = 1:size(bank,1)
  
  B = bank(i);
  
  % train seed detectors
  detectors{i} = generateSeedDetectors(imread(filenames{B}), [64 64]);
  
  % find nearby images
  nearbyFilenames = {};
  nearbyACFs = {};
  nearbyTransforms = [];
  for j = 1:size(transforms,2)
    if norm(transforms(1:3,B) - transforms(1:3,j)) < 1.0
      nearbyFilenames{end+1} = filenames{j};
      nearbyTransforms = [nearbyTransforms transforms(:,j)];
      acf = chnsCompute(imread(nearbyFilenames{end}));
      nearbyACFs{end+1} = cat(3,acf.data{:});
    end
  end

  fprintf('%d nearby image(s) found\n', length(nearbyTransforms));
  
  %{
  xys = zeros(length(nearbyFilenames), size(detectors{i},1), 3);
  for nn = 1:length(nearbyFilenames)
    image = imread(nearbyFilenames{nn});
    descriptor = computeDescriptor(image);
    for d = 1:size(detectors{i},1)
      xys(nn, d,:) = detect(descriptor, detectors{i}(d,:));
    end
  end
  %}
  
end

%%

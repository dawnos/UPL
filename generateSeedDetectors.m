function [detectors, bbox] = generateSeedDetectors(image, ssize)

% Settings
stride = 8;
negCount = 100;
iou = 0.1;

if ischar(image)
  image = imread(image);
end

winWidth = ssize(1);
winHeight = ssize(2);
SS = size(image);
height = SS(1);
width = SS(2);

Nw = (height-winHeight)/stride+1;
Nh = (width-winWidth)/stride+1;


%% Generate bounding box
posbbs = [...
  reshape(repmat(1:stride:(width-winWidth+1), Nw, 1), [], 1)...
  reshape(repmat(1:stride:(height-winHeight+1), 1, Nh), [], 1)...
  repmat(winWidth, Nw * Nh, 1)...
  repmat(winHeight, Nw * Nh, 1)...
  ];

negbbs = [...
  randi(width-winWidth+1, negCount, 1)...
  randi(height-winHeight+1, negCount, 1)...
  repmat(winWidth, negCount, 1)...
  repmat(winHeight, negCount, 1)...
  ];

R = bboxOverlapRatio(posbbs, negbbs);

bbox = posbbs;

posbbs = ceil(posbbs / 4);
negbbs = ceil(negbbs / 4);


%% Compute features
chns = [];
tic;
for gamma = 2.^(-1.5:0.4:0.5)
  for sigma = 0:0.5:2
    augImg = imgaussfilt(imadjust(image, [], [], gamma), sigma+eps);
    C = computeDescriptor(augImg);
    chns = cat(3, chns, C);
  end
end
fprintf('Augmentation and ACF takes %f second(s)\n', toc);

fprintf('Training detectors...\n');
detectors = zeros(size(posbbs,1), winWidth/4 * winHeight/4 * 10);


%% Train
parfor i = 1:size(posbbs,1)
  tic;
  
  %%
  posbb = posbbs(i,:);
  negbb = negbbs(R(i,:) < iou,:);
  %%
  pos = tensorCrops(chns, posbb);
  pos = reshape(pos, winWidth/4 * winHeight/4 * 10, []);
  
  %%
  neg = tensorCrops(chns, negbb);
  neg = reshape(neg, winWidth/4 * winHeight/4 * 10, []);
  
  %%
  label = [ones(size(pos,2), 1); -ones(size(neg,2), 1)];
  data =  [pos neg]';
  data = double(data);
  
  %%
  detector = train(label, sparse(data) ...
    );
  % , ['-w-1 1 -w1 ' num2str(negCount)]);
  % , '-B 1');
  
  detectors(i,:) = detector.w;
  fprintf('detector %d/%d takes %f second(s)\n', i, size(posbbs,1), toc);
end

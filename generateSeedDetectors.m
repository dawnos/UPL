function [detectors, bbox] = generateSeedDetectors(image, ssize)

stride = 8;
negCount = 1000;
iou = 0.5;
   
if ischar(image)
  image = imread(image) / 255;
end

winWidth = ssize(1);
winHeight = ssize(2);
SS = size(image);
height = SS(1);
width = SS(2);

Nw = (height-winHeight)/stride+1;
Nh = (width-winWidth)/stride+1;

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

chns = [];
tic;
for gamma = 2.^(-1.5:0.4:0.5)
  for sigma = 0:0.5:2
    % fprintf('aug a img\n');
    augImg = imgaussfilt(imadjust(image, [], [], gamma), sigma+eps);
    % augImg = imNormalize(augImg);
    % C = chnsCompute(augImg);
    % C = cat(3,C.data{:});
    C = computeDescriptor(augImg);
    chns = cat(3, chns, C);
    % figure; montage2(C);
  end
end
fprintf('Augmentation and ACF takes %f second(s)\n', toc);

fprintf('Training detectors...\n');
detectors = zeros(size(posbbs,1), winWidth/4 * winHeight/4 * 10);

for i = 1:size(posbbs,1)
  tic;
  posbb = posbbs(i,:);
  negbb = negbbs(R(i,:) < iou,:);
  
  pos = tensorCrops(chns, posbb);
  pos = reshape(pos, [], winWidth/4 * winHeight/4 * 10);
  
  neg = tensorCrops(chns, negbb);
  neg = reshape(neg, [], winWidth/4 * winHeight/4 * 10);
  
  label = [zeros(size(pos,1), 1);ones(size(neg,1), 1)];
  data = [pos;neg];
  detector = train(label, sparse(data));
  % detector = train(label, sparse(data), '-n 11');
  detectors(i,:) = detector.w;
  fprintf('detector %d/%d takes %f second(s)\n', i, size(posbbs,1), toc);
end

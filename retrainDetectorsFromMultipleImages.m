% Step 4
function [detectors] = retrainDetectorsFromMultipleImages(...
    nearbyImages, positions, ssize)

% Settings
negCount = 200;
iou = 0.1;


perCount = ceil(negCount/size(positions,1));

winWidth = ssize(1);
winHeight = ssize(2);
SS = size(nearbyImages{1});
height = SS(1);
width = SS(2);

ACFs = cell(1, length(nearbyImages));
for i = 1:length(nearbyImages)
    ACFs{i} = [];
    tic;
    for gamma = 2.^(-1.5:0.4:0.5)
        for sigma = 0:0.5:2
            augImg = imgaussfilt(imadjust(nearbyImages{i}, [], [], gamma), sigma+eps);
            C = computeDescriptor(augImg);
            ACFs{i} = cat(3, ACFs{i}, C);
        end
    end
    fprintf('ACF in %f second(s). %d/%d\n', toc, i, length(nearbyImages));
end

detectors = zeros(size(positions,2), winWidth/4 * winHeight/4 * 10);
parfor dd = 1:size(positions,2)
    tic;
    pos = [];
    neg = [];
    for nn = 1:size(positions,1)
        
        posbb = [squeeze(positions(nn,dd,:))' ssize]/4;
        
        negbb0 = ceil([...
            randi(width-winWidth+1, perCount, 1)...
            randi(height-winHeight+1, perCount, 1)...
            repmat(winWidth, perCount, 1)...
            repmat(winHeight, perCount, 1)...
            ]/4);
        
        R = bboxOverlapRatio(posbb, negbb0);

        negbb = negbb0(R(:) < iou,:);
        
        p = tensorCrops(ACFs{nn}, posbb);
        n = tensorCrops(ACFs{nn}, negbb);
        p = reshape(p, winWidth/4 * winHeight/4 * 10, []);
        n = reshape(n, winWidth/4 * winHeight/4 * 10, []);
        pos = [pos p];
        neg = [neg n];
    end
    
    label = [ones(size(pos,2), 1); -ones(size(neg,2), 1)];
    data =  [pos neg]';
    data = sparse(double(data));
    
    detector = train(label, data , ['-w-1 1 -w1 ' num2str(negCount)]);
    
    detectors(dd,:) = detector.w;
    fprintf('detector %d/%d takes %f second(s)\n', dd, size(positions,2), toc);
end


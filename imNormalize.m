function O = imNormalize(I)

% https://github.com/facebook/fb.resnet.torch/blob/master/datasets/imagenet.lua
RGBmean = [ 0.485, 0.456, 0.406 ];
RGBstd = [ 0.229, 0.224, 0.225 ];

O = zeros(size(I));
for i = 1:3
    O(:,:,i) = I(:,:,i) - RGBmean(i);
end
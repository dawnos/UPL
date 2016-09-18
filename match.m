
%%
I1 = imread('~/Projects/datasets/ZED/D1-P1-L1/image02/data/0000000558.jpg');
% I2 = imread('~/Projects/datasets/ZED/D1-P1-L2/image02/data/0000000510.jpg');
I2 = imread('~/Projects/datasets/ZED/D2-P1-L1/image02/data/0000000510.jpg');
% I2 = imread('~/Projects/datasets/ZED/D1-P1-L1/image02/data/0000000558.jpg');

figure;
subplot(2,2,1); imshow(I1);
subplot(2,2,2); imshow(I2);

%%
points1 = [];
points2 = [];
matches = [];
for i = 1:size(detector3,1)
    [position1, score1] = detect(I1, detector3(i,:));
    [position2, score2] = detect(I2, detector3(i,:));
    points1 = [points1;(position1*4+32)];
    points2 = [points2;(position2*4+32)];
    matches = [matches; i i];
end

%%
subplot(2,2,[3 4]);
showMatchedFeatures(I1,I2,points1,points2, 'montage');

%%
[F,inliersIndex] = estimateFundamentalMatrix(points1, points2, 'Method', 'RANSAC', 'DistanceThreshold', 1);
showMatchedFeatures(I1,I2,points1(inliersIndex,:),points2(inliersIndex, :), 'montage');

%%
[R, t] = cameraPose(F, stereoCamParam.CameraParameters1, points1(inliersIndex,:), points2(inliersIndex, :));

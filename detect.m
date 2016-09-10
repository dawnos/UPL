function [position, score] = detect(I, W)

if ischar(I)
  I = imread(I);
end

if size(I,3) == 3
  I = computeDescriptor(I);
end

if isvector(W)
  S = length(W);
  S = sqrt(S/10);
  W = reshape(W, [S S 10]);
end

C = tensorConv2(I, W);

M = max(max(C));
[y, x] = ind2sub(size(C), find(C==M));

position = [x y];
score = M;


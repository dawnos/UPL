function X = detect(I, W)

t = 0.2;

if ischar(I)
  I = imread(I);
end

if size(I,3) == 3
  I = chnsCompute(I);
  I = cat(3, I.data{:});
end

if isvector(W)
  S = length(W);
  S = sqrt(S/10);
  W = reshape(W, [S S 10]);
end

C = tensorConv2(I, W);

M = max(max(C));
[y, x] = ind2sub(size(C), find(C==M));

X = [x y M];


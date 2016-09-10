function X = detect2(I, W, rect)

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
figure;
imagesc(C); hold on;
%{
rectangle('Position', rect, 'EdgeColor', 'red');
%}
axis equal;
X = C;



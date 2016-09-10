function F = tensorCrops(I, rect)

assert(size(rect,2) == 4);

% F = zeros(size(rect,1), rect(1,3)*rect(1,4)*size(I,3));
F = [];
for i = 1:size(rect, 1)
  A = tensorCrop(I, rect(i,:));
  % F(i,:) = A(:)';
  F = [F A(:)'];
end
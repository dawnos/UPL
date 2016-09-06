function F = crops(I, rect)

assert(size(rect,2) == 4);

F = zeros(size(rect,1), rect(1,3)*rect(1,4)*size(I,3));
for i = 1:size(rect, 1)
  A = crop(I, rect(i,:));
  F(i,:) = A(:)';
end
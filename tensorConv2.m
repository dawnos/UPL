function C = tensorConv2(A, B)

assert(size(A,3) == size(B,3));
C = zeros(size(A,1), size(A,2));
for i = 1:size(A,3)
  C = C + conv2(A(:,:,i), B(:,:,i), 'same');
end
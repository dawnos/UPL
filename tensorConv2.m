function C = tensorConv2(A, B)

assert(size(A,3) == size(B,3));
[ma,na,~] = size(A);
[mb,nb,~] = size(B);
C = zeros(max([ma-max(0,mb-1), na-max(0,nb-1)],0));
for i = 1:size(A,3)
  C = C + conv2(A(:,:,i), B(:,:,i), 'valid');
end
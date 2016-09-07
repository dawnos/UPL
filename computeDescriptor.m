function D = computeDescriptor(I)

if ischar(I)
  I = imread(I);
end

D = chnsCompute(I);
D = cat(3, D.data{:});
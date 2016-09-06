function O = tensorCrop(I, rect)

assert(isvector(rect) && length(rect) == 4);
% fprintf('(%f,%f) - %fx%f\n', rect(2), rect(1), rect(4), rect(3));
O = I(rect(2):(rect(2)+rect(4)-1), rect(1):(rect(1)+rect(3)-1), :);
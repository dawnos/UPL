function e = projFunc(x, positions, transforms, A)

% x(3) = 1/x(3);
p = zeros(3,size(positions,1));
for i = 1:size(positions,1)
  %   t = transforms(1:3, i);
  %   q = transforms([5 6 7 4], i);
  %   R = quat2rotm(q);
  %   p(:,i) = R\(x-t);
  
  % T = transforms{i};% * [0 0 1 0;-1 0 0 0;0 -1 0 0;0 0 0 1];
  p(:,i) = transforms{i}(1:3,1:3) \ x - transforms{i}(1:3,4);
  % p(:,i) = T(1:3,1:3)\(x-T(1:3,4));
  % p(:,i) = [0 0 1;-1 0 0;0 -1 0] \ p(:,i);
end

pp = A * p;
u = pp(1,:)./pp(3,:);
v = pp(2,:)./pp(3,:);

e = positions(:) - [u v]';
% e = norm(positions - [u;v]);
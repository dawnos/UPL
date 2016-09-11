function [filenames, transforms] = readImageFilenames(data_dir)

interval = 0.1;

fid = fopen(fullfile(data_dir, 'transform.txt'));
transforms = fscanf(fid, '%f', [7 inf]);
N = size(transforms, 2);
filenames = cellstr(cat(2, ...
  repmat([data_dir '/image02/data/'], [N 1]), ...
  num2str((0:(N-1))', '%010d'), ...
  repmat('.jpg', [N 1])));

if 1
  KF = 1;
  for i = 1:N
    if norm(transforms(1:3,i) - transforms(1:3,KF(end))) > interval
      KF = [KF i];
    end
  end
  transforms = transforms(:,KF);
  filenames = filenames(KF);
end

transforms1 = cell(size(transforms,2),1);
for i=1:size(transforms,2)
  R = quat2rotm(transforms([5 6 7 4],i));
  t = transforms(1:3,i);
  transforms1{i} = [R t;0 0 0 1];
end
transforms = transforms1;

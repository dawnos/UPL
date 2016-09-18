function [filenames, transforms, stereoCamParam] = ...
  readImageFilenames(data_dir)

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
  R = quat2rotm(transforms(4:7,i));
  t = transforms(1:3,i);
  transforms1{i} = [R t;0 0 0 1];
end
transforms = transforms1;

calib = loadCalibrationCamToCam(fullfile(data_dir, 'calib_cam_to_cam.txt'));

leftCamParam = cameraParameters('IntrinsicMatrix', calib.K{1});
rightCamParam = cameraParameters('IntrinsicMatrix', calib.K{2});
stereoCamParam = stereoParameters(leftCamParam, rightCamParam, ...
  calib.R{2}, calib.T{2});

% n = length(filenames);
filenames1 = cell(length(filenames)*2, 1);
transforms1 = cell(length(filenames)*2, 1);
for i=1:length(filenames)
  filenames1{i*2-1} = filenames{i};
  filenames1{i*2  } = strrep(filenames{i}, 'image02', 'image03');
  transforms1{i*2-1} = transforms{i};
  transforms1{i*2  } = [calib.R{2} calib.T{2};0 0 0 1] * transforms{i};
end
filenames = filenames1;
transforms = transforms1;

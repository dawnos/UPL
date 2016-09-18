function stereoCamParam = readZEDConf(filename)

zed = ini2struct(filename);
leftCamParam = cameraParameters('IntrinsicMatrix', [...
  str2double(zed.left_cam_vga.fx) 0 str2double(zed.left_cam_vga.cx)
  0 str2double(zed.left_cam_vga.fy) str2double(zed.left_cam_vga.cy)
  0 0 1
  ]);
rightCamParam = cameraParameters('IntrinsicMatrix', [...
  str2double(zed.right_cam_vga.fx) 0 str2double(zed.right_cam_vga.cx)
  0 str2double(zed.right_cam_vga.fy) str2double(zed.right_cam_vga.cy)
  0 0 1
  ]);
stereoCamParam = stereoParameters(leftCamParam, rightCamParam, eye(3), [str2double(zed.stereo.baseline/1000) 0 0]);
stereoCamParam.WorldUnits = 'm';
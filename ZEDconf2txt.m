function ZEDconf2txt(infile, outfile, type, camId)

param = ini2struct(infile);

if strcmp(type, '2k') == true
  S = [2208 1242];
  lp = param.left_cam_2k;
  rp = param.right_cam_2k;
elseif strcmp(type, 'fhd') == true
  S = [1920 1080];
  lp = param.left_cam_fhd;
  rp = param.right_cam_fhd;
elseif strcmp(type, 'hd') == true
  S = [1280 720];
  lp = param.left_cam_hd;
  rp = param.right_cam_hd;
elseif strcmp(type, 'vga') == true
  S = [672 376];
  lp = param.left_cam_vga;
  rp = param.right_cam_vga;
else
  error('type %s not found', type);
end

  Kl = [str2double(lp.fx) 0 str2double(lp.cx);0 str2double(lp.fy) str2double(lp.cy);0 0 1];
  Dl = [0 0 0 0 0];
  Kr = [str2double(rp.fx) 0 str2double(rp.cx);0 str2double(rp.fy) str2double(rp.cy);0 0 1];
  Dr = [0 0 0 0 0];
  R = eye(3);
  T = [0 -str2double(param.stereo.baseline)/1000 0]';
 
  fid = fopen(outfile, 'w');
  
  fprintf(fid, 'calib_time: %s\n', datetime);
  
  writeVariable(fid, 'S', camId, S);
  writeVariable(fid, 'K', camId, Kl);
  writeVariable(fid, 'D', camId, Dl);
  writeVariable(fid, 'R', camId, R);
  writeVariable(fid, 'T', camId, [0 0 0]');
  
  writeVariable(fid, 'S', camId+1, S);
  writeVariable(fid, 'K', camId+1, Kr);
  writeVariable(fid, 'D', camId+1, Dr);
  writeVariable(fid, 'R', camId+1, R);
  writeVariable(fid, 'T', camId+1, T);
  
  function writeVariable(fid, name, camId, A)
    fprintf(fid, '%s_%02d:', name, camId);
    A = A';
    fprintf(fid, ' %e', A(:));
    fprintf(fid, '\n');
  end

end
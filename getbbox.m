
width = 672;
height = 376;
stride = 8;
NW = (width-64) / stride+1;
NH = (height-64) / stride+1;
[x, y] = ginput;

x
y
(floor(x/stride)) * NH + floor(y/stride)
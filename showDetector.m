idx = 2;
figure;
for i=1:length(nearbyFilenames)
  subplot(ceil(length(nearbyFilenames)/5),5,i);
  imshow(nearbyImages{i});
  rectangle('Position', [positions3(i,idx,1), positions3(i,idx,2), 64, 64], 'EdgeColor', 'red');
end
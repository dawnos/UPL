
%%
figure;
for i = 1:length(nearbyFilenames)
  subplot(ceil(length(nearbyFilenames)/5), 5, i);
  I = insertObjectAnnotation(nearbyImages{i}, 'rectangle', ...
    [squeeze(positions3(i,:,:)) repmat(64, size(positions3,2), 2)], ...
    cellstr(num2str((1:size(positions3,2))')), ...
    'Color', 'r', 'FontSize', 8, 'LineWidth', 2);
  imshow(I);
end


%%
figure;
% for i = 1:size(locations,2)
%   
% end
nn = size(positions3,1)/2+1;
I = insertObjectAnnotation(imread(nearbyFilenames{nn}), 'rectangle', ...
  [squeeze(positions3(nn,:,:)) repmat(64, size(positions3,2), 2)], ...
  cellstr(num2str(squeeze(locations(3,:)'))), ...
  'Color', 'r', 'FontSize', 8);
imshow(I);


%%
figure;
nn = size(positions3,1)/2+1;
imshow(nearbyImages{nn}); hold on;
% plot(positions3(nn,:,1), positions3(nn,:,2), 'o', 'Color', 'red');
h=textfit(positions3(nn,:,1), positions3(nn,:,2), ...
  cellstr(num2str(squeeze(locations(3,:)'))), 'Color', 'r');
% annotation('textarrow',positions3(nn,:,1), positions3(nn,:,2), ...
%   'String', cellstr(num2str(squeeze(locations(3,:)'))));

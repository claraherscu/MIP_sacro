function [ heatMap ] = createBBoxHeatMap ( bboxesFileName )
%createBBoxHeatMap take all the bounding boxes from the file and create a
%heat map of their locations
%   input: bboxesFileName - the file name for the bboxes
%   output: a heat map 

% opening file to read from
fd = fopen(bboxesFileName, 'r');

% scanning the file
formatSpec = '%d %d %d %d %d %d %d %d';
c = textscan(fd, formatSpec);
c = cell2mat(c);

fclose(fd);

% initializing heatmap
heatMap = zeros(512,512);
% creating heatmap
for i=1:size(c,1)
curr_points = c(i,:);
curr_points = reshape(curr_points, 2,4);
curr_points = transpose(curr_points);
mask = roipoly(heatMap, curr_points(:,1), curr_points(:,2));
heatMap = heatMap + mask;
end

end

% 
% function [heatMap] = rowHeatMap (heatMap, curr_points)
% % a helper function to be applied on each row of matrix c
% 
% curr_points = reshape(curr_points, 2,4);
% curr_points = transpose(curr_points);
% mask = roipoly(heatMap, curr_points(:,1), curr_points(:,2));
% heatMap = heatMap + mask;
% 
% end

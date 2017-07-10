function [ outliers, outliersHeat ] = detectHeatmapOutliers( thresholdedHeat, bboxesFile, originalHeat )
%detectHeatmapOutliers find outliers in terms of location
%   comparing the window location to the heatMap - if the window is too far
%   away from the heatmap peak, it is tagged as an outlier
%   INPUTS: heatMap = the heatmap, thresholded

% opening file to read from
fd1 = fopen(bboxesFile, 'r');

% scanning the file
formatSpec = '%d %d %d %d %d %d %d %d';
c = textscan(fd1, formatSpec);
c = cell2mat(c);

outliersHeat = zeros(size(originalHeat));

outliers = zeros(size(c,1));

for i = 1:size(c,1)
    curr_points = c(i,:);
    curr_points = reshape(curr_points, 2,4);
    curr_points = transpose(curr_points);
    mask = flipud(roipoly(thresholdedHeat, curr_points(:,1), curr_points(:,2)));
    
    localHeat = thresholdedHeat;
    localHeat(imcomplement(mask)) = 0;
    if(sum(localHeat(:)) < 50)
        outliers(i) = 1;
        outliersHeat = outliersHeat + mask;
    end
end

fclose(fd1); % fclose(fd2);
end

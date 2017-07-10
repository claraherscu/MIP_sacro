% test windows quality
basefolder = '/cs/casmip/clara.herscu/git/MIP_sacro/dataset/bboxes_per_slice/';

% % get HeatMap
% bboxesFileLeft = [basefolder 'coordsLeftOnly.txt'];
% leftHeatMap = createBBoxHeatMap(bboxesFileLeft);
% leftHeatMap = flipud(leftHeatMap);
% image(leftHeatMap);
% title('Left Side Windows Heatmap');
% 
bboxesFileRight = [basefolder 'coordsRightOnly.txt'];
rightHeatMap = createBBoxHeatMap(bboxesFileRight);
rightHeatMap = flipud(rightHeatMap);
figure;
image(rightHeatMap);
title('Right Side Windows Heatmap');
% 
% jointHeatMap = rightHeatMap + leftHeatMap;
% figure;
% image(jointHeatMap);
% title('Both Sides Windows Heatmap');

% detect outliers
thresholdedLeft = leftHeatMap;
thresholdedLeft(leftHeatMap < 100) = 0;
[ outliersLeft, outliersHeat ] = detectHeatmapOutliers(thresholdedLeft, bboxesFileLeft, leftHeatMap);
outliersLeft = find(outliersLeft, length(outliersLeft), 'first');

accessNumsFileLeft = [basefolder 'accessNumLeftDelimeter.txt'];
fd = fopen(accessNumsFileLeft, 'r');
accessNums = textscan(fd, '%s %s', 'Delimiter', '-');
accessNumsMat = [accessNums{:}];
display(accessNumsMat(outliersLeft,:));
fclose(fd);

image(outliersHeat);

outliersLeftFile = [basefolder 'outliersLeft.txt'];
outliersfd = fopen(outliersLeftFile, 'w');
fprintf(outliersfd, '%s\n', accessNumsMat{outliersLeft,1});
fclose(outliersfd);

% now to the right side
% detect outliers
thresholdedRight = rightHeatMap;
thresholdedRight(rightHeatMap < 100) = 0;
[ outliersRight, outliersHeat ] = detectHeatmapOutliers(thresholdedRight, bboxesFileRight, rightHeatMap);
outliersRight = find(outliersRight, length(outliersRight), 'first');

accessNumsFileRight = [basefolder 'accessNumRightDelimeter.txt'];
fd = fopen(accessNumsFileRight, 'r');
accessNums = textscan(fd, '%s %s', 'Delimiter', '-');
accessNumsMat = [accessNums{:}];
display(accessNumsMat(outliersRight,:));
fclose(fd);

image(outliersHeat);

outliersRightFile = [basefolder 'outliersRight.txt'];
outliersfd = fopen(outliersRightFile, 'w');
fprintf(outliersfd, '%s\n', accessNumsMat{outliersRight,1});
fclose(outliersfd);


%% let's take a look at the big windows too
% get HeatMap
bboxesFileLeft = [basefolder 'bigBBoxesCoordsLeft.txt'];
leftHeatMap = createBBoxHeatMap(bboxesFileLeft);
leftHeatMap = flipud(leftHeatMap);
image(leftHeatMap);
title('Left Side Big Windows Heatmap');

bboxesFileRight = [basefolder 'bigBBoxesCoordsRight.txt'];
rightHeatMap = createBBoxHeatMap(bboxesFileRight);
rightHeatMap = flipud(rightHeatMap);
figure;
image(rightHeatMap);
title('Right Side Big Windows Heatmap');

jointHeatMap = rightHeatMap + leftHeatMap;
figure;
image(jointHeatMap);
title('Both Sides Big Windows Heatmap');

% test file designated for testing the minCut operations, disregarding the 
% data that did not do successfull hips segmentation.

load matlabData;
basefolder = 'sacro/dataset/';
dataWithCanny = data;

% defining a container for all the places where i identified a clear 
% problem in hips segmentation. (containes their accessNums)
problematicHipsSegment = {};

% these first two are not even pelvis area.
problematicHipsSegment{end+1} = '4015005386642';
problematicHipsSegment{end+1} = '4015005763550';

% these 3 include both hips and rib cage.
problematicHipsSegment{end+1} = '4015005378993';
problematicHipsSegment{end+1} = '4015004843912';
problematicHipsSegment{end+1} = '4015006233633';

% these 2 have internal organs.
problematicHipsSegment{end+1} = '4015005435619';
problematicHipsSegment{end+1} = '4015006182930';



% for i = 1:numel(dataWithCanny)
for i = 1
    fPath = [basefolder, dataWithCanny{i}.accessNum];
    if any(~isequal(dataWithCanny{i}.accessNum, problematicHipsSegment))
        if exist(fPath,'file') 
            display(fPath);
            filename = [basefolder, dataWithCanny{i}.accessNum];               
            tic; [seg, score, noise] = segmentSij(filename,''); toc;
        end
    end
end

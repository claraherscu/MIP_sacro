load matlabData;
basefolder = 'sacro/dataset/';
dataWithCanny = data;

% defining a container for all the places where i identified a clear 
% problem in hips segmentation. (containes their accessNums)
% problematicHipsSegment = {};

% these first two are not even pelvis area.
% --- turning these pictures upside down did not help! this is not the 
% problem ---
% problematicHipsSegment{end+1} = '4015005386642';
% problematicHipsSegment{end+1} = '4015005763550';

% these 3 include both hips and rib cage.
% --- in the first 2 of them, this condition was never met: 
% convhullWidth(end) < max(convhullWidth)*Rconv 
% they also both have internal organs in the picture ---
% ** the big error here is hipsEnd, we could live with hipsStart **
% problematicHipsSegment{end+1} = '4015005378993';
% problematicHipsSegment{end+1} = '4015004843912';
% --- in this one i think that the problem is setting the wrong hipsStart
% parameter: [~,j] = min(spinePixels); hipsStart = hipsEnd - j + 1; 
% this file is also corrupted like the first two which return a vertebra.
% this also happens on the previous 2 so maybe it's the problem ---
% ** hips are at ~140-190 but segmentation returns 3-270 **
% problematicHipsSegment{end+1} = '4015006233633';

% these 2 have internal organs.
% problematicHipsSegment{end+1} = '4015005435619';
% --- this one was segmented correctly despite this fact, the first one 
% wasn't ---
% problematicHipsSegment{end+1} = '4015006182930';

% adding a good hips segmentation for reference:
% problematicHipsSegment{end+1} = '4015005330771';


% for i = 1:numel(problematicHipsSegment)
%     fPath = [basefolder, problematicHipsSegment{i}];
%     if exist(fPath,'file') 
%         display(fPath);
%         filename = [basefolder, problematicHipsSegment{i}];               
%         tic; [ hipsSeg ] = segmentHipsAndSave(filename,'Hips'); toc;
%     end
<<<<<<< HEAD
% end


for i = 1:numel(dataWithCanny)
    fPath = [basefolder, dataWithCanny{i}];
    if exist(fPath,'file') 
        display(fPath);
        filename = [basefolder, dataWithCanny{i}];               
        dicomInfo = dicom_folder_info(fPath);
        display('resolusion details:');
        display(dicomInfo.scales(3));
    end
end
=======
% end
>>>>>>> origin/master

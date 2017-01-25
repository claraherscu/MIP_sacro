load matlabData;
basefolder = 'D://MIP_sacro/sacro/dataset/';
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
%         tic; [ seg, ~, ~ ] = segmentSij(filename,'Hips'); toc;
%         segFile = [fPath '/segmentation'];
%         save(segFile, 'seg', 'info');
%     end
% end

count = 0;
for i = 1:numel(dataWithCanny)
%     fPath = [basefolder, dataWithCanny{i}];
    if exist(fPath,'file') 
        filename = [basefolder, dataWithCanny{i}.accessNum];               
        dicomInfo = dicom_folder_info(filename);
        if(dicomInfo.Scales(3) > 2)
            display(dataWithCanny{i}.accessNum);
            display(['resolusion details:' num2str(dicomInfo.Scales(3))]);
            count = count + 1;
        else
            display('resolution OK. skipped');
        end
    end
end
display(['total amount of images with bad resolution', num2str(count)]);

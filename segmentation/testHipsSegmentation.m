load matlabData;
basefolder = 'sacro/dataset/';
dataWithCanny = data;

% defining a container for all the places where i identified a clear 
% problem in hips segmentation. (containes their accessNums)
problematicHipsSegment = {};

% these first two are not even pelvis area.
% --- i think the problem is that the picture is upside-down ---
% problematicHipsSegment{end+1} = '4015005386642';
% problematicHipsSegment{end+1} = '4015005763550';

% these 3 include both hips and rib cage.
% --- in the first 2 of them, this condition was never met: 
% convhullWidth(end) < max(convhullWidth)*Rconv 
% they also both have internal organs in the picture ---
% problematicHipsSegment{end+1} = '4015005378993';
% problematicHipsSegment{end+1} = '4015004843912';
% --- in this one i think that the problem is setting the wrong hipsStart
% parameter: [~,j] = min(spinePixels); hipsStart = hipsEnd - j + 1;
% this also happens on the previous 2 so maybe it's the problem ---
% problematicHipsSegment{end+1} = '4015006233633';

% these 2 have internal organs.
% problematicHipsSegment{end+1} = '4015005435619';
% --- this one was segmented correctly despite this fact, the first one 
% wasn't ---
% problematicHipsSegment{end+1} = '4015006182930';


for i = 1:numel(problematicHipsSegment)
    fPath = [basefolder, problematicHipsSegment{i}];
%     disp(fPath);
    hipsFile = [fPath '/segmentationWithCanny.mat'];
    if exist(fPath,'file') 
        sdisplay(fPath);
        filename = [basefolder, problematicHipsSegment{i}];               
        tic; [ hipsSeg ] = segmentHipsAndSave(filename,'withCanny'); toc;
%         hipsFile = [fPath '/segmentationWithCanny'];
%         save(hipsFile, 'hipsSeg');
    end
end

    

% original test code, saving for later
% for i = 1:numel(dataWithCanny)
%     fPath = [basefolder, dataWithCanny{i}.accessNum];
%     disp(fPath);
%     hipsFile = [fPath '/segmentationWithCanny.mat'];
%     if exist(fPath,'file') 
%         display(fPath);
% 
%         if exist(hipsFile,'file') > 0
%             display('Already segmented');
%         %    continue;
%         end
%         filename = [basefolder, dataWithCanny{i}.accessNum];               
%         tic; [ hipsSeg ] = segmentHipsAndSave(filename,'withCanny'); toc;
%         hipsFile = [fPath '/segmentationWithCanny'];
%         save(hipsFile, 'hipsSeg');
%     end
% end
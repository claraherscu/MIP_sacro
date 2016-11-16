load matlabData;
basefolder = 'sacro/dataset/';
dataWithCanny = data;

% defining a container for all the places where i identified a clear 
% problem in hips segmentation. (containes their accessNums)
problematicHipsSegment = {};
% these first two are not even pelvis area
problematicHipsSegment{end+1} = '4015005386642';
problematicHipsSegment{end+1} = '4015005763550';


for i = 1:numel(problematicHipsSegment)
    fPath = [basefolder, problematicHipsSegment{i}];
    disp(fPath);
    hipsFile = [fPath '/segmentationWithCanny.mat'];
    if exist(fPath,'file') 
        display(fPath);
        filename = [basefolder, problematicHipsSegment{i}.accessNum];               
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
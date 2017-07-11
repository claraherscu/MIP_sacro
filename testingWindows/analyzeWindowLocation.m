% find the geometrical clues for locating a heuristic window
load matlabData;
basefolder = '/cs/casmip/clara.herscu/git/MIP_sacro/dataset/';

% open file to write to
logPelvisFile = [basefolder 'bboxes_per_slice/log_pelvis.txt'];
fd = fopen(logPelvisFile, 'w');

format_xmin = '%s %d xmin %d\n';
formt_xmax = '%s %d xmax %d\n';
format_ymin = '%s %d ymin %d\n';
formt_ymax = '%s %d ymax %d\n';
format_xmiddle = '%s %d xmiddle %d\n';

for i = 1:numel(data)
    d = data{i};
    % loading hipsSeg
    hipsSegPath = [basefolder data{i}.accessNum '/hipsSeg.mat'];
    if(~exist(hipsSegPath, 'file'))
        continue
    end
    load(hipsSegPath);
    disp(i);
    
    % per slice, get hipsMiddle and hipsEdges, and compare to bbox edges
    for sliceNum = 1:size(hipsSeg,3)
        % square = [xmin xmax ymin ymax]
        square = getConvhullSquare(hipsSeg(:,:,sliceNum));
        if(max(square(:)) == 0)
            continue;
        end
        
        % hipsMiddle for current slice
        xMiddle = floor((square(2) + square(1))/2);
        fprintf(fd, format_xmin, d.accessNum, sliceNum, square(1));
        fprintf(fd, formt_xmax, d.accessNum, sliceNum, square(2));
        fprintf(fd, format_ymin, d.accessNum, sliceNum, square(3));
        fprintf(fd, formt_ymax, d.accessNum, sliceNum, square(4));
        fprintf(fd, format_xmiddle, d.accessNum, sliceNum, xMiddle);
    end
end

fclose(fd);


% for i = 1:1 %numel(data)
%     d = data{i};
%     
%     pixelSz = info.score(1,end-3);
%     % loading hipsSeg
%     hipsSegPath = [basefolder data{i}.accessNum '/hipsSeg.mat'];
%     load(hipsSegPath);
%     % loading borderSeg
%     segBorderFile = [basefolder, d.accessNum, '/segBorderEqualized.mat'];
%     load(segBorderFile);
%     % loading bellman ford borderSeg if exists
%     segBorderFile = [basefolder, d.accessNum, '/segBorderBellmanFordEqualized.mat'];
%     if(exist(segBorderFile,'file'))
%         load(segBorderFile);
%         segBorder = newSegBorder;
%     end
% 
%     % get the bboxes ??
%     
% end
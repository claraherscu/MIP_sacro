basefolder = 'D://MIP_sacro/sacro/dataset/';
for i = 2%1:numel(data)
    d = data{i};
    segR = [d.accessNum, 'R'];
    segL = [d.accessNum, 'L'];
    segfile = [basefolder, d.accessNum,'/segmentation.mat'];
    if exist(segfile,'file')
        clear segBones;
        load(segfile)
        if exist('seg','var')               
            disp(d.accessNum);
            % fixFile = ['sacro/dataset/', d.accessNum, '/segmentationWithCannyFixed'];
            % load(fixFile);
            pixelSz = info.score(1,end-3);
            pixelZSz = info.score(1,end-2);
            segBorder = segmentRelevantBorders(seg,pixelSz,pixelZSz);
%             segBorder = segmentRelevantBorders(seg,pixelSz);
            outfile = [basefolder, d.accessNum, '/segBorder'];
            save(outfile, 'segBorder', 'info', 'segBorder');
            saveBorderSeg(segBorder.L, segBorder.R, [basefolder d.accessNum], 'segBorder');
        end
    end
end
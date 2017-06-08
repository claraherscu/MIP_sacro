load matlabData;
basefolder = 'D://MIP_sacro/sacro/dataset/';
dataWithCanny = data;
for i =157%:160%:numel(dataWithCanny)
    fPath = [basefolder, dataWithCanny{i}.accessNum];
    disp(fPath);
    segFile = [fPath '/segmentation.mat'];
    if exist(fPath,'file') 
        display(fPath);
        if exist(segFile,'file') > 0
            display('Already segmented');
%             continue;
        end
        filename = [basefolder, dataWithCanny{i}.accessNum];               
        tic; [seg, score, noise] = segmentSij(filename); toc;
        dataWithCanny{i}.noise = noise;        
        dataWithCanny{i}.score = score;
        info = dataWithCanny{i};
        segFile = [fPath '/segmentation'];
        save(segFile, 'seg', 'info');
    end
end

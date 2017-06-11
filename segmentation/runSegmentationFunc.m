function [] = runSegmentationFunc (basefolder, data, start_index, end_index)
    dataWithCanny = data;
    for i = start_index:end_index
        fPath = [basefolder, dataWithCanny{i}.accessNum];
        display([fPath ' index=' num2str(i)]);
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
end
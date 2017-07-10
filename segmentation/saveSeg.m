function saveSeg ( segL, segR, fPath, outname)
    segResult = fliplr(segL + segR);
    %newfPath = strrep(fPath, '/', '\');
    dicm2nii(fPath, fPath, 'nii.gz');
    file = dir([fPath '/*.nii.gz']);
    filename = ['/' file(1).name];
    display(['loading ' fPath filename]);
    niiStruct = load_untouch_nii_gzip([fPath filename]);
    niiStruct.img = segResult;
    % saving as a new nifty file
    save_untouch_nii_gzip(niiStruct, [fPath '/' outname '.nii.gz']);
end


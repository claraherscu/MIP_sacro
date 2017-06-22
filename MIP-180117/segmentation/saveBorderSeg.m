function saveBorderSeg ( segL, segR, fPath, outname)
    segResult = fliplr(segL + segR);
    file = dir([fPath '/seg.nii.gz']);
    filename = ['/' file.name];
    display(['loading ' fPath filename]);
    niiStruct = load_untouch_nii_gzip([fPath filename]);
    niiStruct.img = segResult;
    % saving as a new nifty file
    save_untouch_nii_gzip(niiStruct, [fPath '/' outname '.nii.gz']);
end



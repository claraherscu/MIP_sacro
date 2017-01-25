function saveBorderSeg ( segL, segR, fPath, outname)
    segResult = fliplr(segL + segR);
    newfPath = strrep(fPath, '/', '\');
    file = dir([newfPath '\seg.nii.gz']);
    filename = ['\' file.name];
    display(['loading ' newfPath filename]);
    niiStruct = load_untouch_nii_gzip([newfPath filename]);
    niiStruct.img = segResult;
    % saving as a new nifty file
    save_untouch_nii_gzip(niiStruct, [newfPath '\' outname '.nii.gz']);
end



function saveSeg ( segL, segR, fPath, outname)
    segResult = fliplr(or(segL, segR));
    newfPath = strrep(fPath, '/', '\');
    dicm2nii(newfPath, newfPath, 'nii.gz');
    file = dir([newfPath '\*.nii.gz']);
    filename = ['\' file(1).name];
    display(['loading ' newfPath filename]);
    niiStruct = load_untouch_nii_gzip([newfPath filename]);
    niiStruct.img = segResult;
    % saving as a new nifty file
    save_untouch_nii_gzip(niiStruct, [newfPath '\' outname '.nii.gz']);
end


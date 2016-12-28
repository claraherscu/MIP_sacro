function [ seg, score, noise ] = segmentSijTestParam( fPath, outfile, iliumParam )
%SEGMENTSIJTESTPARAM Run segmentation on the SacroIlium Joint
%   testing the ilium init param
[basefolder, folder] = fileparts(fPath);
if exist([fPath,'/',folder,'.mat'],'file')
    load([fPath,'/',folder,'.mat'])
else
    dicomInfo = dicom_folder_info(fPath);
    vol = dicom_read_volume(fPath);
end
slices = size(vol,3); display(slices);
vol = dicom2niftiVol(vol, dicomInfo);
bonesSeg = getBones(vol, 0);
hipsSeg = getHips(bonesSeg, 0, vol); clearvars bonesSeg;
[segR, cutR] = minCutHipsTestParam(vol, dicomInfo, hipsSeg, 'right', 10, iliumParam);
[segL, cutL] = minCutHipsTestParam(vol, dicomInfo, hipsSeg, 'left', 10, iliumParam);
if exist('outfile','var')
    close all;
    try
        picsSeries(segR, vol, [basefolder, '/', folder, '/', folder, '_', outfile, 'R.jpg']);
        picsSeries(segL, vol, [basefolder, '/', folder, '/', folder, '_', outfile, 'L.jpg']);
    catch
        display('Problem showing the images');
    end
end
scoreL = scoreSegmentation(segL,vol,dicomInfo,'left');
scoreR = scoreSegmentation(segR,vol,dicomInfo,'right');
score = [scoreL cutL;scoreR cutR];
noise = getNoiseValue(vol);
seg.L = segL;
seg.R = segR;
end


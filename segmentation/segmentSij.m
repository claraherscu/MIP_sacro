function [ seg, score, noise ] = segmentSij( fPath, outfile  )
%SEGMENTSIJ Run segmentation on the SacroIlium Joint
% We need to point the folder containing the DICOM files.
% Optional
%  - boolean outfile: 
%        Specify if we want to generate a jpg image with the output results

[basefolder, folder] = fileparts(fPath);
dicomInfo = dicom_folder_info(fPath);
vol = dicom_read_volume(fPath);
slices = size(vol,3); display(slices);
vol = dicom2niftiVol(vol, dicomInfo);

%vol = load_untouch_nii_gzip([fPath '/*.nii.gz']);
% save([fPath, '/', folder, '.mat'], 'vol');
bonesSeg = getBones(vol, 0);
hipsSeg = getHips(bonesSeg, 0, vol); 

% saving for later
hipsSegMatPath = [fPath '/hipsSeg.mat'];
save(hipsSegMatPath, 'hipsSeg');
% hipsSegNiiPath = [fPath '/hipsSeg.nii.gz'];
% saveSeg(hipsSeg, int8(zeros(size(hipsSeg))), fPath, 'hipsSeg'); 

%fPathForHipsSave = strrep(fPath, '/', '\');
[segR, cutR, hipsCTRight] = minCutHips(vol, dicomInfo, hipsSeg, 'right', 10);
[segL, cutL, hipsCTLeft] = minCutHips(vol, dicomInfo, hipsSeg, 'left', 10);
saveSeg(hipsCTLeft, hipsCTRight, fPath, 'pelvis_equalized');

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
saveSeg ( segL, segR, fPath, 'seg' );
seg.L = segL;
seg.R = segR;
end



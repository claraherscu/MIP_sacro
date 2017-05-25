load matlabData;
basefolder = 'D://MIP_sacro/sacro/dataset/';

for i = 1%:numel(data)
    tic;
    disp(['Working on ' num2str(i)]);
    
    folder = data{i}.accessNum;
    dicomInfo = dicom_folder_info([basefolder folder]);
    vol = dicom_read_volume([basefolder folder]);
    vol = dicom2niftiVol(vol, dicomInfo);
    
    slices = size(vol,3);
    newfPath = strrep([basefolder, data{i}.accessNum], '/', '\');
    % would like to work on the roi of the pelvis
    pelvis = load([newfPath '\hipsSeg.mat']);

    pelvis_roi = int16(vol).*int16(pelvis.img);

    pelvis_roi_equalized = EqualizeSingleImageHistogram(pelvis_roi);
    
    % save equalized image
    save([newfPath '\pelvis_eauqlized.mat'], 'pelvis_roi_equalized');
%     pelvis.img = pelvis_roi_equalized;
%     save_untouch_nii_gzip(pelvis, [newfPath '\pelvis_equalized.nii.gz']);
    toc;
end

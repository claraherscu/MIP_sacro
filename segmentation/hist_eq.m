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
    pelvis = load_untouch_nii_gzip([newfPath '\hipsSeg.nii.gz']);
    
    pelvis_roi = int16(vol).*int16(pelvis.img);

    % create commulative histogram of every image
    clear all_values; 
    for sliceNum = 1:slices
        slice = pelvis_roi(:,:,sliceNum);
        slice_roi_gray = int16(mat2gray(slice)*255);
    
        if (~exist('all_values', 'var'))
            all_values = slice_roi_gray(slice_roi_gray>0);
        else
            all_values = [all_values; slice_roi_gray(slice_roi_gray>0)];
        end
    end
    
    % for every possible value, multiply with corresponding eq parameter
    [~, pelvis_histogram_eq] = histeq(all_values(:));
    pelvis_gray = int16(mat2gray(pelvis_roi)*255);
    pelvis_roi_equalized = pelvis_gray;
    for j = 1:255
        values_to_multiply = find(pelvis_gray == j);
        pelvis_roi_equalized(values_to_multiply) = ...
            pelvis_gray(values_to_multiply)*pelvis_histogram_eq(j);
    end
    
    % save equalized image
    pelvis.img = pelvis_roi_equalized;
    save_untouch_nii_gzip(pelvis, [newfPath '\pelvis_equalized.nii.gz']);
    toc;
end

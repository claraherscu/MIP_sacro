%TRAIN_RANDOM_FOREST uses existing segmentations of relevant sink and
%source points in order to train a decision forest to help us find the best
%points in the future

load matlabData;
basefolder = 'D://MIP_sacro/sacro/dataset/';

%% creating train set
all_images_lines = [];
for i = 1:8%numel(data)
    s_t_seg_file = [basefolder, data{i}.accessNum, '/s_t_seg.nii.gz'];
    if (exist(s_t_seg_file, 'file'))
        % getting original volume
        original_img_path = [basefolder, data{i}.accessNum];
        original_vol = dicom_read_volume(original_img_path);
        dicomInfo = dicom_folder_info(original_img_path);
        original_vol = dicom2niftiVol(original_vol, dicomInfo);
        
        % getting s t segmentation
        new_seg_file_name = strrep(s_t_seg_file, '/', '\');
        niiStruct = load_untouch_nii_gzip(new_seg_file_name);
        s_t_seg = niiStruct.img;
        
        % getting gradient images
        [Gx,Gy,Gz] = imgradientxyz(original_vol);
        
        % adding to train set: creating line for every voxel
        if ~(eq(size(Gx(:),1), size(original_vol(:),1)) && ...
                eq(size(original_vol(:),1), size(s_t_seg(:),1)))
            % check why this is happening: on 6441852 - it doubles the
            % original volume
            display('dimensions problem!');
            continue;
        end
        img_line_rep = [original_vol(:), Gx(:), Gy(:), transpose(1:size(original_vol(:))), s_t_seg(:)];
        all_images_lines = [all_images_lines; img_line_rep];
    end
end

%% training
forest = TreeBagger(10, all_images_lines(:, 1:4), all_images_lines(:, 5));
%TRAIN_RANDOM_FOREST uses existing segmentations of relevant sink and
%source points in order to train a decision forest to help us find the best
%points in the future

load matlabData;
basefolder = 'D://MIP_sacro/sacro/dataset/';

%% creating train set
all_images_lines = [];
for i = 1%:8%numel(data)
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
        [Gx, ~, ~] = imgradientxyz(original_vol);
        
        % creating indices array
        indices = transpose(1:size(original_vol(:)));
        indices = reshape(indices, size(original_vol, 1), size(original_vol, 2), size(original_vol, 3));
        
        % which slices do we need?
        sum_of_slices = zeros(size(s_t_seg,3),1);
        for z = 1:size(sum_of_slices,1)
            slice = s_t_seg(:,:,z);
            sum_of_slices(z) = sum(slice(:));
        end
        first_slice = find(sum_of_slices, 1, 'first');
        last_slice = find(sum_of_slices, 1, 'last');
        
        % get the bBox of the pelvis to avoid redundant voxels
        hipsSegPath = [original_img_path '/hipsSeg.mat'];
        load(hipsSegPath);
        stats = regionprops(hipsSeg, 'BoundingBox');
        first_x = ceil(stats.BoundingBox(1)); 
        last_x = ceil(stats.BoundingBox(1))+ceil(stats.BoundingBox(4)); 
        first_y = ceil(stats.BoundingBox(2)); 
        last_y = ceil(stats.BoundingBox(2))+ceil(stats.BoundingBox(5)); 
        first_z = ceil(stats.BoundingBox(3)); 
        last_z = ceil(stats.BoundingBox(3))+ceil(stats.BoundingBox(6)); 
        
        % cropping
        original_vol = original_vol(first_x:last_x,first_y:last_y,first_slice:last_slice);
        s_t_seg = s_t_seg(first_x:last_x,first_y:last_y,first_slice:last_slice);
        Gx = Gx(first_x:last_x,first_y:last_y,first_slice:last_slice);
        indices = indices(first_x:last_x,first_y:last_y,first_slice:last_slice);
        
        % adding to train set: creating line for every voxel
        if ~(eq(size(Gx(:),1), size(original_vol(:),1)) && ...
                eq(size(original_vol(:),1), size(s_t_seg(:),1)))
            % check why this is happening: on 6441852 - it doubles the
            % original volume
            display('dimensions problem!');
            continue;
        end
        img_line_rep = [original_vol(:), Gx(:), indices(:), s_t_seg(:)];
        all_images_lines = [all_images_lines; img_line_rep];
    end
end

%% training
forest = TreeBagger(50, single(all_images_lines(:, 1:3)), all_images_lines(:, 4), ...
    'Method', 'classification');
function [ pelvis_roi_equalized ] = EqualizeSingleImageHistogram( pelvis_roi )
%EqualizeSingleImageHistogram Equalizes histogram of the whole image (3d)
%   uses commulative binning of the histograms of every single slice.

    % create commulative histogram of every image
    clear all_values; 
    slices = size(pelvis_roi, 3);
    for sliceNum = 1:slices
        slice = pelvis_roi(:,:,sliceNum);
        slice_roi_gray = int16(mat2gray(slice)*255);
    
        if (~exist('all_values', 'var'))
            all_values = slice_roi_gray(slice_roi_gray>1);
        else
            all_values = [all_values; slice_roi_gray(slice_roi_gray>1)];
        end
    end
    
    % for every possible value, multiply with corresponding eq parameter
    [~, pelvis_histogram_eq] = histeq(all_values(:));
    %% changed here to 1000 instead of 500 - check!!! 
    pelvis_gray = int16(mat2gray(pelvis_roi)*1000);
    pelvis_roi_equalized = pelvis_gray;
    for j = 1:255
        values_to_multiply = find(pelvis_gray == j);
        pelvis_roi_equalized(values_to_multiply) = ...
            pelvis_gray(values_to_multiply)*pelvis_histogram_eq(j);
    end

end


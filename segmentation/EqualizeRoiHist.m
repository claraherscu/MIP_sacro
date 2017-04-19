function [ roi_equalized ] = EqualizeRoiHist( roi )
%EqualizeRoiHist return an equalized version of the roi
%   normalizing histogram of this slice to a constant range
    
    slice_roi_gray = int16(mat2gray(roi)*500);

    % for every possible value, multiply with corresponding eq parameter
    [~, slice_histogram_eq] = histeq(slice_roi_gray(:));
    roi_equalized = slice_roi_gray;
    for j = 1:256
        values_to_multiply = find(slice_roi_gray == j);
        roi_equalized(values_to_multiply) = ...
            slice_roi_gray(values_to_multiply)*slice_histogram_eq(j);
    end
    
end


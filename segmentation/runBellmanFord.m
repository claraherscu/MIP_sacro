function [ newBorderSeg ] = runBellmanFord ( borderSeg, hipsSeg, original_vol )
% RUNBELLMANFORD a method for running bellman ford per slice to find a
% better border between the sacrum and the illium - will be used when our
% previous segmentation attempts have failed

    %% getting all segmented borders
    [padded_L, padded_R, padded_hips, padded_original] = getPaddedImages (hipsSeg, borderSeg, original_vol);
    % [padded_L, padded_R] = getPaddedImages (hipsSeg, borderSeg);
    flipped_L = flipud(padded_L); flipped_R = flipud(padded_R);

    %% find pelvis start and end slices
    both_sides = or(padded_L, padded_R);
    sum_of_slices = zeros(size(both_sides,3),1);
    for z = 1:size(sum_of_slices,1)
        slice = both_sides(:,:,z);
        sum_of_slices(z) = sum(slice(:));
    end

    pelvis_start = find(sum_of_slices, 1, 'first');
    pelvis_end = find(sum_of_slices, 1, 'last');

    %% iterate over all slices: for each slice find best borders for L&R
    newBorderL = zeros(size(both_sides));
    newBorderR = zeros(size(both_sides));
    for sliceNum = pelvis_start:pelvis_end
        display(['slice #' num2str(sliceNum)]);
        hipsSegSlice = padded_hips(:,:,sliceNum);
        original_vol_slice = padded_original(:,:,sliceNum);
        % left side
        currSliceBorderL = getSliceBorder (hipsSegSlice, original_vol_slice, ...
            padded_L(:,:,sliceNum), flipped_R(:,:,sliceNum));
        newBorderL(:,:,sliceNum) = currSliceBorderL;
        % same for right side
        currSliceBorderR = getSliceBorder (hipsSegSlice, original_vol_slice, ...
            padded_R(:,:,sliceNum), flipped_L(:,:,sliceNum));
        newBorderR(:,:,sliceNum) = currSliceBorderR;
    end
    newBorderSeg.L = newBorderL;
    newBorderSeg.R = newBorderR;
    
end

function [padded_roi, d] = getShortestPathForBorderSlice(borderSegSlice,...
    hipsSegSlice, original_vol_slice)
% GETSHORTESTPATHSFORBORDER looks for shortest paths in the graph created
% by every slice in the given border.
%   INPUTS: *borderSegSlice, hipsSegSlice, original_vol_slice - all padded 
%           (of the same size) and correlated - if the border segmentation 
%           is flipped, so is the hips segmentation and the original image.
%   OUTPUTS: *path - the linear indices of the path found by bellman-ford
%           on the current slice.
%           *d - the cost of this path
    
    % getting all points for bellman ford initialization
    [ t, s ] = getBellmanFordSinkSourceFromBorderSlice(borderSegSlice(:,:), hipsSegSlice(:,:));

    % some of the slices are going to have empty results here (no border)
    if (t(1) == -1)
        % no border on this slice
        padded_roi = 0;
        d = 0;
    else
        % have results, should run bellman ford on this slice!
        display(['got source: (' num2str(s(1)) ',' num2str(s(2)) ') '...
            'and sink: (' num2str(t(1)) ',' num2str(t(2)) ')']);

        % creating ROI
        BL = [min(s(1),t(1)), min(s(2),t(2))] - 20;
        UR = [max(s(1),t(1)), max(s(2),t(2))] + 20;
%         if (s(1) < t(1))
%             if (s(2) < t(2))
%                 BL = s - 20;
%                 UR = t + 20;
%             else
%                 BL = [s(1) - 20, t(2) - 20];
%                 UR = [t(1) - 20, s(2) - 20];
%             end
%         else
%             if (s(2) < t(2))
%                 BL = [t(1) - 20, s(2) - 20];
%                 UR = [s(1) - 20, t(2) - 20];
%             else
%                 BL = t - 20;
%                 UR = s + 20;
%             end
%         end
        
        [ roi, pre_add_to_x, post_add_to_x, pre_add_to_y,...
                    post_add_to_y ] = getROI (original_vol_slice, BL, UR);
        % creating graph according to original grey-values ROI
        sliceGraph = getSliceGraph(roi);
        [path, d] = shortestpath(sliceGraph, ...
            sub2ind(size(roi), s(1) - pre_add_to_x, s(2) - pre_add_to_y), ...
            sub2ind(size(roi), t(1) - pre_add_to_x, t(2) - pre_add_to_y), ...
            'Method', 'mixed');

        % add the difference from the cropping
%         to_add_linear = sub2ind(size(original_vol_slice), add_to_x, add_to_y);
%         path = path + to_add_linear;
        
        [X,Y] = ind2sub(size(roi), path); 
        X = X + pre_add_to_x 
        Y = Y + pre_add_to_y
        
        roi = zeros(size(roi));
        roi(path) = 1;
        padded_roi = padarray(roi, [pre_add_to_x; pre_add_to_y], 'pre');
        padded_roi = padarray(padded_roi, [post_add_to_x-1; post_add_to_y-1], 'post');
    end
end
    
function [ roi, pre_add_to_x, post_add_to_x, pre_add_to_y, post_add_to_y ] = getROI (original_vol_slice, BL, UR)
    roi = original_vol_slice(BL(1):UR(1), BL(2):UR(2));
    pre_add_to_y = BL(2);
    pre_add_to_x = BL(1);
    post_add_to_y = size(original_vol_slice,2) - UR(2);
    post_add_to_x = size(original_vol_slice,1) - UR(1);
end

function [ sliceBorder ] = getSliceBorder (hipsSegSlice, ...
    original_vol_slice, border_slice_1, border_slice_2)
%GETSLICEBORDER uses getShortestPathForBorderSlice to find the best shortest
%path of each side of the slice
%   INPUTS: *hipsSegSlice, original_vol_slice - all padded 
%           (of the same size) and correlated - if the border segmentation 
%           is flipped, so is the hips segmentation and the original image.
%           *pborder_slice_1, border_slice_2 - all possible borders for 
%           this side on this slice
%   OUTPUTS: *sliceBorder - matrix the same size of the border segmentation
%           with 1's only where the best path is.

    [padded_roi_1, path_1_d] = getShortestPathForBorderSlice(border_slice_1, ...
        hipsSegSlice, original_vol_slice);
    [padded_roi_2, path_2_d] = getShortestPathForBorderSlice(border_slice_2, ...
        hipsSegSlice, original_vol_slice);
    if ((path_1_d ~= 0) && (path_1_d < path_2_d))
        % path_1 is better
        sliceBorder = padded_roi_1;
    else
        if ((path_2_d ~= 0) && (path_2_d < path_1_d))
            sliceBorder = padded_roi_2;
        else
            sliceBorder = zeros(size(original_vol_slice));
        end
    end
end
function [ newBorderSeg ] = runBellmanFord ( borderSeg, hipsSeg, original_vol )
% RUNBELLMANFORD a method for running bellman ford per slice to find a
% better border between the sacrum and the illium - will be used when our
% previous segmentation attempts have failed

    % getting all segmented borders
    [padded_L, padded_R, padded_hips, padded_original] = getPaddedImages (hipsSeg, borderSeg, original_vol);
    % [padded_L, padded_R] = getPaddedImages (hipsSeg, borderSeg);
    flipped_L = flipud(padded_L); flipped_R = flipud(padded_R);

    % find pelvis start and end slices
    both_sides = or(padded_L, padded_R);
    sum_of_slices = zeros(size(both_sides,3),1);
    for z = 1:size(sum_of_slices,1)
        slice = both_sides(:,:,z);
        sum_of_slices(z) = sum(slice(:));
    end

    pelvis_start = find(sum_of_slices, 1, 'first');
    pelvis_end = find(sum_of_slices, 1, 'last');


    % iterate over all borders
    L_all_paths = getShortestPathsForBorder(padded_L, padded_hips, ...
        padded_original, pelvis_start, pelvis_end);
    % R_all_paths, L_flipped_all_paths, R_flipped_all_paths


end


function [allPaths] = getShortestPathsForBorder(borderSeg, hipsSeg, ...
    original_vol, pelvis_start, pelvis_end)
% GETSHORTESTPATHSFORBORDER looks for shortest paths in the graph created
% by every slice in the given border.
%   INPUTS: *borderSeg, hipsSeg, original_vol - all padded (of the same
%           size) and correlated - if the border segmentation is flipped, 
%           so is the hips segmentation and the original image.
%           *pelvis_start, pelvis_end - slice numbers of the start and end
%           of the segmentation of the pelvis.
%   OUTPUTS: *allPaths{sliceNum} contains the shortest path found for this
%           slice and its cost.
    
    allPaths = {};
    for sliceNum = pelvis_start:pelvis_end
        % getting all points for bellman ford initialization
        [ t, s ] = getBellmanFordSinkSourceFromBorderSlice(borderSeg(:,:,sliceNum), hipsSeg(:,:,sliceNum));

        % some of the slices are going to have empty results here (no border)
        if (t(1) == -1)
            % no border on this slide
            continue;
        else
            % have results, should run bellman ford on this slice!
            display(['for slice #' num2str(sliceNum) ' got sink: (' ...
                num2str(t(1)) ',' num2str(t(2)) ') and source: ('...
                num2str(s(1)) ',' num2str(s(2)) ')']);
            
%             % creating ROI
%             roi = original_vol(s(1):t(1),s(2):t(2),sliceNum);
%             % creating graph according to original grey-values ROI
%             sliceG = getSliceGraph(roi);
            sliceG = getSliceGraph(original_vol(:,:,sliceNum)); %no ROI
            
            % finding shortest path
            % TODO: consider using graphshortestpath / different 'method's
            [path, d] = shortestpath(sliceG, ...
                sub2ind(size(original_vol(:,:,sliceNum)),s(1),s(2)), ...
                sub2ind(size(original_vol(:,:,sliceNum)),t(1),t(2)), ...
                'Method', 'mixed');
            allPaths{sliceNum} = struct('path', path, 'd', d);
        end
    end
end
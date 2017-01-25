function [ newBorderSeg ] = runBellmanFord ( borderSeg, hipsSeg )
% RUNBELLMANFORD a method for running bellman ford per slice to find a
% better border between the sacrum and the illium - will be used when our
% previous segmentation attempts have failed

sum_of_slices = zeros(size(hipsSeg,3),1);
for z = 1:size(sum_of_slices,1)
    slice = hipsSeg(:,:,z);
    sum_of_slices(z) = sum(slice(:));
end

pelvis_start = find(sum_of_slices, 1, 'first');
pelvis_end = find(sum_of_slices, 1, 'last');

% getting all segmented borders
[padded_L, padded_R] = getPaddedImages (hipsSeg, segBorder);
flipped_L = flipud(padded_L); flipped_R = flipud(padded_R);

all_borders_img = or(padded_L, flipped_L, padded_R, flipped_R);

% TODO: iterate over all borders
newBorderSeg = zeros(size(borderSeg));
for sliceNum = pelvis_start:pelvis_end
    % getting all points for bellman ford initialization
    
    
end

end
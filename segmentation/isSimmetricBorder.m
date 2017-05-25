function [ isSimmetricBorder ] = isSimmetricBorder ( hipsSeg, segBorder, pixelSz )
%ISSIMMETRICBORDER checks if the segmentation result was ~ simmetric

    %% mirroring
    [padded_L, padded_R] = getPaddedImages(hipsSeg, segBorder);
    
    % mirroring left side on the right
    mirrored_L = flipud(padded_L);
    both_sides = or(padded_R, mirrored_L); 
    
    %% looking for the maximal distance in the x axis
    sum_of_slices = zeros(size(both_sides,3),1);
    for z = 1:size(sum_of_slices,1)
        slice = both_sides(:,:,z);
        sum_of_slices(z) = sum(slice(:));
    end
    
    pelvis_start = find(sum_of_slices, 1, 'first');
    pelvis_end = find(sum_of_slices, 1, 'last');

    display(['pelvis start slice found at ', num2str(pelvis_start), ' and the end at ' ...
        , num2str(pelvis_end)]);
    
    % measuring distance from original right to the mirrorring result
    % the interesting distance is in the x axis
    max_x_distances_per_slice = zeros(abs(pelvis_start - pelvis_end),1);
    for z = pelvis_start:pelvis_end
        max_dist = 0;
        for y = 1:size(both_sides,2)
            y_vector = both_sides(:,y,z);
            curr_dist = abs(find(y_vector, 1, 'first') - find(y_vector, 1, 'last'));
            if (curr_dist > max_dist)
                max_dist = curr_dist;
            end
        end
        max_x_distances_per_slice(z-pelvis_start+1) = max_dist;
    end
    
    % if the maximal distance over all slices is big, we will return 'not
    % simmetric'. (big means > 3.5 cm)
    max_allowed_dist = ceil(35/pixelSz);
    max_x_distances = max(max_x_distances_per_slice);
    display(max_x_distances);
    if (max_x_distances > max_allowed_dist)
        isSimmetricBorder = false;
    else
        isSimmetricBorder = true;
    end
end
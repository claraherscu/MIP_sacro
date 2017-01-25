function [ isSimmetricBorder ] = isSimmetricBorder ( segBorder, pixelSz )
%ISSIMMETRICBORDER checks if the segmentation result was ~ simmetric

    % mirroring left side on the right
    mirrored_L = flipud(segBorder.L);
    
    % measuring distance from original right to the mirrorring result
    both_sides = or(segBorder.R, mirrored_L); 
    sum_of_slices = zeros(size(both_sides,3),1);
    for z = 1:size(sum_of_slices,1)
        slice = both_sides(:,:,z);
        sum_of_slices(z) = sum(slice(:));
    end
    
    first_ind = find(sum_of_slices, 1, 'first');
    [~,~,pelvis_start] = ind2sub(size(both_sides), first_ind);
    last_ind = find(sum_of_slices, 1, 'last');
    [~,~,pelvis_end] = ind2sub(size(both_sides), last_ind);
    
    % the interesting distance is in the x axis
    max_x_distances_per_slice = zeros(abs(pelvis_start - pelvis_end),1);
    for z = 1:size(max_x_distances_per_slice,1)
        max_dist = 0;
        for y = 1:size(both_sides,2)
            y_vector = both_sides(:,y,z);
            curr_dist = abs(find(y_vector, 1, 'first') - ...
                find(y_vector, 1, 'last'));
            if (curr_dist > max_dist)
                max_dist = curr_dist;
            end
        end
        max_x_distances_per_slice(z) = max_dist;
    end
    
    % if the maximal distance over all slices is big, we will return 'not
    % simmetric'. (big means > 2 cm)
    max_allowed_dist = ceil(20/pixelSz);
    max_x_distances = max(max_x_distances_per_slice);
    if (max_x_distances > max_allowed_dist)
        isSimmetricBorder = false;
    else
        isSimmetricBorder = true;
    end
end


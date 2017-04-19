function [ weight ] = calculateEdgeWeight( slice, i, j, avg_intensity_sink_source )
% calculateEdgeWeight get appropriate weight for an edge between two pixels
%   INPUT: slice - the cropped image
%          i, j - the two pixels we wish to connect
%          avg_intensity_sink_source - calculated intensity of source and 
%               sink, which we use in the weights
    
    % initial weight will be exp(-(I(i)-I(j))^2/2sigma^2)
    sigma = std(slice(:));
    
    % calculating weight relatively to s and t
    diff_matrix = slice - avg_intensity_sink_source;
    diff_std = std(diff_matrix(:));
    
    intensity_diff = slice(i) - slice(j);
    
    % calculating weights for "being closer to edge"
    weight_darker_neighbour = exp(intensity_diff);
    
    [i_x, i_y] = ind2sub(size(slice), i); [j_x, j_y] = ind2sub(size(slice), j);
    % wrapping it all up
    weight_neighbour_diff = exp(-((intensity_diff)^2)/(2*(sigma^2)));
    weight_s_t_diff = exp(-((diff_matrix(j_x,j_y))^2)/(2*(diff_std^2)));
    weight = 1-exp(-0.1*weight_neighbour_diff - 0.15*weight_s_t_diff - ...
        0.85*weight_darker_neighbour);

end


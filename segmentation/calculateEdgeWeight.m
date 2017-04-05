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
    
    % calculating weights for "being closer to edge"
    
    % wrapping it all up
    intensity_diff = slice(i) - slice(j);
    weight_neighbour_diff = exp(-((intensity_diff)^2)/(2*(sigma^2)));
    weight_s_t_diff = exp(-((diff_matrix(j_x,j_y))^2)/(2*(diff_std^2)));
    weight = 1-exp(-weight_neighbour_diff - 1.5*weight_s_t_diff);

end


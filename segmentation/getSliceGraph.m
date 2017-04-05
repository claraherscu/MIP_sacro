function [ G, adj ] = getSliceGraph(slice, avg_intensity_sink_source)
% GETSLICEGRAPH creates a neighbors matrix and then creates a directed 
% graph object from it.
%   in every cell (i,j) in the adjacency matrix, there is the weight of 
%   the edge between them, when i and j are linear indices originating in
%   the slice image.
%   the weight is: 1 - exp(-(I(i)-I(j))^2/2sigma^2)
%   based on 4-connectivity

    % getting the size of the image
    [ r, c ] = size(slice);
    dim = r*c; % we will work with linear indexing
    
    % creating a square zero matrix - will be filled with weights
    adj = zeros(dim, dim);
    
    % initial weight will be exp(-(I(i)-I(j))^2/2sigma^2)
    sigma = std(slice(:));
    
    % calculating weight relatively to s and t
    diff_matrix = slice - avg_intensity_sink_source;
    diff_std = std(diff_matrix(:));
    
    % calculating weights for "being closer to edge"
    
    
    % 8-neighbors of pixel i are:
    % i - 1, i + 1, i + r, i - r; i - r - 1, i - r + 1, i + r -1, i + r + 1
    neighbours = [-1,1,r,-r,-r-1,-r+1,r-1,r+1];
    for i = 1:dim
        % determine weight for each of i's neighbours
        for neigh = neighbours
            j = i + neigh; % the neighbour we will now weight
            [i_x, i_y] = ind2sub(size(slice), i);
            if (j > 0 && j <= dim) % in range
                [j_x, j_y] = ind2sub(size(slice), j);
                if (sqrt((i_x - j_x)^2 + (i_y - j_y)^2) < 2)                
                    intensity_diff = slice(i) - slice(j);
                    weight_neighbour_diff = exp(-((intensity_diff)^2)/(2*(sigma^2)));
                    weight_s_t_diff = exp(-((diff_matrix(j_x,j_y))^2)/(2*(diff_std^2)));
                    adj(i,j) = 1-exp(-weight_neighbour_diff - 1.5*weight_s_t_diff);
                    if(adj(i,j) < 0)
                        display(['i:' num2str(i) ' j:' num2str(j)])
                    end
                end
            end
        end
    end
    
    adj = sparse(adj ./ max(adj(:)));
    nans = isnan(adj);
    if(sum(nans(:)) > 0)
        [row, col] = find(isnan(adj));
        display(['row:' num2str(row) ' col:' num2str(col)])
    end
    G = digraph(adj);
%     plot(G);
%     G = adj;
end

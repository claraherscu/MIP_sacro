function [ G ] = getSliceGraph(slice)
% GETSLICEGRAPH creates a neighbors matrix and then creates a directed 
% graph object from it.
%   in every cell (i,j) in the adjacency matrix, there is the weight of 
%   the edge between them, when i and j are linear indices originating in
%   the slice image.
%   the weight is: exp(-(I(i)-I(j))^2/2sigma^2)
%   based on 4-connectivity

    % getting the size of the image
    [ r, c ] = size(slice);
    dim = r*c; % we will work with linear indexing
    
    % creating a square zero matrix - will be filled with weights
    adj = sparse(dim, dim);
    
    % weight will be exp(-(I(i)-I(j))^2/2sigma^2)
    sigma = std(slice(:));
    
    % 4-neighbors of pixel i are:
    % i - 1, i + 1, i + r, i - r;
    neighbours = [-1,1,r,-r];
    for i = 1:dim
        % determine weight for each of i's neighbours
        for neigh = neighbours
            j = i + neigh; % the neighbour we will now weight
            if (j > 0 && j <= dim)
                % we're in range
                intensity_diff = slice(i) - slice(j);
                adj(i,j) = exp(-((intensity_diff)^2)/(2*(sigma^2)));
            end
        end
    end
    
    G = digraph(adj);
end
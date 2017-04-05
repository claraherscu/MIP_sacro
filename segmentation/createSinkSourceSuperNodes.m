function [ newSliceGraph ] = createSinkSourceSuperNodes( sliceGraph, source, sink )
% createSinkSourceSuperNodes edit the sliceGraph: create super-nodes for
% source and sink: they will be highly connected in order to represent a
% group of former existing regular nodes.
%   INPUT: sliceGraph - the original graph
%          source, sink - the source and sink nodes in the graph
%   OUTPUT: a new slice graph based on the former, but with two super-nodes
%           for source and target.

    newSliceGraph = sliceGraph;
    newSliceGraph = createSuperNode(newSliceGraph, source);
    newSliceGraph = createSuperNode(newSliceGraph, sink);
    
end


function newSliceGraph = createSuperNode(sliceGraph, node)
% createSuperNode remvoes first order neighbours of node and adds edged
% between node and the second and third order neighbours to create higher
% connectivity
    
    % find nodes we want to connect to the node
    % neighbours of node
    direct_neighbours = neighbors(sliceGraph, node);
    for neigh_node = direct_neighbours                
        % 2nd degree neighbours of node
        second_degree_neigh = neighbors(sliceGraph, neigh_node);
        for neigh_node_2 = second_degree_neigh
            if (~findedge(newSliceGraph, node, neigh_node_2))
                % what is the proper weight for this edge?
                edge_weight = calculateEdgeWeight(slice, i, j, avg_intensity_sink_source);
                % adding edge
                newSliceGraph = addedge(newSliceGraph, node, neigh_node_2, edge_weight);
            end
            
            % 3rd degree neighbours of node from this 2nd degree neighbour
            third_degree_neigh = neighbors(sliceGraph, neigh_node_2);
            for neigh_node_3 = third_degree_neigh
                if (~findedge(newSliceGraph, node, neigh_node_3))
                    % what is the proper weight for this edge?
                    edge_weight = calculateEdgeWeight(slice, i, j, avg_intensity_sink_source);
                    % adding edge
                    newSliceGraph = addedge(newSliceGraph, node, neigh_node_3, edge_weight);
                end
            end
        end
        
        % delete this direct neighbour
        newSliceGraph = rmnode(newSliceGraph, neigh_node);
    end
end


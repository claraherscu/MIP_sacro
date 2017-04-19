function [ newSliceGraph ] = createSinkSourceSuperNodes( sliceGraph, source, sink )
% createSinkSourceSuperNodes edit the sliceGraph: create super-nodes for
% source and sink: they will be highly connected in order to represent a
% group of former existing regular nodes.
%   INPUT: sliceGraph - the original graph
%          source, sink - the source and sink nodes in the graph
%   OUTPUT: a new slice graph based on the former, but with two super-nodes
%           for source and target.

    % adding edges, and collecting nodes to be removed
    [to_be_removed1, newSliceGraph] = createSuperNode(sliceGraph, source);
    [to_be_removed2, newSliceGraph] = createSuperNode(newSliceGraph, sink);
%     % removing redundant nodes
%     newSliceGraph = rmnode(newSliceGraph, [to_be_removed1; to_be_removed2]);
    
    % removing self loops
    newSliceGraph = rmedge(newSliceGraph, 1:numnodes(newSliceGraph),...
        1:numnodes(newSliceGraph));
    
end

function newSliceGraph = addEdgeToSuperNode(newSliceGraph, node, neigh)
    if (~findedge(newSliceGraph, node, neigh))
        all_subGraph_nodes = [neigh; successors(newSliceGraph, neigh)];
        if(any(successors(newSliceGraph, neigh) == neigh))
            all_subGraph_nodes = successors(newSliceGraph, neigh);
        end
        
        % giving this edge the best of former weights
        subGraph = subgraph(newSliceGraph,all_subGraph_nodes);
        edge_weight = min(subGraph.Edges.Weight);
        % adding edge
        newSliceGraph = addedge(newSliceGraph, node, neigh, edge_weight);
        
    end
end

function [to_be_removed, newSliceGraph] = createSuperNode(sliceGraph, node)
% createSuperNode remvoes first order neighbours of node and adds edged
% between node and the second and third order neighbours to create higher
% connectivity
    
    newSliceGraph = sliceGraph;
    % find nodes we want to connect to the node
    % neighbours of node
    direct_neighbours = successors(newSliceGraph, node).';
    to_be_removed = [];
    for neigh_node = direct_neighbours                
        % 2nd degree neighbours of node
        second_degree_neigh = successors(newSliceGraph, neigh_node).';
        for neigh_node_2 = second_degree_neigh
            % 3rd degree neighbours of node from this 2nd degree neighbour
            third_degree_neigh = successors(newSliceGraph, neigh_node_2).';
            for neigh_node_3 = third_degree_neigh
                newSliceGraph = addEdgeToSuperNode(newSliceGraph, node, neigh_node_3);
            end
            % later we'll delete this 2nd degree neighbour
            if(neigh_node_2 ~= node && ~any(to_be_removed == neigh_node_2))
                % this is not the node we are working on connecting 
                % nore is this already in the remove set
                to_be_removed = [to_be_removed; neigh_node_2];
            end 
        end
        % we'll delete this direct neighbour later
        if(neigh_node ~= node && ~any(to_be_removed == neigh_node))
            to_be_removed = [to_be_removed; neigh_node];
        end
    end
end


function [ sink, source ] = getBellmanFordSinkSourceFromBorderSlice( borderSlice )
%GET_BELLMAN_FORD_SINK_SOURCE_FROM_BORDER_SLICE a method for getting source
% and sink points in this slice for bellman ford
%   these points will be extracted from the border on thhis slice using the
%   following steps:
%       1. get average slope of these couple of border
%       2. get a point between these two borders
%       3. pick two points "above" and "below" the borders (out of the bone
%       area!!) to be the source and sink



end


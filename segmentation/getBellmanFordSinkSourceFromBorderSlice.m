function [ sink, source ] = getBellmanFordSinkSourceFromBorderSlice( borderSlice, hipsSeg )
%GET_BELLMAN_FORD_SINK_SOURCE_FROM_BORDER_SLICE a method for getting source
% and sink points in this slice for bellman ford
%   these points will be extracted from the border on thhis slice using the
%   following steps:
%       1. get average slope of these couple of border
%       2. get a point between these two borders
%       3. pick two points "above" and "below" the borders (out of the bone
%       area!!) to be the source and sink

    %% get average slope of borders
    [x_left_down, y_left_down, ...
        x_right_down, y_right_down, ...
        x_left_top, y_left_top, ...
        x_right_top, y_right_top] = getEdgesOfBorders(borderSlice);
    
    if (x_left_down == 0 || x_right_down == 0 || x_left_top == 0 || x_right_top == 0)
        % should return some empty default answer in order to go on to next
        % slice or should prevent this function from being called on this
        % situation at all.
        source(1) = -1; source(2) = -1; sink(1) = -1; sink(2) = -1;
        display('no border on current slice');
%         return;
    else
        display('found border on current slice');
    %     slope_left = (y_left_top - y_left_down)/(x_left_top - x_left_down);
    %     slope_right = (y_right_top - y_right_down)/(x_right_top - x_right_down);
    %     avg_slope = (slope_left + slope_right)/2;
        y_diff_left = (y_left_top - y_left_down);
        y_diff_right = (y_right_top - y_right_down);
        avg_y_diff = (y_diff_left + y_diff_right)/2;
        x_diff_left = (x_left_top - x_left_down);
        x_diff_right = (x_right_top - x_right_down);
        avg_x_diff = (x_diff_left + x_diff_right)/2;

        %% get a point between the two borders
        center_x_top = floor((x_right_top + x_left_top)/2);
        center_y_top = floor((y_right_top + y_left_top)/2);
        center_x_bottom = floor((x_right_down + x_left_down)/2);
        center_y_bottom = floor((y_right_down + y_left_down)/2);

        %% finally, pick sink and source according to center point, slopes, and
        % hipsSeg (should pick something out of the segmentation of the hips)
        source(1) = floor(center_x_top + avg_x_diff/2);
        source(2) = floor(center_y_top + avg_y_diff/2);
        % not very likely but possible
        if (hipsSeg(source(1),source(2)) > 0)
            % we took a point to close, it's still in the pelvis
            source(1) = floor(source(1) + avg_x_diff/2);
            source(2) = floor(source(2) + avg_y_diff/2);
        end

        sink(1) = floor(center_x_bottom - avg_x_diff/2);
        sink(2) = floor(center_y_bottom - avg_y_diff/2);
        % not very likely but possible
        if (hipsSeg(sink(1),sink(2)) > 0)
            % we took a point to close, it's still in the pelvis
            sink(1) = floor(sink(1) + avg_x_diff/2);
            sink(2) = floor(sink(2) + avg_y_diff/2);
        end

    %     figure;
    %     hold on;
    %     imagesc(borderSlice);
    %     line([source_x, sink_x], [source_y, sink_y], 'Color', 'r', 'LineWidth',2);
    %     hold off;
    end
end

function [x_1_1, y_1_1, x_2_1, y_2_1, x_1_2, y_1_2, x_2_2, y_2_2] ...
    = getEdgesOfBorders(borderSlice)
% GETEDGESOFBORDERS a function for finding the topmost and lowmost points
% of both borders in this slice, in order to later calculate the slope

    x_1_1 = 0; y_1_1 = 0; x_2_1 = 0; y_2_1 = 0; 
    x_1_2 = 0; y_1_2 = 0; x_2_2 = 0; y_2_2 = 0;
    
    %TODO: should i really return the size(borderSlice,2) - y? or just y?
    for y = 1:size(borderSlice,2)
        x_inds = find(borderSlice(:,y));
        if (numel(x_inds) < 2)
            continue
        end
        % this is a row with both borders in it, should save indices
        x_1_1 = x_inds(1); y_1_1 = size(borderSlice,2) - y;
        x_2_1 = x_inds(2); y_2_1 = size(borderSlice,2) - y;

        % we now have what we needed, can stop loop
        break
    end
    
    for y = size(borderSlice,2):-1:1
        x_inds = find(borderSlice(:,y));
        if (numel(x_inds) < 2)
            continue;
        end
        % this is a row with both borders in it, should save indices
        x_1_2 = x_inds(1); y_1_2 = size(borderSlice,2) - y;
        x_2_2 = x_inds(2); y_2_2 = size(borderSlice,2) - y;
        % we now have what we needed, can stop loop
        break;
    end
end
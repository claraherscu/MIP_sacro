function [ ] = getBBoxPerSlice (border_seg, pixelSz, side, fd, filename)
% getBBoxPerSlice extracts a bounding box around the sacroiliac joint on
% every slice where a segmentation exists. only write to log file if we are in debug mode
%   inputs: border_seg = seg image of single side (ex.: segBorder.L);
%           pixelSz = the size of a pixel, to calculate sizes correctly
%           side = 'left' or 'right', needed for orientation calculations
%           fd = a file already open for writing the results into

    % first, flip segmentation upsidedown to work on correct idxs
    border_seg = fliplr(border_seg);
    
    % use regression to find the orientation of the bBox on each slice
    [pelvis_start, pelvis_end] = getStartEnd(border_seg);

    % format to write to file
    coords_format = [filename ' coords %d ' side ' : (%d %d) (%d %d) (%d %d) (%d %d) \n'];
    slope_format = [filename ' slope %d ' side ' : %d \n'];
    
    % constants for the window
    w = 10/pixelSz; % 3.5 mm
    l = 35/pixelSz; % 35 mm
    
    degree = 1;
    for sliceNum = pelvis_start:pelvis_end
        curr_slice_border = border_seg(:,:,sliceNum);
        [X,Y] = find(curr_slice_border);
        % use polyfit to find orientation
        curr_slice_poly = polyfit(X, Y, degree);
        
        % pick top point: if it's the left side, top is largest x
        [Xs, ~] = find(curr_slice_border);
        if(strcmp(side, 'left'))
            top_x = max(Xs);
        else % side == 'right'
            top_x = min(Xs);
        end
        
        % get y of this top point
        top_y = polyval(curr_slice_poly, top_x);
        
        % move the top a bit further
        v = [-1, polyval(curr_slice_poly, top_x-1)-top_y];
        u = v / norm(v);
        if(strcmp(side, 'left'))
            top = floor([top_x top_y] - (l/4*u)); % bottom = (x0,y0) - d*u -> direction of x0
        else % side == 'right'
            top = floor([top_x top_y] + (l/4*u)); % bottom = (x0,y0) + d*u -> direction of x1
        end
        top_x = top(1); top_y = top(2);
        
        % get perpendicular slope
        original_slope = curr_slice_poly(1); % p is the coefficient vector of the polyfit
        perp_slope = -1/original_slope; % perpendicular slope is -1/slope
        
        % build top perp line
        top_perp_b = top_y - perp_slope*top_x; % perp intercept
        top_perp_poly = [perp_slope, top_perp_b]; % built the coefficient vector        
        
        % take w/2 to the left of [top_x, top_y] on the perpendicular slope
        v = [-1, polyval(top_perp_poly, top_x-1)-top_y]; % v = (x1,y1)-(x0,y0)
        u = v / norm(v); % u = normalized v
        TL = floor([top_x top_y] + (w * u)); % TL = (x0,y0) + d*u -> direction of x1
        TR = floor([top_x top_y] - (w * u)); % TR = (x0,y0) - d*u -> direction of x0

        
        % calculate bottom_x, bottom_y
        v = [-1, polyval(curr_slice_poly, top_x-1)-top_y];
        u = v / norm(v);
        if(strcmp(side, 'left'))
            bottom = floor([top_x top_y] + (l*u)); % bottom = (x0,y0) + d*u -> direction of x1
        else % side == 'right'
            bottom = floor([top_x top_y] - (l*u)); % bottom = (x0,y0) - d*u -> direction of x0
        end
        
        % build bottom perp line
        bottom_perp_b = bottom(2) - perp_slope*bottom(1); % perp intercept
        bottom_perp_poly = [perp_slope, bottom_perp_b]; % built the coefficient vector
        
        % calculate BR
        v = [-1, polyval(bottom_perp_poly, bottom(1)-1)-bottom(2)]; % v = (x1,y1)-(x0,y0)
        u = v / norm(v); % u = normalized v
        BR = floor(bottom - (w * u)); % BL = (x0,y0) - d*u -> direction of x0 
        BL = floor(bottom + (w * u)); % BL = (x0,y0) + d*u -> direction of x1 
        
        % make sure we're not out of bounds
        TL(1) = max(min(TL(1),size(border_seg,1)),1);
        TR(1) = max(min(TR(1),size(border_seg,1)),1);
        BR(1) = max(min(BR(1),size(border_seg,1)),1);
        BL(1) = max(min(BL(1),size(border_seg,1)),1);
        TL(2) = max(min(TL(2),size(border_seg,2)),1);
        TR(2) = max(min(TR(2),size(border_seg,2)),1);
        BR(2) = max(min(BR(2),size(border_seg,2)),1);
        BL(2) = max(min(BL(2),size(border_seg,2)),1);
        
        % write polynom slope to file
        fprintf(fd, slope_format, sliceNum, curr_slice_poly(1));
        
        % write [TL, BR, sliceNum] to file
        fprintf(fd, coords_format, sliceNum, TL(1), TL(2), TR(1), TR(2), BR(1), BR(2), BL(1), BL(2));
    end
end
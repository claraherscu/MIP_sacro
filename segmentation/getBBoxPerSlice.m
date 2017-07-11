function [ ] = getBBoxPerSlice (border_seg, pixelSz, side, filename, hipsSeg, fd, w_size, l_size)
% getBBoxPerSlice extracts a bounding box around the sacroiliac joint on
% every slice where a segmentation exists. only write to log file if we are in debug mode
%   inputs: border_seg = seg image of single side (ex.: segBorder.L);
%           pixelSz = the size of a pixel, to calculate sizes correctly
%           side = 'left' or 'right', needed for orientation calculations
%           filename = the accessNum of this scan 
%           hipsSeg = the segmentation of the pelvis area
%           optional fd = a file already open for writing the results into
%           optional w_size = width of window (default 10/pixelSz meaning 10 mm)
%           optional l_size = length of window (default 35/pixelSz meaning 35 mm)

    % first, flip segmentation upsidedown to work on correct idxs
    border_seg = fliplr(border_seg);
    
    % use regression to find the orientation of the bBox on each slice
    [pelvis_start, pelvis_end] = getStartEnd(border_seg);
    
    % if there are too little slices of border we'll add some slices that
    % are still in the pelvis region
    [pelvis_start_2, pelvis_end_2] = getStartEnd(hipsSeg);
    if (abs(pelvis_start - pelvis_end) < 10)
        pelvis_start = max(pelvis_start - 15, pelvis_start_2);
    end
    if (abs(pelvis_start - pelvis_end) < 15)
        pelvis_end = min(pelvis_end + 15, pelvis_end_2);
    end

    % format to write to file
    coords_format = [filename ' coords %d ' side ' : (%d %d) (%d %d) (%d %d) (%d %d) \n'];
    artificial_coords_format = [filename ' artificial coords %d ' side ' : (%d %d) (%d %d) (%d %d) (%d %d) \n'];
    slope_format = [filename ' slope %d ' side ' : %d \n'];
    artificail_slope_format = [filename ' artificial slope %d ' side ' : %d \n'];
    
    % constants for the window
    if (~exist('w_size','var'))
        w_size = 10/pixelSz; % 5 mm
    end
    if (~exist('l_size', 'var'))
        l_size = 35/pixelSz; % 35 mm
    end
    
    
    degree = 1;
    for sliceNum = pelvis_start:pelvis_end      
        ARTIFICIAL_WINDOW = 0;
        curr_slice_border = border_seg(:,:,sliceNum);
        if(~sum(curr_slice_border(:)))
            % we need to generate an artificial window
            [top_x, top_y, curr_slice_poly] = generateArtificialTop(sliceNum, hipsSeg, side);
            ARTIFICIAL_WINDOW = 1;
        else
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
                top = floor([top_x top_y] - (l_size/4*u)); % bottom = (x0,y0) - d*u -> direction of x0
            else % side == 'right'
                top = floor([top_x top_y] + (l_size/4*u)); % bottom = (x0,y0) + d*u -> direction of x1
            end
            top_x = top(1); top_y = top(2);
        end
        
        
        % get perpendicular slope
        original_slope = curr_slice_poly(1); % p is the coefficient vector of the polyfit
        perp_slope = -1/original_slope; % perpendicular slope is -1/slope
        
        % build top perp line
        top_perp_b = top_y - perp_slope*top_x; % perp intercept
        top_perp_poly = [perp_slope, top_perp_b]; % built the coefficient vector        
        
        % take w/2 to the left of [top_x, top_y] on the perpendicular slope
        v = [-1, polyval(top_perp_poly, top_x-1)-top_y]; % v = (x1,y1)-(x0,y0)
        u = v / norm(v); % u = normalized v
        if(ARTIFICIAL_WINDOW)
            % window should be twice as wide
            TL = floor([top_x top_y] + (w_size * u * 2)); % TL = (x0,y0) + d*u -> direction of x1
            TR = floor([top_x top_y] - (w_size * u * 2)); % TR = (x0,y0) - d*u -> direction of x0
        else
            TL = floor([top_x top_y] + (w_size * u)); % TL = (x0,y0) + d*u -> direction of x1
            TR = floor([top_x top_y] - (w_size * u)); % TR = (x0,y0) - d*u -> direction of x0
        end

        
        % calculate bottom_x, bottom_y
        v = [-1, polyval(curr_slice_poly, top_x-1)-top_y];
        u = v / norm(v);
        if(strcmp(side, 'left'))
            if(ARTIFICIAL_WINDOW)
                % window should be twice as long
                bottom = floor([top_x top_y] + (l_size * u * 2)); % bottom = (x0,y0) + d*u -> direction of x1
            else
                bottom = floor([top_x top_y] + (l_size*u)); % bottom = (x0,y0) + d*u -> direction of x1
            end
        else % side == 'right'
            if(ARTIFICIAL_WINDOW)
                % window should be twice as long
                bottom = floor([top_x top_y] - (l_size * u * 2)); % bottom = (x0,y0) - d*u -> direction of x0
            else
                bottom = floor([top_x top_y] - (l_size*u)); % bottom = (x0,y0) - d*u -> direction of x0
            end
        end
        
        % build bottom perp line
        bottom_perp_b = bottom(2) - perp_slope*bottom(1); % perp intercept
        bottom_perp_poly = [perp_slope, bottom_perp_b]; % built the coefficient vector
        
        % calculate BR
        v = [-1, polyval(bottom_perp_poly, bottom(1)-1)-bottom(2)]; % v = (x1,y1)-(x0,y0)
        u = v / norm(v); % u = normalized v
        if(ARTIFICIAL_WINDOW)
            % window should be twice as wide
            BR = floor(bottom - (w_size * u * 2)); % BL = (x0,y0) - d*u -> direction of x0 
            BL = floor(bottom + (w_size * u * 2)); % BL = (x0,y0) + d*u -> direction of x1 
        else
            BR = floor(bottom - (w_size * u)); % BL = (x0,y0) - d*u -> direction of x0 
            BL = floor(bottom + (w_size * u)); % BL = (x0,y0) + d*u -> direction of x1 
        end
        
        % make sure we're not out of bounds
        TL(1) = max(min(TL(1),size(border_seg,1)),1);
        TR(1) = max(min(TR(1),size(border_seg,1)),1);
        BR(1) = max(min(BR(1),size(border_seg,1)),1);
        BL(1) = max(min(BL(1),size(border_seg,1)),1);
        TL(2) = max(min(TL(2),size(border_seg,2)),1);
        TR(2) = max(min(TR(2),size(border_seg,2)),1);
        BR(2) = max(min(BR(2),size(border_seg,2)),1);
        BL(2) = max(min(BL(2),size(border_seg,2)),1);
        
        if(exist('fd','var'))
            % write polynom slope to file
            if(ARTIFICIAL_WINDOW)
                fprintf(fd, artificail_slope_format, sliceNum, curr_slice_poly(1));                
            else
                fprintf(fd, slope_format, sliceNum, curr_slice_poly(1));
            end

            % write [TL, TR, BR, BL, sliceNum] to file
            if(ARTIFICIAL_WINDOW)
                fprintf(fd, artificial_coords_format, sliceNum, TL(1), TL(2), TR(1), TR(2), BR(1), BR(2), BL(1), BL(2));
            else
                fprintf(fd, coords_format, sliceNum, TL(1), TL(2), TR(1), TR(2), BR(1), BR(2), BL(1), BL(2));
            end
        end
    end
end



function [top_x, top_y, curr_slice_poly] = generateArtificialTop(sliceNum, hipsSeg, side)
% generateArtificialTop generates a window clue based on geometrical 
% clues we have.
%   will locate the window at a slope of 2 at distance of about 60 pixels 
%       from the top and 60 pixels from the middle, at a slope of 2 or -2.
%   INPUTS: sliceNum = current slice
%           hipsSeg = segmentation of the pelvis area, will be used for
%           geometrical clues
    
    square = getConvhullSquare(hipsSeg(:,:,sliceNum));
    xmiddle = floor((square(2) + square(1))/2);
    % square = [xmin xmax ymin ymax]
    
    top_y = size(hipsSeg,2) - (square(4) - 60);
    if(strcmp(side, 'left'))
        top_x = xmiddle + 60;
        slope = 2;
    else
        top_x = xmiddle - 60;
        slope = 2;
    end
    intercept = top_y - slope*top_x;
    % curr_slice_poly(1) = slope; curr_slice_poly(2) = intercept
    curr_slice_poly = [slope, intercept];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   code for printign the distances from the pelvis lanmarks
%       
%     distance_from_right_format = [filename ' dist from right %d ' side ' : %f \n'];
%     distance_from_left_format = [filename ' dist from left %d ' side ' : %f \n'];
%     distance_from_top_format = [filename ' dist from top %d ' side ' : %f \n'];
%     distance_from_bottom_format = [filename ' dist from bottom %d ' side ' : %f \n'];
%
%     % distances from all sides
%     square = getConvhullSquare(hipsSeg(:,:,sliceNum));
%     xmiddle = floor((square(2) + square(1))/2);
%     % square = [xmin xmax ymin ymax]
%     if(strcmp(side, 'left'))
%         % distance from right is (square(2) - max(TL(1),TR(1),BR(1),BL(1))
%         dist_from_right = (square(2) - max([TL(1),TR(1),BR(1),BL(1)]));
%         % distance from left is (min(TL(1),TR(1),BR(1),BL(1)) - xmiddle)
%         dist_from_left = (min([TL(1),TR(1),BR(1),BL(1)]) - xmiddle);
%     else
%         % distance from right is (xmiddle - max(TL(1),TR(1),BR(1),BL(1))
%         dist_from_right = (xmiddle - max([TL(1),TR(1),BR(1),BL(1)]));
%         % distance from left is (min(TL(1),TR(1),BR(1),BL(1)) - square(1))
%         dist_from_left = (min([TL(1),TR(1),BR(1),BL(1)]) - square(1));
%     end
%     fprintf(fd, distance_from_left_format, sliceNum, dist_from_left);
%     fprintf(fd, distance_from_right_format, sliceNum, dist_from_right);
% 
%     % distance from top is square(4) - max(TL(2),TR(2),BR(2),BL(2))
%     dist_from_top = square(4) - max([TL(2),TR(2),BR(2),BL(2)]);
%     % distance from bottom is min([TL(2),TR(2),BR(2),BL(2)]) - square(3)
%     dist_from_bottom = min([TL(2),TR(2),BR(2),BL(2)]) - square(3);
%     fprintf(fd, distance_from_top_format, sliceNum, dist_from_top);
%     fprintf(fd, distance_from_bottom_format, sliceNum, dist_from_bottom);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

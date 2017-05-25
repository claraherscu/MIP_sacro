function [point1, point2, point3, point4, pelvis_start, pelvis_end] = getBBoxAroundJoint (border_seg, pixelSz, side)
% getBBoxAroundJoint extracts a bounding box around the sacroiliac joint
% based on the given segmentation of the joint
%   outputs: UL, LR - UpperLeft and LowerRight corners of the (3-d) bBox 

    %% use PCA to find the orientation of the bBox
    % collect all points that belong to the joint according to the seg.
    all_points = [];
    for slice_num = 1:size(border_seg, 3)
        [new_points_rows, new_points_cols] = find(border_seg(:,:,slice_num));
        new_points = [new_points_rows, new_points_cols];
        all_points = [all_points; new_points];
    end
    
    [pelvis_start, pelvis_end] = getStartEnd(border_seg);
    
    % use polyfit to find orientation
    degree = 1;
    p = polyfit(all_points(:,1), all_points(:,2), degree);
    
    % get all the points up to certain distance from this line
    distances = zeros(size(all_points,1),1);
    p1 = [all_points(1,1), polyval(p, all_points(1,1))]; 
    p2 = [all_points(size(all_points,1),1), polyval(p, all_points(size(all_points,1),1))]; 
    for idx = 1:size(all_points,1)
        point = all_points(idx,:);
        distances(idx) = getDistanceFromPoly(point, p1, p2);
    end
    
    % take two points farthest from each other, under a distance threshold
    thresh = 1;
    under_thresh = find(distances < thresh);
    [~, minIdx] = min(all_points(under_thresh,1));
    [~, maxIdx] = max(all_points(under_thresh,1));
    minPoint = all_points(under_thresh(minIdx),:);
    maxPoint = all_points(under_thresh(maxIdx),:);
    
    % get perpendicular vector
    original_slope = p(1); % p is the coefficient vector of the polyfit
    perp_slope = -1/original_slope; % perpendicular slope is -1/slope
    
    % calculate the bBox bounds
%     pixelSz = info.score(1,end-3);
    wanted_distance = ceil(30/pixelSz); % we want ~3cm in each direction

    if(strcmp(side, 'left'))
        point1 = floor(maxPoint + [-0.5*wanted_distance, perp_slope*wanted_distance]);
        point2 = floor(maxPoint + [0.5*wanted_distance, -perp_slope*wanted_distance]);
        point3 = floor(minPoint + [-0.5*wanted_distance, perp_slope*wanted_distance]);
        point4 = floor(minPoint + [0.5*wanted_distance, -perp_slope*wanted_distance]);
    else
        point1 = floor(maxPoint + [wanted_distance, perp_slope*wanted_distance]);
        point2 = floor(maxPoint + [-wanted_distance, -perp_slope*wanted_distance]);
        point3 = floor(minPoint + [wanted_distance, perp_slope*wanted_distance]);
        point4 = floor(minPoint + [-wanted_distance, -perp_slope*wanted_distance]);
    end
end


function [dist] = getDistanceFromPoly(point, p1, p2)

    dist = abs(det([p2 - p1; point - p1]))/norm(p2 - p1);

end
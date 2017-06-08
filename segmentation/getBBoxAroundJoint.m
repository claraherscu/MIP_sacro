function [point1, point2, point3, point4, pelvis_start, pelvis_end] = getBBoxAroundJoint (border_seg, pixelSz, side)
% getBBoxAroundJoint extracts a bounding box around the sacroiliac joint
% based on the given segmentation of the joint
%   outputs: 4 points describing the box, start slice and end slice

    %% use regression to find the orientation of the bBox
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
    while(p1(1) == p2(1))
        p2_x = all_points(size(all_points,1)-1,1);
        p2 = [p2_x, polyval(p, p2_x)]; 
    end
    for idx = 1:size(all_points,1)
        point = all_points(idx,:);
        distances(idx) = getDistanceFromPoly(point, p1, p2);
    end
    
    % take two points farthest from each other, under a distance threshold
    thresh = 1;
    under_thresh = find(distances < thresh);
%     while (isempty(under_thresh))
%         thresh = thresh + 1;
%         under_thresh = find(distances < thresh);
%     end
    [~, minIdx] = min(all_points(under_thresh,1));
    [~, maxIdx] = max(all_points(under_thresh,1));
    
    % get perpendicular vector
    original_slope = p(1); % p is the coefficient vector of the polyfit
    perp_slope = -1/original_slope; % perpendicular slope is -1/slope
    
    % calculate the bBox bounds
%     pixelSz = info.score(1,end-3);
    wanted_distance = ceil(30/pixelSz); % we want ~3cm in each direction

    if(strcmp(side, 'left'))
        minPoint = all_points(under_thresh(minIdx),:) + [35,0];
        maxPoint = all_points(under_thresh(maxIdx),:) - [35,0];
        point1 = floor(maxPoint + [-0.5*wanted_distance, perp_slope*wanted_distance]);
        point2 = floor(maxPoint + [0.5*wanted_distance, -perp_slope*wanted_distance]);
        point3 = floor(minPoint + [-0.5*wanted_distance, perp_slope*wanted_distance]);
        point4 = floor(minPoint + [0.5*wanted_distance, -perp_slope*wanted_distance]);
    else
        minPoint = all_points(under_thresh(minIdx),:) - [35,0];
        maxPoint = all_points(under_thresh(maxIdx),:) + [35,0];
        point1 = floor(maxPoint + [0.5*wanted_distance, perp_slope*wanted_distance]);
        point2 = floor(maxPoint + [-0.5*wanted_distance, -perp_slope*wanted_distance]);
        point3 = floor(minPoint + [0.5*wanted_distance, perp_slope*wanted_distance]);
        point4 = floor(minPoint + [-0.5*wanted_distance, -perp_slope*wanted_distance]);
    end
    
    % make sure we are not out of bounds
    point1(1) = max(min(point1(1),size(border_seg,1)),1);
    point2(1) = max(min(point2(1),size(border_seg,1)),1);
    point3(1) = max(min(point3(1),size(border_seg,1)),1);
    point4(1) = max(min(point4(1),size(border_seg,1)),1);
    point1(2) = max(min(point1(2),size(border_seg,2)),1);
    point2(2) = max(min(point2(2),size(border_seg,2)),1);
    point3(2) = max(min(point3(2),size(border_seg,2)),1);
    point4(2) = max(min(point4(2),size(border_seg,2)),1);
end


function [dist] = getDistanceFromPoly(point, p1, p2)

    if(~abs(det([p2 - p1; point - p1])))
        display('ahahahahahah');
    end
    dist = abs(det([p2 - p1; point - p1]))/norm(p2 - p1);

end
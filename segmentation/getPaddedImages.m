function [padded_L, padded_R] = getPaddedImages (hipsSeg, segBorder)
    % find the center of the conv of the pelvis and mirror around it.
    x_middle = getXMiddle(hipsSeg);
    
    % pad the image to do the right flip
    diff = (x_middle - ((size(hipsSeg,1) - x_middle)));
    if (diff > 0)
        % should pad on the left of the image (big Xs)
        padded_L = padarray(segBorder.L, [diff 0], 'post');
        padded_R = padarray(segBorder.R, [diff 0], 'post');
    else
        % should pad on the right of the image (small Xs)
        padded_L = padarray(segBorder.L, [-diff 0], 'pre');
        padded_R = padarray(segBorder.R, [-diff 0], 'pre');
    end
end

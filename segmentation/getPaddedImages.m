function [padded_L, padded_R, padded_hips, padded_original, diff] = getPaddedImages (hipsSeg, segBorder, original_vol)
    % find the center of the conv of the pelvis and mirror around it.
    x_middle = getXMiddle(hipsSeg);
    
    % pad the image to do the right flip
    diff = (x_middle - ((size(hipsSeg,1) - x_middle)));
    if (diff > 0)
        % should pad on the left of the image (big Xs)
        padded_L = padarray(segBorder.L, [diff 0], 'post');
        padded_R = padarray(segBorder.R, [diff 0], 'post');
        padded_hips = padarray(hipsSeg, [diff 0], 'post');
        if (nargin > 2)
            padded_original = padarray(original_vol, [diff 0], 'post');
        end
    else
        % difference was negative, can't pad with negative values
        % should pad on the right of the image (small Xs)
        padded_L = padarray(segBorder.L, [-diff 0], 'pre');
        padded_R = padarray(segBorder.R, [-diff 0], 'pre');
        padded_hips = padarray(hipsSeg, [-diff 0], 'pre');
        if (nargin > 2)
            padded_original = padarray(original_vol, [-diff 0], 'pre');
        end
    end
end

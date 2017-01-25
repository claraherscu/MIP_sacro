function [ cutScore ] = getSegScore( score )
%GETSEGSCORE calculates the score of the segmentation - lower score is
%better

    scoreL = score(1,:);
    scoreR = score(2,:);
    cutScore = scoreL(9) + scoreR(9);
    
end


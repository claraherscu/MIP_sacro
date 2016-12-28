% test designated to finding best initialization for the ilium bone

%loading segmentation scores from past runs
load segScoresSmallIliumPrior; % param = 10
load segScoreLargeIliumPrior; % param = 3

X = 1:size(segScoreLargeIlium, 2);
scores = zeros(size(segScoreLargeIlium, 2));
scores2 = zeros(size(segScoreLargeIlium, 2));

for i = 1:size(segScoreLargeIlium, 2)
    score = segScores(1,i);
    scores(i) = score{1}(1,9);
%     disp(scores(i));
    score = segScoreLargeIlium(1,i);
    scores2(i) = score{1}(1,9);
%     disp(scores2(i));
end

dispScore = [scores(1) scores2(1); scores(2) scores2(2); ...
    scores(3) scores2(3); scores(4) scores2(4); scores(5) scores2(5)];
bar(X,dispScore);
for j = 1:numel(X)
    text(X(j),dispScore(j,1), num2str(dispScore(j,1), '%0.0f'), ...
        'HorizontalAlignment','center',...
        'VerticalAlignment','bottom',...
        'color','b');
    text(X(j),dispScore(j,2), num2str(dispScore(j,2), '%0.0f'), ...
        'HorizontalAlignment','center',...
        'VerticalAlignment','top', ...
        'color','r');
end

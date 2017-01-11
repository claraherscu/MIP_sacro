%% looking for the best parameter for ilium initialization
% the method: i will run the minCut many times with a change in the ilium
% initialization parameter, and find the one with average best score

load matlabData;
basefolder = 'D://MIP_sacro/sacro/dataset/';
dataWithCanny = data;
% 
% initParams = 2:2:42;
% for i = 5:20
%     fPath = [basefolder, dataWithCanny{i}.accessNum];
%     scoresForThisSample = [];
%     for initIliumParam = 2:2:42
%         outfile = ['_iliumInit_' num2str(initIliumParam)];
%         [ seg, score, ~ ] = segmentSijTestParam( fPath, outfile, initIliumParam );
%         myScore = getSegScore(score);
%         display(['for ', num2str(initIliumParam), ' got ', num2str(myScore)]);
%         scoresForThisSample(end+1) = myScore;
%     end
%     [bestScore,bestIndex] = min(scoresForThisSample);
%     display(['the best score for this sample is:', num2str(bestScore(1)), ...
%         ' the init parameter for this score is:', num2str(initParams(bestIndex(1)))]);
%     figure;
%     bar(initParams, scoresForThisSample, 'blue');
%     saveas(gcf, ['testingParameters/scoresForSample',num2str(i),'.jpg']);
% end

i = 6;
fPath = [basefolder, dataWithCanny{i}.accessNum];
scoresForThisSample = [];
initIliumParam = 10;
outfile = ['_iliumInit_another_' num2str(initIliumParam)];
[ seg, score, ~ ] = segmentSijTestParam( fPath, outfile, initIliumParam );
myScore = getSegScore(score);
display(['for ', num2str(initIliumParam), ' got ', num2str(myScore)]);
scoresForThisSample(end+1) = myScore;
[bestScore,bestIndex] = min(scoresForThisSample);
display(['the best score for this sample is:', num2str(bestScore(1)), ...
    ' the init parameter for this score is:', num2str(initParams(bestIndex(1)))]);
figure;
bar(initParams, scoresForThisSample, 'blue');
saveas(gcf, ['testingParameters/scoresForSample',num2str(i),'.jpg']);


load matlabData

% manually selected failures upon data(1:70)
borderSegFailures = {'4015004870488', '4015006075518', '4015006017986', '4015006419774', '4015006419945', '4015004803404', '4015005777363',...
    '4015006138581', '4015006598468', '4015006554212', '4015006522124', '4015006348431', '4015004868530', '4015005425376', '4015006088494',...
    '4015006298427', '4015005874490', '4015005464650', '4015005428443', '4015005380217', '4015005416116', '4015005449878', '4015006233633',...
    '4015005501541', '4015005700513', '4015006831465', '4015005362745', '4015005428443_2', '4015006298427_2', '4015006348431_2', '4015006445479_2', ...
    '4015006598468_2', '4015006754599_2', '4015007119880_2', '4015007190566_2', '4015007411679_2', '4015007485414_2', '4015007503289_2', ...
    '4015007504323_2', '4015007505522_2', '4015007509858_2', '4015007513481_2', '4015007516373_2'};
borderSegFailRt = {'4015006407282', '4015006431281', '4015006263625', '4015005820494', '4015005848554', '4015005460482', '4015005928218',...
    '4015005360398', '4015005873846', '4015004835309_3', '4015006431281_2', '4015007507548_3', '4015007511536_2', '4015007511685_3',...
    '4015007515504_2', '4015007515726_2', '4015007516303_2'};
borderSegFailLt = {'4015005391114', '4015005769122', '4015006201223', '4015005753333', '4015005716425', '4015005334645', '4015005969234',...
    '4015004868530_2', '4015006201223_2', '4015006360124_3', '4015006898751_3', '4015007245987_2', '4015007505522_3', '4015007507548_2', '4015007507847_2',...
    '4015007509858_3', '4015007515942_2', '4015007516172_2'};
pelvisSegFailures = {'4015004853476', '4015004843912', '4015006627185', '4015006701858', '4015005386642', '4015005763550', '4015005893559', ...
    '4015005421901', '4015005365594', '4015005426026_4', '4015005729792_3', '4015006298427_3', '4015006862488_2', '4015005428443_3', '4015006940572_2', ...
    '4015006522124_2', '4015006522124_3', '4015006790477_2', '4015007422171_3', '4015007422171_4', '4015007505115_2', '4015007505796_3',...
    '4015007511274_2', '4015007511338_2', '4015007511573_2', '4015007512752_2', '4015007512752_3', '4015007513197_2', '4015007513398_2',...
    '4015007515442_2'};

% not abdominal: 4015005751587_3, 4015005751587_2, 4015005751587_4

%% first, collect all the data
pelvisFailGrades = [];
borderFailGrades = [];
borderSuccessGrades = [];
failGrades = zeros(5,1);
totalGrades = zeros(5,1);

for i = 1:numel(data)
    d = data{i};
    currAccessNum = d.accessNum;
    totalGrades(d.Rt + 1) =  totalGrades(d.Rt + 1) + 1;
    totalGrades(d.Lt + 1) =  totalGrades(d.Lt + 1) + 1;
    
    % did this example fail pelvis segmentation?
    isPelvisFailure = find(strcmp(pelvisSegFailures, currAccessNum));
    if (isPelvisFailure)
        pelvisFailGrades(end + 1) = d.Rt;
        pelvisFailGrades(end + 1) = d.Lt;
        continue;
    end
    
    % did this example fail both sides of border segmentation?
    isBorderFailure = find(strcmp(borderSegFailures, currAccessNum));
    if (isBorderFailure)
        borderFailGrades(end + 1) = d.Rt;
        borderFailGrades(end + 1) = d.Lt;
        failGrades(d.Rt + 1) =  failGrades(d.Rt + 1) + 1;
        failGrades(d.Lt + 1) =  failGrades(d.Lt + 1) + 1;
        continue;
    end
    
    % did it only fail on the left side?
    isLeftBorderFailure = find(strcmp(borderSegFailLt, currAccessNum));
    if (isLeftBorderFailure)
        borderFailGrades(end + 1) = d.Lt;
        borderSuccessGrades(end + 1) = d.Rt;
        failGrades(d.Lt + 1) =  failGrades(d.Lt + 1) + 1;
        continue;
    end
    
    % did it only fail on the right side?
    isRightBorderFailure = find(strcmp(borderSegFailRt, currAccessNum));
    if (isRightBorderFailure)
        borderFailGrades(end + 1) = d.Rt;
        borderSuccessGrades(end + 1) = d.Lt;
        failGrades(d.Rt + 1) =  failGrades(d.Rt + 1) + 1;
        continue;
    end
    
%     display(['d.accessNum ' d.accessNum]);
    borderSuccessGrades(end + 1) = d.Rt;
    borderSuccessGrades(end + 1) = d.Lt;
end

%% show summaries
% figure;
% histogram(categorical(pelvisFailGrades, [0, 1, 2, 3, 4]));
% title('Samples that failed pelvis segmentation');
% xlabel('Grade');
% ylabel('Number of Samples');

% display(mean(pelvisFailGrades));

figure;
histogram(borderFailGrades, [0, 1, 2, 3, 4]);
title('Failure of border segmentation');
xlabel('Grade');
ylabel('Number of Samples');
figure;
histogram(borderSuccessGrades, [0, 1, 2, 3, 4]);
title('Success of border segmentation');
xlabel('Grade');
ylabel('Number of Samples');

% display(mean(borderFailGrades)); display(mean(borderSuccessGrades));

percentageFails = failGrades ./ totalGrades;
display(percentageFails);
percentageSuccess = 1 - percentageFails;
display(percentageSuccess);
display(totalGrades - failGrades);

display(['overall success rate: ' num2str(1 - (sum(failGrades)/(sum(totalGrades) - numel(pelvisSegFailures))))]);
display(['success rate excluding grade 4 patients: ' num2str(1-(sum(failGrades(1:4))/(sum(totalGrades) - numel(pelvisSegFailures))))]);
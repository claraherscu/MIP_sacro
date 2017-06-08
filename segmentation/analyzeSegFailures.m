load matlabData

% manually selected failures upon data(1:70)
borderSegFailures = {'4015004870488', '4015006075518', '4015006017986',...
    '4015006419774', '4015006419945', '4015004803404', '4015005777363',...
    '4015006138581', '4015006598468', '4015006554212', '4015006522124',...
    '4015006348431', '4015004868530', '4015005425376', '4015006088494',...
    '4015006298427', '4015005874490', '4015005464650', '4015005428443',...
    '4015005380217', '4015005416116', '4015005449878', '4015006233633',...
    '4015005501541', '4015005700513', '4015006831465', '4015005362745'};
borderSegFailRt = {'4015006407282', '4015006431281', '4015006263625',...
    '4015005820494', '4015005848554', '4015005460482', '4015005928218',...
    '4015005360398', '4015005873846', '4015004835309_3'};
borderSegFailLt = {'4015005391114', '4015005769122', '4015006201223', ...
    '4015005753333', '4015005716425', '4015005334645', '4015005969234',...
    '015004868530_2'};
pelvisSegFailures = {'4015004853476', '4015004843912', '4015006627185', ...
    '4015006701858', '4015005386642', '4015005763550', '4015005893559', ...
    '4015005421901', '4015005365594'};

%% first, collect all the data
pelvisFailGrades = [];
borderFailGrades = [];
borderSuccessGrades = [];
failGrades = zeros(5,1);
totalGrades = zeros(5,1);

for i = 1:150
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
    
    display(['d.accessNum ' d.accessNum]);
    borderSuccessGrades(end + 1) = d.Rt;
    borderSuccessGrades(end + 1) = d.Lt;
end

%% show summaries
figure;
histogram(categorical(pelvisFailGrades, [0, 1, 2, 3, 4]));
title('Samples that failed pelvis segmentation');
xlabel('Grade');
ylabel('Number of Samples');

display(mean(pelvisFailGrades));

figure;
histogram(categorical(borderFailGrades, [0, 1, 2, 3, 4]));
title('Failure of border segmentation');
xlabel('Grade');
ylabel('Number of Samples');
figure;
histogram(categorical(borderSuccessGrades, [0, 1, 2, 3, 4]));
title('Success of border segmentation');
xlabel('Grade');
ylabel('Number of Samples');

display(mean(borderFailGrades)); display(mean(borderSuccessGrades));

percentageFails = failGrades ./ totalGrades;
display(percentageFails);
percentageSuccess = 1 - percentageFails;
display(percentageSuccess);
display(totalGrades - failGrades);

display(['overall success rate: ' num2str(1 - sum(failGrades)/300)]);
display(['success rate excluding grade 4 patients: ' num2str(1 - sum(failGrades(1:4))/300)]);
%% run segmentation: segmenting SIJ, extracting borders, extracting windows
DEBUG_FLAG = 1; % will only write to log when this flag is on
SEGMENTATION_FLAG = 0; % will only run segmentation when this flag is on
SUCCESSFUL_ONLY_FLAG = 0; % will only extract borders for successful segmentation if this flag is on

load matlabData;
basefolder = '/cs/casmip/clara.herscu/git/MIP_sacro/dataset/';

% run segmentation
if(SEGMENTATION_FLAG)
    runSegmentationFunc(basefolder, data, 1, numel(data));
end

log_filename = 'logWithArtificialWindows';
% run border segmentation and write to log
segmentBordersFunc(basefolder, data, 1, numel(data), DEBUG_FLAG, log_filename, SUCCESSFUL_ONLY_FLAG);
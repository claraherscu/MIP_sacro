% read csv file
basefolder = 'D://MIP_sacro/sacro_new/';
filename = '270417.csv';
raw_data = csvread([basefolder filename], 1, 0);

% create the struct to hold the data
access_col = 1; right_grade_col = 2; left_grade_col = 3;
new_data = {};
all_folders = dir('D:\MIP_sacro\sacro_new\Acc_15_1_17\data');
access_nums = raw_data(:, access_col);
access_nums = arrayfun(@(x) num2str(x), access_nums, 'UniformOutput', false);
for i = 3:numel(all_folders)
    % what raw data does this access_num match?
    ix = find(cellfun(@(s) ~isempty(strfind(s, all_folders(i).name(1:13))), access_nums));
    s = struct('Rt', raw_data(ix, right_grade_col), 'Lt', raw_data(ix, left_grade_col), ...
        'accessNum', all_folders(i).name);
    display(['folder name is: ', all_folders(i).name, ...
        ' and raw name found was: ' num2str(raw_data(ix, access_col))]);
    new_data{end+1} = s;
end

load matlabData;
data = [data, new_data];
save('MAT files\newMatlabData.mat', 'data');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % create the struct to hold the data
% access_col = 1; right_grade_col = 2; left_grade_col = 3;
% new_data = {};
% for i = 1:size(raw_data, 1)
%     s = struct('Rt', raw_data(i, right_grade_col), 'Lt', raw_data(i, left_grade_col), ...
%         'accessNum', num2str(raw_data(i, access_col)));
%     new_data{end+1} = s;
% end

% % ignore the scans that are not axial
% all_folders = dir('D:\MIP_sacro\sacro_new\Acc_15_1_17\data');
% % saving all irrelevant folder names
% non_axial_folders = '';
% % skipping folders 1 and 2 1 is '.' and 2 is '..'
% for i = 20:numel(all_folders)
%     fPath = ['D:\MIP_sacro\sacro_new\Acc_15_1_17\data\' all_folders(i).name];
%     dicomInfo = dicom_folder_info(fPath);
%     if (~strfind(dicomInfo.DicomInfo.ImageType, 'AXIAL'))
%         display(['accessNum: ' all_folders(i).name ' is not axial']);
%         non_axial_folders = [non_axial_folders; all_folders(i).name];
%     end
%     clear dicomInfo;
% end

% display(non_axial_folders);

% not_found = '';
% for i = 1:numel(data)
%     if (~strfind(all_folder_names, data{i}.accessNum))
%         not_found = [not_found; data{i}.accessNum];
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
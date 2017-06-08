clear;
load matlabData;
basefolder = 'D://MIP_sacro/sacro/dataset/';

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

simmetricBorder = ones(numel(data));

% old bboxes
% for i = 133:150%:numel(data)
%     d = data{i};
%     
%     % currently working only on successful segs
%     isPelvisFailure = find(strcmp(pelvisSegFailures, d.accessNum));
%     if(isPelvisFailure)
%         continue;
%     end
%     isBorderFailure = find(strcmp(borderSegFailures, d.accessNum));
%     if(isBorderFailure)
%         continue;
%     end
%     isLeftBorderFailure = find(strcmp(borderSegFailLt, d.accessNum));
%     if(isLeftBorderFailure)
%         continue;
%     end
%     isRightBorderFailure = find(strcmp(borderSegFailRt, d.accessNum));
%     if(isRightBorderFailure)
%         continue;
%     end
%     
% 
%     segR = [d.accessNum, 'R'];
%     segL = [d.accessNum, 'L'];
%     segfile = [basefolder, d.accessNum,'/segmentation.mat'];
%     if exist(segfile,'file')
%         load(segfile)
%         if exist('seg','var')               
%             disp(d.accessNum);
%             pixelSz = info.score(1,end-3);
%             pixelZSz = info.score(1,end-2);
%             segBorder = segmentRelevantBorders(seg,pixelSz,pixelZSz);
% 
%             % save border
%             outfile = [basefolder, d.accessNum, '/segBorderEqualized'];
%             save(outfile, 'segBorder', 'info', 'segBorder');
%             saveBorderSeg(segBorder.L, segBorder.R, [basefolder d.accessNum], 'segBorderEqualized');
%             
%             % get Bbox
%             [l_point1, l_point2, l_point3, l_point4, l_pelvis_start, l_pelvis_end] = getBBoxAroundJoint (segBorder.L, pixelSz, 'left');
%             [r_point1, r_point2, r_point3, r_point4, r_pelvis_start, r_pelvis_end] = getBBoxAroundJoint (segBorder.R, pixelSz, 'right');
%             
%             l_point1(2) = size(segBorder.L,2) - l_point1(2);
%             l_point2(2) = size(segBorder.L,2) - l_point2(2);
%             l_point3(2) = size(segBorder.L,2) - l_point3(2);
%             l_point4(2) = size(segBorder.L,2) - l_point4(2);
%             r_point1(2) = size(segBorder.L,2) - r_point1(2);
%             r_point2(2) = size(segBorder.L,2) - r_point2(2);
%             r_point3(2) = size(segBorder.L,2) - r_point3(2);
%             r_point4(2) = size(segBorder.L,2) - r_point4(2);
%             
%             pelvis_start = max(l_pelvis_start, r_pelvis_start);
%             pelvis_end = min(l_pelvis_end, r_pelvis_end);
%             
%             % write to txt file
%             txtfilename = [basefolder 'bboxes_new/' d.accessNum];
%             format = '%d %d \n%d %d \n%d %d \n%d %d \n\n%d %d \n%d %d \n%d %d \n%d %d\n\n%d %d';
%             f = fopen([txtfilename '.txt'], 'wt');
%             fprintf(f, format, l_point1(1), l_point1(2), l_point2(1), l_point2(2), l_point3(1), l_point3(2), l_point4(1), l_point4(2), ...
%                 r_point1(1), r_point1(2), r_point2(1), r_point2(2), r_point3(1), r_point3(2), r_point4(1), r_point4(2), pelvis_start, pelvis_end);
%             fclose(f);
% 
%             % check if the border is simmetric
%             hipsSegPath = [basefolder data{i}.accessNum '/hipsSeg.mat'];
%             load(hipsSegPath)
%             isSimmetric = isSimmetricBorder(hipsSeg, segBorder, pixelSz);
%             if(~isSimmetric)
%                 simmetricBorder(i) = 0;
%                 display('border is not simmetric');
%                 equalized_img_path = [basefolder, data{i}.accessNum, '/pelvis_equalized.nii.gz'];
% %                 original_vol = dicom_read_volume(equalized_img_path);
% %                 dicomInfo = dicom_folder_info(equalized_img_path);
% %                 original_vol = dicom2niftiVol(original_vol, dicomInfo);
%                 new_equalized_img_path = strrep(equalized_img_path, '/', '\');
%                 equalized_struct = load_untouch_nii_gzip(new_equalized_img_path);
%                 equalized_vol = equalized_struct.img;
%                 newSegBorder = runBellmanFord(segBorder, hipsSeg, equalized_vol);
%                 if(~isempty(newSegBorder))
%                     saveBorderSeg(newSegBorder.L, newSegBorder.R, [basefolder d.accessNum], 'segBorderBellmanFordEqualized');
%                     outfile = [basefolder, d.accessNum, '/segBorderBellmanFordEqualized'];
%                     save(outfile, 'newSegBorder', 'info', 'newSegBorder');
%                 end
%             else
%                 display('border is simmetric');
%             end
%         end
%     end
% end

% new, per slice bboxes
for i = 1%:10%:numel(data)
    d = data{i};
    
%     % currently working only on successful segs
%     isPelvisFailure = find(strcmp(pelvisSegFailures, d.accessNum));
%     if(isPelvisFailure)
%         continue;
%     end
%     isBorderFailure = find(strcmp(borderSegFailures, d.accessNum));
%     if(isBorderFailure)
%         continue;
%     end
%     isLeftBorderFailure = find(strcmp(borderSegFailLt, d.accessNum));
%     if(isLeftBorderFailure)
%         continue;
%     end
%     isRightBorderFailure = find(strcmp(borderSegFailRt, d.accessNum));
%     if(isRightBorderFailure)
%         continue;
%     end
    

    segR = [d.accessNum, 'R'];
    segL = [d.accessNum, 'L'];
    segfile = [basefolder, d.accessNum,'/segmentation.mat'];
    if exist(segfile,'file')
        load(segfile)
        if exist('seg','var')               
            disp(d.accessNum);
            pixelSz = info.score(1,end-3);
            pixelZSz = info.score(1,end-2);
            segBorder = segmentRelevantBorders(seg,pixelSz,pixelZSz);

            % save border
            outfile = [basefolder, d.accessNum, '/segBorderEqualized'];
            save(outfile, 'segBorder', 'info', 'segBorder');
            saveBorderSeg(segBorder.L, segBorder.R, [basefolder d.accessNum], 'segBorderEqualized');
            


            % check if the border is simmetric
            hipsSegPath = [basefolder data{i}.accessNum '/hipsSeg.mat'];
            load(hipsSegPath)
            isSimmetric = isSimmetricBorder(hipsSeg, segBorder, pixelSz);
            if(~isSimmetric)
                simmetricBorder(i) = 0;
                display('border is not simmetric');
                equalized_img_path = [basefolder, data{i}.accessNum, '/pelvis_equalized.nii.gz'];
                new_equalized_img_path = strrep(equalized_img_path, '/', '\');
                equalized_struct = load_untouch_nii_gzip(new_equalized_img_path);
                equalized_vol = equalized_struct.img;
                newSegBorder = runBellmanFord(segBorder, hipsSeg, equalized_vol);
                if(~isempty(newSegBorder))
                    saveBorderSeg(newSegBorder.L, newSegBorder.R, [basefolder d.accessNum], 'segBorderBellmanFordEqualized');
                    outfile = [basefolder, d.accessNum, '/segBorderBellmanFordEqualized'];
                    save(outfile, 'newSegBorder', 'info', 'newSegBorder');
                end
                segBorder = newSegBorder;
            else
                display('border is simmetric');
            end
            
            % get Bboxes & write to txt file
            txtfilename = [basefolder 'bboxes_per_slice/' d.accessNum];
            f = fopen([txtfilename '.txt'], 'wt');
            getBBoxPerSlice (segBorder.L, pixelSz, 'left', f);
            getBBoxPerSlice (segBorder.R, pixelSz, 'right', f);
            fclose(f);
        end
    end
end


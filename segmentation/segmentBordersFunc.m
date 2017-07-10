function [] = segmentBordersFunc(basefolder, data, start_index, end_index, DEBUG_FLAG, log_filename, SUCCESSFUL_ONLY_FLAG)
    
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

    simmetricBorder = ones(numel(data));

    WRITE_TO_FILE = 0;
    
    % writing to log
    if(DEBUG_FLAG)
        txtfilename = [basefolder 'bboxes_per_slice/' log_filename];
        if(exist([txtfilename '.txt'], 'file'))
            % popup box to make sure we want to delete the file TODO: fix, abort does not show
            choice = questdlg(['deleting log file: ' txtfilename '. are you sure you want to continue?'], 'Deleting log file!', 'Continue', 'Abort');
            % handle response
            switch choice
                case 'Continue'
                    WRITE_TO_FILE = 1;
                    f = fopen([txtfilename '.txt'], 'wt');
            end
        else
            WRITE_TO_FILE = 1;
            f = fopen([txtfilename '.txt'], 'wt');
        end
    end
    
    for i = start_index:end_index
        d = data{i};
        display(['i:' num2str(i)]);
        SUCCESSFUL_LEFT = 1;
        SUCCESSFUL_RIGHT = 1;

        % failed pelvis segmentations have nothing to do anyway -- skipping
        isPelvisFailure = find(strcmp(pelvisSegFailures, d.accessNum));
        if(isPelvisFailure)
            SUCCESSFUL_LEFT = 0;
            SUCCESSFUL_RIGHT = 0;
            continue;
        end
        
        isBorderFailure = find(strcmp(borderSegFailures, d.accessNum));
        if(isBorderFailure)
            SUCCESSFUL_LEFT = 0;
            SUCCESSFUL_RIGHT = 0;
            continue;
        end
        isLeftBorderFailure = find(strcmp(borderSegFailLt, d.accessNum));
        if(isLeftBorderFailure)
            SUCCESSFUL_LEFT = 0;
            continue;
        end
        isRightBorderFailure = find(strcmp(borderSegFailRt, d.accessNum));
        if(isRightBorderFailure)
            SUCCESSFUL_RIGHT = 0;
            continue;
        end
        
        % if needed, writing to log
        if (WRITE_TO_FILE)
            succ_format = [d.accessNum ' binary success left : %d \n'];
            fprintf(f, succ_format, SUCCESSFUL_LEFT);
            succ_format = [d.accessNum ' binary success right : %d \n'];
            fprintf(f, succ_format, SUCCESSFUL_RIGHT);
            grade_format = [d.accessNum ' grade left : %d \n' d.accessNum ' grade right : %d \n'];
            fprintf(f, grade_format, d.Lt, d.Rt);
        end
        
        segR = [d.accessNum, 'R'];
        segL = [d.accessNum, 'L'];
        segfile = [basefolder, d.accessNum,'/segmentation.mat'];
        if exist(segfile,'file')
            load(segfile)
            if exist('seg','var')               
                disp(d.accessNum);
                
                pixelSz = info.score(1,end-3);
                pixelZSz = info.score(1,end-2);
%                 segBorder = segmentRelevantBorders(seg,pixelSz,pixelZSz);
% 
%                 % save border
%                 outfile = [basefolder, d.accessNum, '/segBorderEqualized'];
%                 save(outfile, 'segBorder', 'info', 'segBorder');
%                 saveBorderSeg(segBorder.L, segBorder.R, [basefolder d.accessNum], 'segBorderEqualized');

                segBorderFile = [basefolder, d.accessNum, '/segBorderEqualized.mat'];
                load(segBorderFile);

                % check if the border is simmetric
                hipsSegPath = [basefolder data{i}.accessNum '/hipsSeg.mat'];
                load(hipsSegPath)
                isSimmetric = isSimmetricBorder(hipsSeg, segBorder, pixelSz);
                display(isSimmetric)
                
%                 % if needed, writing to file
%                 if (WRITE_TO_FILE)
%                     algorithm_format = [d.accessNum ' algorithm : '];
%                     if(isSimmetric)
%                         fprintf(f, [algorithm_format 'Min-Cut\n']);
%                     else
%                         fprintf(f, [algorithm_format 'Bellman-Ford\n']);
%                     end
%                 end
                

                % can't do this on this computer because digraph was
                % introduced only on MatLab 2015!!
                
                % if not simmetric, segmenting border again using bellman-ford
%                 if(~isSimmetric)
%                     simmetricBorder(i) = 0;
%                     display('border is not simmetric');
%                     equalized_img_path = [basefolder, data{i}.accessNum, '/pelvis_equalized.nii.gz'];
%                     equalized_struct = load_untouch_nii_gzip(equalized_img_path);
%                     equalized_vol = equalized_struct.img;
%                     newSegBorder = runBellmanFord(segBorder, hipsSeg, equalized_vol);
%                     if(~isempty(newSegBorder))
%                         saveBorderSeg(newSegBorder.L, newSegBorder.R, [basefolder d.accessNum], 'segBorderBellmanFordEqualized');
%                         outfile = [basefolder, d.accessNum, '/segBorderBellmanFordEqualized'];
%                         save(outfile, 'newSegBorder', 'info', 'newSegBorder');
%                     end
                segBorderFile = [basefolder, d.accessNum, '/segBorderBellmanFordEqualized.mat'];
                if(exist(segBorderFile,'file'))
                    load(segBorderFile);
                    segBorder = newSegBorder;
                    % if needed, writing to file
                    if (WRITE_TO_FILE)
                        algorithm_format = [d.accessNum ' algorithm : '];
                        fprintf(f, [algorithm_format 'Bellman-Ford\n']);
                    end
                else
                    display('border is simmetric');
                    if (WRITE_TO_FILE)
                        algorithm_format = [d.accessNum ' algorithm : '];
                        fprintf(f, [algorithm_format 'Min-Cut\n']);
                    end
                end

                % get Bboxes & write to log file
                if (WRITE_TO_FILE)
                    getBBoxPerSlice (segBorder.L, pixelSz, 'left', f, d.accessNum);
                    getBBoxPerSlice (segBorder.R, pixelSz, 'right', f, d.accessNum);
                end

%                 % get big Bboxes & write to log file
%                 if (WRITE_TO_FILE)
%                     getBBoxAroundJoint (segBorder.L, pixelSz, 'left', f, d.accessNum);
%                     getBBoxAroundJoint (segBorder.R, pixelSz, 'right', f, d.accessNum);
%                 end

            end
        end
    end
    
    % closing file if we indeed opened it
    if (WRITE_TO_FILE)
        fclose(f);
    end
end
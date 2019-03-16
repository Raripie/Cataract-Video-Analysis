function [ Output ] = tipLocate_cf_0506 ( idxGroup_2, Input, selModel, centerline, addCenterline )
%%% There are 2 differences compared to *0328.m
ROI    = centerline.curvefit;
ROI (idxGroup_2.ch == 0) = 0;
idxROI.linear            = find(ROI == 1) ;
[idxROI.raw_row, idxROI.raw_col] = find(ROI == 1) ;
count = 1;   
%%
if strcmp(selModel.type, 'normal')
    if abs (selModel.p(1)) <= 1 
        if selModel.p(1) >= 0
            for i = min(idxROI.raw_col): max(idxROI.raw_col)
                c = i;
                idxROI.col(count) = i;
                idxROI.row(count) = find (centerline.curvefit(:,c));
                count = count+1;
            end  
        else
            for i = max(idxROI.raw_col):-1: min(idxROI.raw_col)
                c = i;
                idxROI.col(count) = i;
                idxROI.row(count) = find (centerline.curvefit(:,c));
                count = count+1;
            end
        end
    else
            for i = max(idxROI.raw_row): -1:min(idxROI.raw_row)
                r = i;
                idxROI.row(count) = i;
                idxROI.col(count) = find (centerline.curvefit(r,:));
                count = count+1;
            end   
    end
elseif strcmp(selModel.type, 'inverse')
    if abs (selModel.p(1)) <= 1             
        for i = max(idxROI.raw_row): -1:min(idxROI.raw_row)
            r = i;
            idxROI.row(count) = i;
            idxROI.col(count) = find (centerline.curvefit(r,:));
            count = count+1;
        end            
    else
        if selModel.p(1) >= 0
            for i = min(idxROI.raw_col): max(idxROI.raw_col)
                c = i;
                idxROI.col(count) = i;
                idxROI.row(count) = find (centerline.curvefit(:,c));
                count = count+1;
            end  
        else
            for i = max(idxROI.raw_col):-1: imin(idxROI.raw_col)
                c = i;
                idxROI.col(count) = i;
                idxROI.row(count) = find (centerline.curvefit(:,c));
                count = count+1;
            end
        end
    end        
end

    Output.Raw =  Input.Raw;
    Output.Col =  addCenterline.Col;
    Output.x   =  NaN;
    Output.y   =  NaN;
    Output.index = NaN;
    
if isempty(idxROI.linear)
    return;
    
else
    for i=1:3
        for k = 1:length(idxROI.row)
            test1 = Input.Raw(:,:,i);  
            cenData.Raw (k,i) = test1 (idxROI.row(k),idxROI.col(k));
        end
    end

    test1 = rgb2hsv(Input.Raw) ;
    sat = test1(:,:,2);
        for k = 1:length(idxROI.row)
            cenData.Sat (k) = sat (idxROI.row(k),idxROI.col(k));
        end



    if ~isempty (idxROI.row )
        for ii=1:length(idxROI.row)
            %R = cenData.Raw(ii,1);
            Max = max(cenData.Raw(ii));  %% this is the 1st difference : adding Max_intensity, attention to 'medRatio.avg'
            RGB = cenData.Raw(ii,1)+cenData.Raw(ii,2)+cenData.Raw(ii,3);

            if RGB == 0
                ratio(ii) = 0;
            else
                ratio(ii) = Max/RGB;
            end
        end
        medRatio.avg = medfilt1(ratio, 11); % cenData.Sat; 11
        medRatio.sat  = medfilt1(cenData.Sat, 11); % cenData.Sat; 11
        
        level = graythresh(medRatio.avg);
        BW_s = im2bw(medRatio.avg,level);        
%         level = graythresh(medRatio.sat);
%         BW_s = im2bw(medRatio.sat,level);
        
        s = find(BW_s, 1);
        if s>1
            Output.x    = idxROI.col (s-1);
            Output.y    = idxROI.row (s-1);           
        else
            s = find(BW_s == 0);
            Output.x    = idxROI.col (s(end));
            Output.y    = idxROI.row (s(end)); 
        end

        win = 4;
        if ~isempty (Output.y )
            Output.Raw (Output.y-win :Output.y+win , Output.x-win : Output.x+win, 1) = zeros(win*2+1);
            Output.Raw (Output.y-win :Output.y+win , Output.x-win : Output.x+win, 2) = ones (win*2+1);
            Output.Raw (Output.y-win :Output.y+win , Output.x-win : Output.x+win, 3) = ones (win*2+1);

            Output.Col (Output.y-win :Output.y+win , Output.x-win : Output.x+win, 1) = zeros(win*2+1);
            Output.Col (Output.y-win :Output.y+win , Output.x-win : Output.x+win, 2) = ones (win*2+1);
            Output.Col (Output.y-win :Output.y+win , Output.x-win : Output.x+win, 3) = ones (win*2+1);
        end
    end
end
Output.index = s(end);  %% this is the 2nd difference : Output.index = s;
Output.row   = idxROI.row;
Output.col   = idxROI.col;
end
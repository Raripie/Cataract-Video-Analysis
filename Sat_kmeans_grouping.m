function [ sat_kmeans, idxGroup ] = Sat_kmeans_grouping( clusterNum, Raw_denoise, BW_snk )

        hsv_image = rgb2hsv (Raw_denoise);
        idx = find(BW_snk > 0);
        sat = hsv_image(:,:,2); %
        %sat=Raw_denoise(:,:,2);
        sat_limbus = double(sat(idx));
        data_sat = sat_limbus';
        snk_label = repmat(BW_snk,[1 1 3]);
        
        %[cluster_idx, ~] = kmeans(data_sat',clusterNum,'distance','sqEuclidean', ...
        %                                  'Replicates',1,...
        %                                  'emptyaction', 'singleton', ...
        %                                  'MaxIter', 300);
         
        len=length(idx);
        for xxx=1:len
            if data_sat(1,xxx)>=0.18 %|| data_sat(1,xxx)<0.4%&& data_sat(1,xxx)<0.7%0.36
                cluster_idx(xxx,1)=double(1);
            else cluster_idx(xxx,1)=double(2);
            end
        end  %YZ
        
        
        minSat = min(data_sat);
        indexMin = find(data_sat == minSat, 1);
        labelMin = cluster_idx(indexMin);

        idx_C = zeros(size(cluster_idx));
        idx_C(cluster_idx == labelMin) =1; %%replace labelMin by 1  YZ
        idx_C(cluster_idx ~= labelMin) =2;

        sat_gLabel = zeros(size(sat)) ;
        for i = 1:length(idx)
            index = idx(i);
            sat_gLabel(index) = idx_C(i);
        end

        sat_gLabel = repmat(sat_gLabel,[1 1 3]);
        %sat_kmeans = cell(1,clusterNum);
        sat_kmeans = cell(1,clusterNum+1);          %% newly added on 0402

        colorInfo = Raw_denoise ;
        colorInfo(snk_label ~= 1) = 0;
        colorInfo(sat_gLabel == 0) = 0;
        colorInfo(sat_gLabel == 2) = 0;
        sat_kmeans{1} = colorInfo;

        colorInfo = Raw_denoise ;
        colorInfo(snk_label ~= 1) = 0;
        colorInfo(sat_gLabel == 0) = 0;
        colorInfo(sat_gLabel == 1) = 0;
        sat_kmeans{2} = colorInfo;  
        
        sat_kmeans{3} = sat_kmeans{1}+sat_kmeans{2};%% newly added on 0402
        
        idxGroup = cell(1,clusterNum);
        for i = 1:clusterNum
            idxGroup{i} = zeros(size(sat));
            idxGroup{i} (sat_gLabel(:,:,1) == i) = 1;   
        end
        
        
        %% This part for sat=Raw_denoise(:,:,3) only. If it is hsv_image(:,:,2), comment it.
        %m=idxGroup{1};
        %idxGroup{1}=idxGroup{2};
        %idxGroup{2}=m;
            
end


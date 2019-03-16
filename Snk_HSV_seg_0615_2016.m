function [ Input, Output, centerline,num ] = Snk_HSV_seg_0615_2016 ( para )

% if (para.ind >= 1300) %% 2 * 30 + 2, 16 * 30 + 27,  750 + 28
%    disp('pause');
% end

%% This is the file modified from 'Snk_HSV_seg_03282015.m'
    clusterNum = 2;  
    centerline.line = zeros(para.Height, para.Width);
    Raw_denoise = im2double ( para.Color_denoise (:, :, :, para.ind) );
    BW_snk = para.SnkArea (:, :, para.ind);%para.ind
    BW_snk=bwmorph(BW_snk,'thin',15);
    
    %% Compute the binary map inside pupil
    [ sat_kmeans, idxGroup ] = Sat_kmeans_grouping( clusterNum, Raw_denoise, BW_snk );
    [idxGroup_1, idxGroup_2 ] = Process_idxGroup( idxGroup );
    
    %% Prepare Input
    Input.Raw = Raw_denoise;
    Input.BW  = idxGroup{2};
    Input.Sat_g1 = sat_kmeans{1};
    Input.ch = idxGroup_2.ch;
    
    %% Prepare Output
    Output.model.type = 'noModel';%% this line is added for model info.  
    
    %% Check whether the BM contains any information
    BW_fit = addBW_04042016_refine0615 ( idxGroup_1.in, para ); %% BW_fit = addBW_0506 ( idxGroup_1.in, para );
    
    %% YZ connected area 12/29/2018 
    %Output.num=NaN;
    %test=BW_fit.BW_2arms;
    %test(1:320)=0;
    %test1 = bwareaopen(test,100,4);
    %[L,num]=bwlabel(test1,4);
    
    %%
    
    
    
    
    
    
    
    
    
    
    %%              
    if bwarea(BW_fit.thin) <= 15 %10
        %hsv = rgb2hsv(Input.Raw) ;
        Output.Col =  Raw_denoise ;%hsv(:,:,1);
        Output.x = NaN;
        Output.y = NaN; 
        Output.index = NaN;
        Output.rate=NaN;
        num=0;
    else         
        %% Check whether the BM contains any information || here actually add the extra binary map already
%         [ ~, idxGroup_OutterLim ] = Sat_kmeans_grouping_OutterLim( clusterNum, Raw_denoise, BW_snk ); 
%         [ BW_fit, idxGroup_2 ] = refineBW_06152016( BW_fit, idxGroup_2, idxGroup_OutterLim);
        
        [ selModel, centerline, addCenterline ] = centerlineFit_0621_2016( centerline, para, BW_fit.BW_2arms, Input );  %% centerlineFit_0707 ( centerline, para, BW_fit.full, Input );
        [ Output ] = tipLocate_cf_0526 ( idxGroup_2, Input, selModel, centerline, addCenterline, BW_fit );      
        Output.model = selModel;
    end
    
    %% this line is added for BW info.
    Output.BW_fit = BW_fit;
end


%%
%%%% previous version what works well in video2
% function [ Input, Output, centerline ] = Snk_HSV_seg_0707 ( para, ind )
% 
% % if (ind >= 720 + 10 * 30 + 0)
% %    disp('pause');
% % end
% %% This is the file modified from 'Snk_HSV_seg_03282015.m'
%     clusterNum = 2;  
%     centerline.line = zeros(para.Height, para.Width);
% 
%     Raw_denoise = im2double ( para.Color_denoise (:,:,:, ind ));
%     BW_snk = para.SnkArea (:,:,ind); 
%     %% line 67-101 rewritten
%     [ sat_kmeans, idxGroup ] = Sat_kmeans_grouping( clusterNum, Raw_denoise, BW_snk );
%     %% line 109-122 rewritten
%     [ idxGroup_1, idxGroup_2 ] = Process_idxGroup( idxGroup ); % Process_idxGroup_0707( idxGroup, para )
%     %%              
%     Input.Raw = Raw_denoise;
%     Input.BW  = idxGroup{2};
%     %%Input.BW_2= idxGroup{1};
%     Input.Sat_g1 = sat_kmeans{1};
%     BW_fit = addBW_0506 ( idxGroup_1.in, para );
%     Input.ch = idxGroup_2.ch;
% 
%     Output.model.type = 'noModel';%% this line is added for model info.    
%     if sum(sum(BW_fit.thin)) <= 10 %% max(max(BW_fit.full)) == 0
%         Output.Col =  Raw_denoise ;
%         Output.index = NaN;        
%     else
%         [ selModel, centerline, addCenterline ] = centerlineFit_0707 ( centerline, para, BW_fit.full, Input );  % centerlineFit_0526, centerlineFit_0506              
%         %[ selModel ] = Renew_selMode( para.model, selModel, BW_fit.full); %%%% this line is added for forcept, not for needle; still need to test for needle
%         [ Output ] = tipLocate_cf_0526 ( idxGroup_2, Input, selModel, centerline, addCenterline ); % tipLocate_cf_0506 ( idxGroup_2, Input, selModel, centerline, addCenterline );       
%         Output.model = selModel;%% this line is added for model info.
%         % [ Constraint.this ] = CenterlineConstraint( centerline.curvefit );
%     end      
%     Output.BW_fit = BW_fit; %% this line is added for BW info.
% end
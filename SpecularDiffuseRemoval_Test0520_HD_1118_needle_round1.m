close all;
clc 

%%%%%%  Remember to Save centerline_area_constrint   %%%%%%%
writerVideo = VideoWriter('N1_600_F_S4');
open(writerVideo); 

% para.fileID = fopen('ver1_21_3_HD_0721_armInfo.txt','w');
% fprintf(para.fileID,'%12s %12s %12s %12s %12s %12s\n','ind','delta_ang', 'delta_error', 'cur_m_error', 'cur_m_ang','cur_m_ISx');

%% centerline_area_constrint = zeros(para.Height, para.Width, para.nFrames); % this is centerline_area_constrint, it changes with frames

    coor.x = NaN (para.nFrames,1);
    coor.y = NaN (para.nFrames,1);
    coor.index = NaN (para.nFrames,1);
    coor.rate = NaN (para.nFrames,1);
    coor.num = NaN (para.nFrames,1);

para.centerlineAC = ones(para.Height, para.Width); 
para.instrumentArea = zeros(para.Height, para.Width);

 %para.insertionAC  = constrinct_insertion; %
%para.top_constrict = top_constrict;  
 para.top_constrict = zeros(para.Height, para.Width);%
 para.noise_constrict = zeros(para.Height, para.Width);%noise_constrict;%

para.model1 = struct();
para.model2 = struct();
para.model = struct();

Thresh.b_inter = 15;
Thresh.y_diff = 15;
marker = coor;
marker.b = coor.index;

%     marker.tip1.x = NaN(length(marker.b), 1);
%     marker.tip1.y = NaN(length(marker.b), 1);
%     marker.tip1.b = NaN(length(marker.b), 1);
%     marker.tip2.x = NaN(length(marker.b), 1);
%     marker.tip2.y = NaN(length(marker.b), 1);
%     marker.tip2.b = NaN(length(marker.b), 1);
%     marker.diff_1 = NaN(length(marker.b), 1);
%     marker.diff_2 = NaN(length(marker.b), 1);
% marker.centroid.x = NaN(length(marker.b), 1);
% marker.centroid.y = NaN(length(marker.b), 1);
%%
% Thresh.b_inter is for blue markers between 2 interframes  % ii = 757;  % marker.b(ii:end) = coor.index(ii:end);
%% Assume that we know that the # of centerlines is 2. 
start = 1;
tempEnd = para.nFrames; % 1500

para.shadow = zeros(para.Height, para.Width, 'uint8');
shadow = zeros(para.Height, para.Width, 'uint8');
dimension = 16;

for i = 1 : para.nFrames   %% 30 * 16 %% para.nFrames 
    disp(i);
    para.ind = i;
    
    ss_ori = para.SnkArea (:, :, i);
    constrinct_insertion (:,:)= bwmorph(ss_ori,'thin', 10) - bwmorph(ss_ori,'thin', 50);  % Try SMALL_NUM_OF_ITERATIONS = 10 & LARGE_NUM_OF_ITERATIONS = 60 for iterations of morphological operations.
    constrinct_insertion (1 : 250, 1:300)=0;
    para.insertionAC  = constrinct_insertion;
    
    [ Input, Output, centerline ] = Snk_HSV_seg_0615_2016(para); % Snk_HSV_seg_0507 ( para, i );  % Snk_HSV_seg_0615_2016 ( para, i );   %% Snk_HSV_seg_0518_2016 ( para,i );  %% haven't tried  Snk_HSV_seg_0518_2016 ( para, i )   
    %[ Input, Output, centerline,num ] = Snk_HSV_seg_0615_2016(para);
    coor.x(i) = Output.x;
    coor.y(i) = Output.y;
    coor.index(i) = Output.index;
    coor.rate(i)=Output.rate;
    %coor.num(i)=num;
    shadow = makeShadow(coor, dimension, shadow, para, i);
    para.shadow = shadow;

%     Pre_Tip.t1.b = marker.tip1.b(i-1);
%     Pre_Tip.t1.b_move = marker.tip1.b(i-1) - marker.tip1.b(i-2);
%     Pre_Tip.t2.b = marker.tip2.b(i-1);
%     Pre_Tip.t2.b_move = marker.tip2.b(i-1) - marker.tip2.b(i-2);
%     
%     [Output, Forcept_output] = iterativeLR_0604( Input, Output, para, Pre_Tip) ;  % Output = iterativeLR_0520( Input, Output, para, marker.b(i-1) ) ;
%     marker = Store_blueMarker( Forcept_output, marker, i ) ;
%     
%     [Output, Forcept_output, marker ] = Forcept_Tip_Relocate_RedAsPerpenLine ( Input, Output, para, Forcept_output, Thresh, marker); 
    %test=Output.BW_fit.BW_2arms;
    %test1=double(test);
    %test2=imgaussfilt(test1,2);
    %test3=im2bw(test2,0.8);

    part2 = repmat(Output.BW_fit.BW_2arms | edge(para.centerlineAC),[1 1 3]);%Output.BW_fit.BW_2arms
    %part2 = Output.BW_fit.BW_2arms | edge(para.centerlineAC);
    image = [ Output.Col , part2; ]; 
    writeVideo(writerVideo, image);

%     part2 = im2double(repmat(shadow,[1 1 3]));
%     image = [ Output.Col , part2; ]; 
%     writeVideo(writerVideo, image);
      
    para.model = Output.model;
end
close(writerVideo);
% fclose(para.fileID);
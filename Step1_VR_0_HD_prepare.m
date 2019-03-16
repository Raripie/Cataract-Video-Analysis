%This is revised based on praogrms **svm_0401, **svm_0407, **svm_0426 et al.
%Load video data in need

%% Step 1. Load & Save Video Data
% Read a video
% Choice 1:
% Col_ori_v = loadVideoColor('/Users/Xue/Documents/Cataract/raw materials/HD video/NewHighDefCapsulorhexis_received113014/CapsulorrhexisReceived113014case1.mov');
% save ('Col_HD_ori.mat', 'Col_ori_v');
% clear Col_ori_v;
% 
% Gray_ori_v = loadVideo('/Users/Xue/Documents/Cataract/raw materials/HD video/NewHighDefCapsulorhexis_received113014/CapsulorrhexisReceived113014case1.mov');
% save ('Gray_HD.mat', 'Gray_ori_v');
% clear Gray_ori_v;
% 
% % Choice 2: there is other choices if the processor is robust enough
% [ Col_ori_v, Gray_ori_v ] = loadHDVideo('/Users/Xue/Documents/Cataract/raw materials/HD video/NewHighDefCapsulorhexis_received113014/CapsulorrhexisReceived113014case1.mov');
% save ('Col_HD.mat', 'Col_ori_v');
% save ('Gray_HD.mat', 'Gray_ori_v');
% clear Col_ori_v; clear Gray_ori_v;

Col_ori_v = loadVideoColor('VID001A[P].mp4');
save ('Col_HD_ori.mat', 'Col_ori_v');
clear Col_ori_v.mat;

Gray_ori_v = loadVideo('VID001A[P].mp4');
save ('Gray_HD.mat', 'Gray_ori_v');
clear Gray_ori_v;


%% Step 2. Resize Video Data (if necessary)
% load('Col_HD_ori.mat');
para.Height = size (Col_ori_v,1);
para.Width  = size (Col_ori_v,2);
para.nFrames = size (Col_ori_v,4);

[ Col_mov, Gray_mov, para ] = Resize_video_02222016( Col_ori_v, para );
% para.Height = size (Col_mov,1);
% para.Width  = size (Col_mov,2);
% para.nFrames = size (Col_mov,4);

% save ('Col_HD.mat', 'Col_mov');
% save ('Gray_HD.mat', 'Gray_mov');

% clear Col_ori_v;

% rect = [540 1 819 para.Width-1];
% for i = 1 : para.nFrames
%     frame = Col_ori_v(:,:,:,i);
%     frameCropped = imcrop (frame, rect);
%     Col_mov (:,:,:,i) = frameCropped;
%     
%     img = double(frameCropped)/255;
%     img = rgb2gray(img);
%     Gray_mov(:,:,i) = img;
% 
% end

%% Step 3. Select a template
% % Select a template
% % choice 1:
% template.x=160+1; template.y=100+1; template.w=320; template.h=370; 
% % choice 2:
% template.x=135+1; template.y=80+1; template.w=400; template.h=400; 
% % choice 3:
% template.x=208+1; template.y=147+1; template.w=260; template.h=260; 
% % choice 4:
% template.x=159+1; template.y=142+1; template.w=331; template.h=288; 
%%%% template.x=165+1; template.y=150+1; template.w=324; template.h=256; 

% for the case 1
% % choice 1:
% template.x=112+1; template.y=110+1; template.w=262; template.h=223; 
% % choice 2:


im = Col_mov(:,:,:,1);
[ X, Y ] = automaticCircularDetection( im );
template.x = min(X);
template.y = min(Y);
template.w = max(X) - min(X) + 1; 
template.h = max(Y) - min(Y) + 1; 

% template.x=112+1; template.y=110+1; template.w=262; template.h=276; 

image = Gray_mov (:, :, 1);
template.img = image (template.y : template.y+template.h - 1, template.x : template.x + template.w - 1); 
imwrite (template.img, 'template1.tiff');
% clear image

TEMPLATE = zeros (size(template.img, 1), size(template.img, 2), para.nFrames);
x_ref = template.x;
y_ref = template.y;

%%  Step 4. Initialize variables
xoffset = 0;
yoffset = 0;

x_old = x_ref;
y_old = y_ref;
x_shift = zeros(para.nFrames, 1);
y_shift = zeros(para.nFrames, 1);
xpeak = zeros(para.nFrames, 1);
ypeak = zeros(para.nFrames,1);
xpeak(1) = x_ref;
ypeak(1) = y_ref;

xpeak_ada = zeros(para.nFrames, 1);
ypeak_ada = zeros(para.nFrames, 1);
xpeak_ada(1) = x_ref;
ypeak_ada(1) = y_ref;

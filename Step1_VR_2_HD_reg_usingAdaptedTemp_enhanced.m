 % This file is the same as "HD_reg_usingAdaptedTemp_0827.m".
% It works well, following the same logic as "HD_reg_usingAdaptedTemp.m".

adatemp = template.img;
TEMPLATE(:,:,1) = adatemp;

for i=2 : para.nFrames
    
    %%% block starts for using adaptive adatemp    
    rect = [xpeak(i)-1 ypeak(i)-1 size(template.img,2)-1  size(template.img,1)-1];
    % The following line is the original version, but it can generate
    % bugs..
    % rect = [xpeak(i) ypeak(i) size(adatemp,2)-1  size(adatemp,1)-1];
    adatemp = imcrop(Gray_mov(:,:,i) , rect);
       
    TEMPLATE(:,:,i) = adatemp;
      
end

% clear writerObj;
% writerObj = VideoWriter('unMedian_Template');
% open(writerObj);
% 
% for i=1:para.nFrames  
%     img = TEMPLATE (:,:,i);
%     writeVideo(writerObj,img);     
% end
% close(writerObj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

win_h = 1;
win_w = 1;
win_p = 31;

TEMPLATE_update = medfilt3(TEMPLATE,[win_h win_w win_p]);

clear writerObj;
writerObj = VideoWriter('Median_Template');
open(writerObj);

for i=1:para.nFrames  
    img = TEMPLATE_update (:,:,i);
    writeVideo(writerObj,img);     
end
close(writerObj);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% re-define some variables
x_left_up_cor = zeros(para.nFrames,1);
y_left_up_cor = zeros(para.nFrames,1);

x_left_up_cor(1) = x_ref;
y_left_up_cor(1) = y_ref;

x_old = x_ref;
y_old = y_ref;

for i=2 : para.nFrames
    i
    %%% block starts for using adaptive adatemp    
    cc_precise = normxcorr2(TEMPLATE_update(:,:,i - 1), Gray_mov(:,:,i));
    c_precise = cc_precise( size(adatemp,1):end, size(adatemp,2):end);
    
    [ y_left_up_cor(i), x_left_up_cor(i) ] = peakDetection(c_precise, x_old, y_old);
    
    if abs(y_left_up_cor(i)-ypeak(i))+abs(x_left_up_cor(i)-xpeak(i)) >=100
        y_left_up_cor(i)=ypeak(i);
        x_left_up_cor(i)=xpeak(i);
    end
   
    x_old = x_left_up_cor (i);
    y_old = y_left_up_cor (i);     

end
x_sf = x_ref - x_left_up_cor ;
y_sf = y_ref - y_left_up_cor ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear writerObj;
writerObj = VideoWriter('HD_reg_usingAdaptedTemplate_color_halfWidth_halfHeight');
open(writerObj);
writeVideo(writerObj,Col_mov(:,:,:,1)); 

for i=2:para.nFrames
   
    img = Col_mov (:,:,:,i);
    xform = [1 0 0
             0 1 0
             x_sf(i) y_sf(i) 1]; 
       
    tform_translate = maketform('affine',xform);%affine2d(xform);
    img2 = imtransform(img, tform_translate, ...
               'XData', [1 size(img,2)],...
               'YData', [1 size(img,1)],...
               'FillValues', 0);  
    %img2=imwarp(img,tform_translate,'FillValues',0);
    writeVideo(writerObj,img2); 
    
end
close(writerObj);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % This part is added to realize the template matching without median
% % filter.
% % re-define some variables
% x_left_up_cor = zeros(para.nFrames,1);
% y_left_up_cor = zeros(para.nFrames,1);
% 
% x_left_up_cor(1) = x_ref;
% y_left_up_cor(1) = y_ref;
% 
% x_old = x_ref;
% y_old = y_ref;
% 
% for i=2 : para.nFrames
%     
%     %%% block starts for using adaptive adatemp    
%     cc_precise = normxcorr2(TEMPLATE(:,:,i-1), Gray_mov(:,:,i));
%     c_precise = cc_precise( size(adatemp,1):end, size(adatemp,2):end);
%     
%     [ y_left_up_cor(i), x_left_up_cor(i) ] = peakDetection(c_precise, x_old, y_old);
%    
%     x_old = x_left_up_cor (i);
%     y_old = y_left_up_cor (i);     
% 
% end
% x_sf = x_ref - x_left_up_cor ;
% y_sf = y_ref - y_left_up_cor ;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% clear writerObj;
% writerObj = VideoWriter('HD_reg_usingAdaptedTemplate_temp4_color_SameAsCCR903_noMedian');
% open(writerObj);
% writeVideo(writerObj,Col_mov(:,:,:,1)); 
% 
% for i=2:para.nFrames
%    
%     img = Col_mov (:,:,:,i);
%     xform = [1 0 0
%              0 1 0
%              x_sf(i) y_sf(i) 1]; 
%        
%     tform_translate = maketform('affine',xform);   
%     img2 = imtransform(img, tform_translate, ...
%                'XData', [1 size(img,2)],...
%                'YData', [1 size(img,1)],...
%                'FillValues', 0);
%     writeVideo(writerObj,img2); 
%     
% end
% close(writerObj);

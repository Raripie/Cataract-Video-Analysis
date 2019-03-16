 
temp = template.img;
x_old = x_ref;
y_old = y_ref;

fileID = fopen('Step1_VR1_disp_shift_xy_fexedTemp1.txt','w');
for i=2 : para.nFrames 
    
    cc = normxcorr2(temp(:,:), Gray_mov(:,:,i));
    c = cc( size(temp,1):end, size(temp,2):end); 
    % figure, surf(c), shading flat
 
    [ ypeak(i), xpeak(i) ] = peakDetection(c, x_old, y_old);
     
    if abs(ypeak(i)-y_old)+abs(xpeak(i)-x_old) >=15 && i<=1900
        ypeak(i)=y_old;
        xpeak(i)=x_old;
    end
    
    x_shift(i) = x_ref - xpeak(i);
    y_shift(i) = y_ref - ypeak(i); 
    
    x_old = xpeak (i);
    y_old = ypeak (i); 
    
    
        
    fprintf(fileID,'%d\t  %d\t  %d\n', i, x_shift(i), y_shift(i));

end
fclose(fileID);

 clear writerObj;
 writerObj = VideoWriter('HD_reg_usingFixedTemplate_color_full');
 open(writerObj);
 writeVideo(writerObj,Col_mov(:,:,:,1)); 
 
 for i=2:para.nFrames
    
     img = Col_mov(:,:,:,i) ;
     xform = [1 0 0
              0 1 0
              x_shift(i) y_shift(i) 1]; 
        
     tform_translate = maketform('affine',xform);   
     img2 = imtransform(img, tform_translate, ...
                'XData', [1 size(img,2)],...
                'YData', [1 size(img,1)],...
                'FillValues', 0);
     writeVideo(writerObj,img2); 
     
 end
 close(writerObj);


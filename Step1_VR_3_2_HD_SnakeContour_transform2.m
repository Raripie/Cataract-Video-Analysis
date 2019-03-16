% 2.2 Snake contour: 1/0
%  03/02/2016

% load('Result/XY_coor_Fig1.mat'); %% load X, Y
tic
Col_mov_RV  = loadVideoColor ('N5_700_C.avi');
para.Height = size (Col_mov_RV,1);
para.Width  = size (Col_mov_RV,2);
para.nFrames = size (Col_mov_RV,4);
para.Color_denoise = Col_mov_RV;
para.Snk_bound = zeros(size(Col_mov_RV, 1), size(Col_mov_RV, 2), size(Col_mov_RV, 4));
para.SnkArea = zeros(size(Col_mov_RV, 1), size(Col_mov_RV, 2), size(Col_mov_RV, 4));
para.SE = strel('square', 2); 


im = para.Color_denoise(:,:,:,1);
[ X, Y ] = automaticCircularDetection( im );% need to change the
%coefficient at line 41/42 from 1.1 to 0.85
clear im;
toc
clear writerVideo_c;
writerVideo_c = VideoWriter('N5_700_C_snake');
open(writerVideo_c);
for i = 1:para.nFrames

    Img = para.Color_denoise (:,:,:,i); %% OR --> Img = Col_mov_RV (:,:,:,i);
    hsv_image = rgb2hsv(Img) ;
    I = hsv_image (:,:,3); %% CCChd_79 uses gray channel 
    %I=Img(:,:,3);
    I = I*255;
    
    [ im_dot, xx, yy ] = run_snk( I, X, Y );
    im_dot=im_dot/255;
    
    n=0;
    for j=1:length(xx)
        n=n+1;
        xy_coor(:,n) = [xx(j) ; yy(j)];
    end
    
    t = 1:n;
    ts = 1: 0.1: n;
    xyc = spline(t,xy_coor,ts);
    xc = floor(xyc(1,:));
    yc = floor(xyc(2,:));

%     for j=1:length(xc)
%         para.snk_bound (yc(j), xc(j),i) = 1;
%     end
       
    C = double(Img);
    for j=1:length(xc)
        C(yc(j), xc(j), 1) = 0;
        C(yc(j), xc(j), 2) = 255; % this part is revised to show green contour
        C(yc(j), xc(j), 3) = 0;
        para.Snk_bound (yc(j), xc(j),i) = 1;
    end
    C = C/255;
    writeVideo(writerVideo_c,C);
    % figure, imshow(double(C));
    
    %%% following lines added on 12/29/2014
    thickenBound = imdilate(para.Snk_bound(:,:,i), para.SE);
    para.SnkArea(:,:,i) = round(imfill(thickenBound, 'holes'));
    
    if mod(i,10)==0
        disp([num2str(i),'/',num2str(para.nFrames),' ',num2str(toc)]);
    end
end
save('N5_700_C_snake.mat','para');
close(writerVideo_c);
toc
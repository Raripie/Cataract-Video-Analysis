function [ Col_mov, Gray_mov, para ] = Resize_video( Col_ori_v, para )
% This function is used to clip video into new size

Col_mov = zeros (para.Height/2, 720, 3, para.nFrames);
Gray_mov = zeros (para.Height/2, 720, para.nFrames);

a=100; 
for num = 1: para.nFrames
    
    Im = im2double( Col_ori_v (:,:,:,num)); 
    Im_resize = imresize(Im, 0.5,'bicubic');
    
    % K = Im_resize(:, (a+1):(a+720), :); % figure, imshow(K)
    Im_resize = Im_normalize ( Im_resize );
    Col_mov (:,:,:,num) = Im_resize(:, (a+1):(a+720), :);
    
    img = Im_resize(:, (a+1):(a+720), :);
    img = rgb2gray(img);
    Gray_mov(:,:,num) = img;
    
end

para.Height = size (Col_mov,1);
para.Width  = size (Col_mov,2);
para.nFrames = size (Col_mov,4);

% save ('Col_HD.mat', 'Col_mov');
% save ('Gray_HD.mat', 'Gray_mov');

end


function [ Im_out ] = Im_normalize ( Im_in )

minN = min(min(min(Im_in)));
maxN = max(max(max(Im_in)));
diff = abs (maxN - minN);

Im_out = ( Im_in - minN ) / diff ;

end

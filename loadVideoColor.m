function [ mov ] = loadVideoColor( FIP )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%   Created on 11/12 to load the video data  
%   which has multi-dimension. The output data
%   is gray-level video data array.

%%% this is a revised version by adding/deleting line 27

clear xyloObj;
clear mov;

xyloObj = VideoReader(FIP);
vidHeight = xyloObj.Height;
vidWidth = xyloObj.Width;
nFrames = xyloObj.NumberOfFrames;%1535;%1760;
%%% nFrames = xyloObj.NumberOfFrames;

mov = zeros(vidHeight, vidWidth, 3, nFrames, 'uint8');

for k = 1  : nFrames
%     img = double(read(xyloObj, k));
%     img=img/255;
%     img = rgb2gray(img);
%     mov(:,:,k) = img;
       
    img = double(read(xyloObj, k));%k+224
    %img = img/255;  %% added by Xue on 02/03/2014 
    mov(:,:,:,k) = img;
end

end


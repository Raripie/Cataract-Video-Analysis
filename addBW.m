function [ BW_4fit ] = addBW( BW_in )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
BW = BW_in;
BW (260:371, :) = zeros();
%BW (260:360, 380:455) = zeros();
conn = 4;

CC = bwconncomp(BW, conn);
S = regionprops(CC, 'Area');
L = labelmatrix(CC);
BW_4fit.full = ismember(L, find([S.Area] >= max([S.Area])));
BW_4fit.skel = bwmorph(BW_4fit.full,'skel',Inf);
BW_4fit.thin = bwmorph(BW_4fit.full,'thin',Inf);
end


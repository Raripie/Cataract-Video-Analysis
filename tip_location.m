function [tiplocate,armlocate,pcaline]=tip_location(centerline,tip_find_image,SnkArea)
sat=tip_find_image;
Hight=size(SnkArea,1);
Width=size(SnkArea,2);
ROI=zeros(Hight,Width);
for i=1:size(centerline,1)
    if SnkArea(centerline(i,1),centerline(i,2))==1
        ROI(centerline(i,1),centerline(i,2))=1;
    end
end
[idxROI.row, idxROI.col] = find(ROI == 1) ;

X=[idxROI.row,idxROI.col];
Y=zeros(length(idxROI.row),2);
[Y(:,1),I]=sort(X(:,1),'descend');
for i=1:length(idxROI.row)
    Y(i,2)=X(I(i),2);
end

idxROI.row=Y(:,1);
idxROI.col=Y(:,2);
for k = 1:length(idxROI.row)
    cenData.Sat (k) = sat (idxROI.row(k),idxROI.col(k));
end

medRatio.avg = cenData.Sat; 
medRatio.avg=double(medRatio.avg);
level = graythresh(medRatio.avg);
BW_s = im2bw(medRatio.avg,level);  

if isempty(BW_s)
    tiplocate.col=idxROI.col(1);
    tiplocate.row=idxROI.row(1);
    armlocate.col=[];
    armlocate.row=[];
    pcaline.col=[];
    pcaline.row=[];
else
    s1=find(BW_s==0);
    s2=find(BW_s==1);
    if s2(1)==1
        tiplocate.col=idxROI.col(s2(end));
        tiplocate.row=idxROI.row(s2(end));
        armlocate.col=idxROI.col(1:s2(end));
        armlocate.row=idxROI.row(1:s2(end));
        pcaline.col=idxROI.col(1:end);
        pcaline.row=idxROI.row(1:end);
    elseif s1(1)==1
        tiplocate.col=idxROI.col(s2(end));
        tiplocate.row=idxROI.row(s2(end));
        armlocate.col=idxROI.col(1:s2(end));
        armlocate.row=idxROI.row(1:s2(end));
        pcaline.col=idxROI.col(1:end);
        pcaline.row=idxROI.row(1:end);
    end
end

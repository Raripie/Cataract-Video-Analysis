raw_frame=loadVideoColor('N2_600_F_S2.avi');
raw_image=loadVideoColor('N2_600_F.avi');

%SnkArea=para.SnkArea(:,:,1);
%SnkArea=bwmorph(SnkArea,'dilate',10);
nframes=size(raw_frame,4);
para.nframes=nframes;

%raw_image=raw_frame(:,1:600,:,:);
%raw_label=raw_frame(:,601:1200,:,:);  %two raw_label; one with less info, one with more info. First one finds centerline, second one finds tip.
Hight=size(raw_image,1);
Width=size(raw_image,2);

info.arm_left=zeros(Hight,2,nframes);
info.arm_right=zeros(Hight,2,nframes);
info.pca_left=zeros(Hight,2,nframes);
info.pca_right=zeros(Hight,2,nframes);
info.Tip_Location=zeros(nframes,5);

for i=1:nframes
    label=raw_frame(:,601:1200,:,i);
    %label(1:350,:,:)=0;
    image=im2bw(label);
    image1=bwareaopen(image,250,8);
    [L,num]=bwlabel(image1,8);
    Label(:,:,i)=L;
    Class(i,1)=num;
end

aviobj=VideoWriter('N2_F_label_video');
aviobj.FrameRate=30;
open(aviobj);
for i=1:nframes
    image1=Label(:,:,i);        
    writeVideo(aviobj,image1/4);
end
close(aviobj);

for i=1:nframes
    image=Label(:,:,i);
    tip_find_image=im2bw(raw_frame(:,601:1200,:,i));
    if Class(i)==1
        
        value=1;
        [centerline,slope,b]=centerline_fit(image,value,Hight,Width);
        
        [tiplocate,armlocate,pcaline]=tip_location(centerline,tip_find_image,SnkArea);
        
        for j=1:size(centerline,1)
            raw_image(centerline(j,1),centerline(j,2),:,i)=255;
        end
        raw_image(tiplocate.row-9:tiplocate.row+9,tiplocate.col-9:tiplocate.col+5,1,i)=0;
        raw_image(tiplocate.row-9:tiplocate.row+9,tiplocate.col-9:tiplocate.col+5,2,i)=0;
        raw_image(tiplocate.row-9:tiplocate.row+9,tiplocate.col-9:tiplocate.col+5,3,i)=255;
        
        
        %record tip location info
        info.Tip_Location(i,1)=1;
        info.Tip_Location(i,2)=tiplocate.row;
        info.Tip_Location(i,3)=tiplocate.col;
        info.arm_left(1:length(armlocate.row),:,i)=[armlocate.row armlocate.col];
        info.arm_right(1:length(armlocate.row),:,i)=[armlocate.row armlocate.col];
        info.pca_left(1:length(pcaline.row),:,i)=[pcaline.row pcaline.col];
        info.pca_right(1:length(pcaline.row),:,i)=[pcaline.row pcaline.col];
        
        
    elseif Class(i)>=2
        
        value=1;
        [centerline1,slope1,b1]=centerline_fit(image,value,Hight,Width);
        
        value=2;
        [centerline2,slope2,b2]=centerline_fit(image,value,Hight,Width);
        
              
        [tiplocate1,armlocate1,pcaline1]=tip_location(centerline1,tip_find_image,SnkArea);
        
        for j=1:size(centerline1,1)
            raw_image(centerline1(j,1),centerline1(j,2),:,i)=255;
        end
        raw_image(tiplocate1.row-9:tiplocate1.row+9,tiplocate1.col-9:tiplocate1.col+9,1,i)=0;
        raw_image(tiplocate1.row-9:tiplocate1.row+9,tiplocate1.col-9:tiplocate1.col+9,2,i)=0;
        raw_image(tiplocate1.row-9:tiplocate1.row+9,tiplocate1.col-9:tiplocate1.col+9,3,i)=255;
        
        [tiplocate2,armlocate2,pcaline2]=tip_location(centerline2,tip_find_image,SnkArea);
        
        for j=1:size(centerline2,1)
            raw_image(centerline2(j,1),centerline2(j,2),:,i)=255;
        end
        raw_image(tiplocate2.row-9:tiplocate2.row+9,tiplocate2.col-9:tiplocate2.col+9,1,i)=0;
        raw_image(tiplocate2.row-9:tiplocate2.row+9,tiplocate2.col-9:tiplocate2.col+9,2,i)=0;
        raw_image(tiplocate2.row-9:tiplocate2.row+9,tiplocate2.col-9:tiplocate2.col+9,3,i)=255;
        
        
        % record tip location info
        A=[tiplocate1.row,tiplocate1.col;tiplocate2.row,tiplocate2.col];
        [y1,u1]=min(A(:,2));
        [y2,u2]=max(A(:,2));
        info.Tip_Location(i,1)=2;
        info.Tip_Location(i,2)=A(u1,1);
        info.Tip_Location(i,3)=A(u1,2);
        info.Tip_Location(i,4)=A(u2,1);
        info.Tip_Location(i,5)=A(u2,2);
        if info.Tip_Location(i,3)==armlocate1.col(end)
            info.arm_left(1:length(armlocate1.row),:,i)=[armlocate1.row armlocate1.col];
            info.arm_right(1:length(armlocate2.row),:,i)=[armlocate2.row armlocate2.col];
            info.pca_left(1:length(pcaline1.row),:,i)=[pcaline1.row pcaline1.col];
            info.pca_right(1:length(pcaline2.row),:,i)=[pcaline2.row pcaline2.col];
        elseif info.Tip_Location(i,3)==armlocate2.col(end)
            info.arm_left(1:length(armlocate2.row),:,i)=[armlocate2.row armlocate2.col];
            info.arm_right(1:length(armlocate1.row),:,i)=[armlocate1.row armlocate1.col];
            info.pca_left(1:length(pcaline2.row),:,i)=[pcaline2.row pcaline2.col];
            info.pca_right(1:length(pcaline1.row),:,i)=[pcaline1.row pcaline1.col];
        end
        
        
    end
end

 aviobj=VideoWriter('N2_F_final1_video');
 aviobj.FrameRate=30;
 open(aviobj);
 for i=1:nframes
     image1=[raw_image(:,:,:,i)];        
     writeVideo(aviobj,image1);
 end
 close(aviobj);
        
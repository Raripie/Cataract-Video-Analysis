% load info.mat
raw_image=loadVideoColor('N5_600_F.avi');

arm_left=info_N5_F.arm_left;
arm_right=info_N5_F.arm_right;
pca_left=info_N5_F.pca_left;
pca_right=info_N5_F.pca_right;
tip_location=info_N5_F.Tip_Location;

n=size(arm_left,3);
l_left=zeros(n,1);
l_right=zeros(n,1);

l_left_modify=zeros(n,1);
l_right_modify=zeros(n,1);

for i=1:n
    if tip_location(i,1)==1
        tip_location(i,4)=tip_location(i,2);
        tip_location(i,5)=tip_location(i,3);
    end
end

for i=1:n
    left=arm_left(:,:,i);
    right=arm_right(:,:,i);
%     if ~isempty(find(left(:,1)))
%         X=find(left(:,1));
%         Y=find(right(:,1));
%         l_left(i)=sqrt((left(1,1)-left(X(end),1))^2+(left(1,2)-left(X(end),2))^2);
%         l_right(i)=sqrt((right(1,1)-right(Y(end),1))^2+(right(1,2)-right(Y(end),2))^2);
%     end
    l_left(i)=length(find(left(:,1)));
    l_right(i)=length(find(right(:,1)));
end

correct_left=ones(n,1);
correct_right=ones(n,1);
[correct1,correct2]=correction(correct_left,correct_right);


for i=2:n
    if abs(l_left(i)-l_left(i-1))<40
        correct_left(i)=correct_left(i-1);
    elseif abs(l_left(i)-l_left(i-1))>=40 && l_left(i)>90 && l_left(i-1)>90
        correct_left(i)=abs(correct_left(i-1)-1);
    end
end

for i=2:n
    if abs(l_right(i)-l_right(i-1))<40
        correct_right(i)=correct_right(i-1);
    elseif abs(l_right(i)-l_right(i-1))>=40 && l_right(i)>90 && l_right(i-1)>90
        correct_right(i)=abs(correct_right(i-1)-1);
    end
end

%correct1=correct_left;
%correct2=correct_right;

tip_left=zeros(n,2);
tip_right=zeros(n,2);

for i=1:n
    if correct1(i)==1
        tip_left(i,1)=tip_location(i,2);
        tip_left(i,2)=tip_location(i,3);
        l_left(i,1)=l_left(i,1);
        
    elseif correct1(i)==0
        s1=find(correct1(1:i-1,1));
        s2=find(correct1(i+1:n,1));
        l1=l_left(s1(end));
        l2=l_left(i+s2(1));
        correct1(i)=1;
        l=l1-(l1-l2)/(i+s2(1)-s1(end)+1);
        l_left(i)=round(l);
        tip_left(i,1)=pca_left(l_left(i),1,i);
        tip_left(i,2)=pca_left(l_left(i),2,i);
    end
end



for i=1:n
    if correct2(i)==1
        tip_right(i,1)=tip_location(i,4);
        tip_right(i,2)=tip_location(i,5);
        l_right(i,1)=l_right(i,1);
        
    elseif correct2(i)==0
        s1=find(correct2(1:i-1,1));
        s2=find(correct2(i+1:n,1));
        l1=l_right(s1(end));
        l2=l_right(i+s2(1));
        correct2(i)=1;
        l=l1-(l1-l2)/(i+s2(1)-s1(end)+1);
        l_right(i)=round(l);
        tip_right(i,1)=pca_right(l_right(i),1,i);
        tip_right(i,2)=pca_right(l_right(i),2,i);
    end
end

tip_left=uint32(tip_left);
tip_right=uint32(tip_right);

for i=1:n
    if tip_location(i,1)==2
        raw_image(tip_left(i,1)-9:tip_left(i,1)+9,tip_left(i,2)-9:tip_left(i,2)+9,1,i)=0;
        raw_image(tip_left(i,1)-9:tip_left(i,1)+9,tip_left(i,2)-9:tip_left(i,2)+9,2,i)=255;
        raw_image(tip_left(i,1)-9:tip_left(i,1)+9,tip_left(i,2)-9:tip_left(i,2)+9,3,i)=0;
        raw_image(tip_right(i,1)-9:tip_right(i,1)+9,tip_right(i,2)-9:tip_right(i,2)+9,1,i)=0;
        raw_image(tip_right(i,1)-9:tip_right(i,1)+9,tip_right(i,2)-9:tip_right(i,2)+9,2,i)=255;
        raw_image(tip_right(i,1)-9:tip_right(i,1)+9,tip_right(i,2)-9:tip_right(i,2)+9,3,i)=0;
    end
    if tip_location(i,1)==1
        tip_row=(tip_left(i,1)+tip_right(i,1))/2;
        tip_col=(tip_left(i,2)+tip_right(i,2))/2;
        tip_row=round(tip_row);
        tip_col=round(tip_col);
        tip_row=uint32(tip_row);
        tip_col=uint32(tip_col);
        tip_left(i,1)=tip_row;
        tip_left(i,2)=tip_col;
        tip_right(i,1)=tip_row;
        tip_right(i,2)=tip_col;
        raw_image(tip_row-9:tip_row+9,tip_col-9:tip_col+9,1,i)=0;
        raw_image(tip_row-9:tip_row+9,tip_col-9:tip_col+9,2,i)=255;
        raw_image(tip_row-9:tip_row+9,tip_col-9:tip_col+9,3,i)=0;
    end
end


aviobj=VideoWriter('N5_F_final_video_tipmodify');
 aviobj.FrameRate=30;
 open(aviobj);
 for i=1:n
     image1=[raw_image(:,:,:,i)];        
     writeVideo(aviobj,image1);
 end
 close(aviobj);


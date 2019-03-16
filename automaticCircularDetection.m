function [ X, Y ] = automaticCircularDetection( im )

hsvImg = rgb2hsv(im);
H = hsvImg(:,:,1);
S = hsvImg(:,:,2);
V = hsvImg(:,:,3);
% gray = rgb2gray(im);
%% S
biFilt = bilateralFilter(double(V));
out = medfilt2(biFilt,[11 11]);
e = edge(out, 'canny');
figure,imshow(e);

%% Carry out the HT

[r,c]=size(e);
m = min(r,c);

%radii = round(m*0.25):2:round(m*0.4);%expert3
radii = round(m*0.15):2:round(m*0.25);%novice5_C
%radii = round(m*0.25):2:round(m*0.35);
%radii = round(m*0.34):2:round(m*0.36);% expert4
h = circle_hough(e, radii, 'same', 'normalise');


%% Find some peaks in the accumulator
%  We select the most prominent peaks.

peaks = circle_houghpeaks(h, radii, 'nhoodxy', 15, 'nhoodr', 21, 'npeaks', 1);

%% Look at the results

figure,imshow(im);
hold on;
for peak = peaks
    [x, y] = circlepoints(peak(3));
    plot(x+peak(1), y+peak(2), 'g-',...
    'LineWidth',2.7);
end

count = 1;
for i = 1 : round(length(x) / 20) : length(x)
    X(count) = round(x(i)*1.1)+peak(1);
    Y(count) = round(y(i)*1.1)+peak(2);
    plot(X(count), Y(count), 'ro', ...
    'LineWidth',2.7, ...
    'MarkerSize',10, ... 
    'MarkerEdgeColor','r',...
    'MarkerFaceColor',[1, 0, 0]);
    count = count + 1;    
end

end


%**************************************************************************
% name     :    PCA_2D
% function :    reduce 2D data to 1D in term of minimum square error
% input :       x          the column indexes of the extracted pixels
%               y          the column indexes of the extracted pixels
%               (both x and y are 1*N column vectors)
% output :      x_mean     mean of the column indexes
%               y_mean     mean of the row indexes
%               slope      slope of the projected line
%               b          intersection
% return :      none
%**************************************************************************
function [x_mean, y_mean, slope, b] = PCA_2D(x, y)

N = length(x);
x_mean = mean(x);

y_mean = mean(y);
x = x - x_mean;
y = y - y_mean;
z = [x' y'];
[U,S,V] = svds(z,1);
Evaluated_data = U*S*V';
x1 = Evaluated_data(:,1);
y1 = Evaluated_data(:,2);

%compute slope+ 
index1 = min(find(y1 == max(y1)));
index2 = min(find(y1 == min(y1)));

slope = (y1(index2)-y1(index1))/(x1(index2)-x1(index1));
%b = y_mean - slope*x_mean;
b = y_mean - slope*x_mean+y1(index1)-slope*x1(index1);

end


function [ selModel, centerline, addCenterline ] = centerlineFit_0526( centerline, para, BW, Input )
%%% remark: 3 revised parts compared to *0328
%%% remark: 1 revised parts compared to *0506: BW instead of BW_full
%%% remark: 2 revised parts compared to *0506: <= (para.Width/para.Height) v.s.  (selModel.p(1)) <= 1 
%[yData, xData] = find(centerline.lineSeg == 1) ;
if max(max(BW)) == 0  %% if max(max(centerline.line)) == 0  
    Model.p     = NaN;
    Model.yFit  = NaN;
    Model.error = NaN;
    selModel.type = 'noModel';
    centerline.curvefit = centerline.line;
    centerline.col = NaN;
    centerline.row = NaN;
else
    [yData, xData] = find(BW == 1) ;
    %yData = para.Height+1 - yData ;
    [xData, yData] = prepareCurveData( xData, yData );

    %%
    Model.p = polyfit(xData,yData,1);
    Model.xData = xData;
    Model.yData = yData;
    Model.yFit = polyval(Model.p,xData);
    Model.error = Model.yFit - yData;
    Model.error = sum(Model.error.^2); % sum(Model.error.* Model.error) ; 
    Model.type = 'normal';
    
    SStotal = (length(yData)-1) * var(yData);
    Model.rsq = 1 - Model.error/SStotal;
    %%
    InvModel.p = polyfit(yData,xData,1);
    InvModel.xData = xData;
    InvModel.yData = yData;
    InvModel.xFit = polyval(InvModel.p,yData);
    InvModel.error = InvModel.xFit - xData;
    InvModel.error = sum(InvModel.error.^2); % sum(InvModel.error.* InvModel.error) ; 
    InvModel.type = 'inverse';
    
    SStotal = (length(xData)-1) * var(xData);
    InvModel.rsq = 1 - InvModel.error/SStotal;
    %% Compare for smaller residual error
    if Model.error <= InvModel.error
        selModel = Model;
        if selModel.p(2) >= 0 % abs (selModel.p(1)) <= (para.Height/para.Width) % (selModel.p(1)) <= 1  
            index.col   = 1:para.Width;
            index.row   = round (polyval(selModel.p,index.col));%%para.Height+1 - round (polyval(Model.p,index.col));
        else
%             index.row   = 1:para.Height;
%             index.col   = round (polyval(InvModel.p,index.row));
            index.row   = 1:para.Height;
            index.col   = round((index.row - selModel.p(2))/selModel.p(1));
        end
    else
        selModel = InvModel;
        if selModel.p(2) > 0 % abs (selModel.p(1)) <= (para.Width/para.Height) % (selModel.p(1)) <= 1 
            index.row   = 1:para.Height;
            index.col   = round (polyval(selModel.p,index.row)); 
        else
            index.col   = 1:para.Width;
            index.row   = round((index.col - selModel.p(2))/selModel.p(1));
        end
    end
    
    [ index ] = Index_reinforcement( index, para ); %% 3nd revision: adding this func. to reinforce r/c

    centerline.curvefit = zeros(para.Height, para.Width); %% 2nd revision: centerline.curvefit = zeros(size(centerline.lineSeg)); 
    for i = 1:length(index.row)
        centerline.curvefit (index.row(i), index.col(i)) = 1;
    end
    
    centerline.col = index.col;
    centerline.row = index.row;
    %figure, imshow(centerline.curvefit | BW)
end
[ addCenterline ] = drawCenterLine_0324( Input, centerline );

end

% function [ index ] = Index_reinforcement( index, para ) %% 3nd revision: adding this func. to reinforce r/c
% 
%     tt = (index.col > 0) & (index.col < para.Width + 1);
%     ss = find(tt);
%     index.col = index.col(ss(1):ss(end));
%     index.row = index.row(ss(1):ss(end));
%     
%     tt = (index.row > 0) & (index.row < para.Height + 1);
%     ss = find(tt);
%     index.col = index.col(ss(1):ss(end));
%     index.row = index.row(ss(1):ss(end));
% end
 
% % function [ index ] = Index_reinforcement( index, para ) %% 3nd revision: adding this func. to reinforce r/c
% % 
% %     tt = (index.col > 0) & (index.col < para.Width + 1);
% %     index.col = index.col(tt);
% %     index.row = index.row(index.col > 0);
% %     
% %     tt = (index.row > 0) & (index.row < para.Height + 1);
% %     index.row = index.row(tt);
% %     index.col = index.col(index.row > 0);
% % end
clear
clc

is_regresion = 1;  % If not regression, use the previous results directly to draw a graph
learning_rate = 0.12;
dataset_queality = 1.5;
epoch_num = 200;   % How many eopchs are returned in total
momentum = 1 - power(0.05, 1 / (171500));
if is_regresion==1
    fprintf('Processing regresion_process.m ...\n');
    F_i=fopen('E:\matlab_project\simulation experiments\results\iou-1715k.txt','w');
    F_g=fopen('E:\matlab_project\simulation experiments\results\giou-1715k.txt','w');
    F_fg=fopen('E:\matlab_project\simulation experiments\results\focal_giou-1715k.txt','w');
    F_w2g=fopen('E:\matlab_project\simulation experiments\results\wiouv2_giou-1715k.txt','w');
    F_a2g=fopen('E:\matlab_project\simulation experiments\results\aiouv2_giou-1715k.txt','w');
    F_w3g=fopen('E:\matlab_project\simulation experiments\results\wiouv3_giou-1715k.txt','w');
    F_a3g=fopen('E:\matlab_project\simulation experiments\results\aiouv3_giou-1715k.txt','w');
    F_pg=fopen('E:\matlab_project\simulation experiments\results\per_giou-1715k.txt','w');

    % Write the losses during the training process in Excel, first write the header
    excle_iou = 'E:\matlab_project\simulation experiments\results\iou-1715k.xls';
    count=zeros(epoch_num,1,'int32');
    for id=1:epoch_num
        count(id)=id;
    end
    xlswrite(excle_iou,{'name','iou','giou','focal_loss_giou','wiou_v2_giou','aiou_v2_giou','wiou_v3_giou','Aiou_v3_giou','per_giou'},'sheet1','A1:I1');
    xlswrite(excle_iou,count,'sheet1','A2:A201');
    
    i_x=zeros(epoch_num,1,'double');i_y=zeros(epoch_num,1,'double');i_w=zeros(epoch_num,1,'double');i_h=zeros(epoch_num,1,'double');
    g_x=zeros(epoch_num,1,'double');g_y=zeros(epoch_num,1,'double');g_w=zeros(epoch_num,1,'double');g_h=zeros(epoch_num,1,'double');
    fg_x=zeros(epoch_num,1,'double');fg_y=zeros(epoch_num,1,'double');fg_w=zeros(epoch_num,1,'double');fg_h=zeros(epoch_num,1,'double');
    w2g_x=zeros(epoch_num,1,'double');w2g_y=zeros(epoch_num,1,'double');w2g_w=zeros(epoch_num,1,'double');w2g_h=zeros(epoch_num,1,'double');
    a2g_x=zeros(epoch_num,1,'double');a2g_y=zeros(epoch_num,1,'double');a2g_w=zeros(epoch_num,1,'double');a2g_h=zeros(epoch_num,1,'double');
    w3g_x=zeros(epoch_num,1,'double');w3g_y=zeros(epoch_num,1,'double');w3g_w=zeros(epoch_num,1,'double');w3g_h=zeros(epoch_num,1,'double');
    a3g_x=zeros(epoch_num,1,'double');a3g_y=zeros(epoch_num,1,'double');a3g_w=zeros(epoch_num,1,'double');a3g_h=zeros(epoch_num,1,'double');
    pg_x=zeros(epoch_num,1,'double');pg_y=zeros(epoch_num,1,'double');pg_w=zeros(epoch_num,1,'double');pg_h=zeros(epoch_num,1,'double');

    position_x=zeros(1715000,1,'double');
    position_y=zeros(1715000,1,'double');
    position_w=zeros(1715000,1,'double');
    position_h=zeros(1715000,1,'double');

    IoU_Loss=zeros(1715000,1,'double');
    GIoU_Loss=zeros(1715000,1,'double');
    Focal_GIoU_Loss=zeros(1715000,1,'double');
    Wiouv2_Loss=zeros(1715000,1,'double');
    Aiouv2_Loss=zeros(1715000,1,'double');
    Wiouv3_Loss=zeros(1715000,1,'double');
    Aiouv3_Loss=zeros(1715000,1,'double');
    Per_Loss=zeros(1715000,1,'double');

    final_error_iou=zeros(1715000,1,'double');
    final_error_giou=zeros(1715000,1,'double');
    final_error_focal_giou=zeros(1715000,1,'double');
    final_error_wiouv2_giou=zeros(1715000,1,'double');
    final_error_aiouv2_giou=zeros(1715000,1,'double');
    final_error_wiouv3_giou=zeros(1715000,1,'double');
    final_error_aiouv3_giou=zeros(1715000,1,'double');
    final_error_per_giou=zeros(1715000,1,'double');
    
    iou0=zeros(1715000,1,'double');
    giou0=zeros(1715000,1,'double');
    focal_giou0=zeros(1715000,1,'double');
    wiouv2_giou0=zeros(1715000,1,'double');
    aiouv2_giou0=zeros(1715000,1,'double');
    wiouv3_giou0=zeros(1715000,1,'double');
    aiouv3_giou0=zeros(1715000,1,'double');
    per_giou0=zeros(1715000,1,'double');
    
    % ---------------------------- get target boxes and anchor boxes -------------------------- %
    rr=3*sqrt(rand(1,5000));
    seta=2*pi*rand(1,5000);
    xx=10+rr.*cos(seta);
    yy=10+rr.*sin(seta);
    c1=sqrt(3);
    c2=sqrt(2);
    gt = zeros(7,4,'double');
    pred = zeros(1715000,4,'double');
    % 生成7个 targets
    for c=1:7
        if c==1
            gt_w=0.5;
            gt_h=2.0;
        end
        if c==2
            gt_w=c1/3;
            gt_h=c1;
        end
        if c==3
            gt_w=c2/2;
            gt_h=c2;
        end
        if c==4
            gt_w=1;
            gt_h=1;
        end
        if c==5
            gt_w=c2;
            gt_h=c2/2;
        end
        if c==6
            gt_w=c1;
            gt_h=c1/3;
        end
        if c==7
            gt_w=2.0;
            gt_h=0.5;
        end
        gt(c,1)=10;
        gt(c,2)=10;
        gt(c,3)=gt_w;
        gt(c,4)=gt_h;
    end
    % 生成5000*7*7*7= 1715000 个 anchors
    for i=1:5000           % 5000个点
        pred_x=xx(i);
        pred_y=yy(i);
        for c=1:7           % 7个长宽比
            if c==1
                gt_w=0.5;
                gt_h=2.0;
            end
            if c==2
                gt_w=c1/3;
                gt_h=c1;
            end
            if c==3
                gt_w=c2/2;
                gt_h=c2;
            end
            if c==4
                gt_w=1;
                gt_h=1;
            end
            if c==5
                gt_w=c2;
                gt_h=c2/2;
            end
            if c==6
                gt_w=c1;
                gt_h=c1/3;
            end
            if c==7
                gt_w=2.0;
                gt_h=0.5;
            end

            for o=1:7             % 7个面积
                if o==1
                    S=0.5*gt_w*gt_h;
                end
                if o==2
                    S=0.67*gt_w*gt_h;
                end
                if o==3
                    S=0.75*gt_w*gt_h;
                end
                if o==4
                    S=1*gt_w*gt_h;
                end
                if o==5
                    S=1.33*gt_w*gt_h;
                end
                if o==6
                    S=1.5*gt_w*gt_h;
                end
                if o==7
                    S=2.0*gt_w*gt_h;                %7 scales of anchor boxes
                end

                for l=1:7                % 7个高宽
                    if l==1
                        pred_w=0.5*sqrt(S);
                        pred_h=2.0*sqrt(S);
                    end
                    if l==2
                        pred_w=c1/3*sqrt(S);
                        pred_h=c1*sqrt(S);
                    end
                    if l==3
                        pred_w=c2/2*sqrt(S);
                        pred_h=c2*sqrt(S);
                    end
                    if l==4
                        pred_w=1.0*sqrt(S);
                        pred_h=1.0*sqrt(S);
                    end
                    if l==5
                        pred_w=c2*sqrt(S);
                        pred_h=c2/2*sqrt(S);
                    end
                    if l==6
                        pred_w=c1*sqrt(S);
                        pred_h=c1/3*sqrt(S);
                    end
                    if l==7
                        pred_w=2.0*sqrt(S);
                        pred_h=0.5*sqrt(S);
                    end
    %                 pred=[pred_x,pred_y,pred_w,pred_h];
                    count = ((i-1)*7*7*7)+((c-1)*7*7)+((o-1)*7)+l;
                    pred(count,1)=pred_x;
                    pred(count,2)=pred_y;
                    pred(count,3)=pred_w;
                    pred(count,4)=pred_h;
                end
            end
        end
    end

    % ---------------------------- end get target boxes and anchor boxes -------------------------- % 
    % GIoU
    pred_i=pred;
    pred_g=pred;
    pred_fg=pred;
    pred_w2g=pred;
    pred_a2g=pred;
    pred_w3g=pred;
    pred_a3g=pred;
    pred_pg=pred;
    
    epoch_id_iou=zeros(epoch_num,4,'double');
    epoch_id_giou=zeros(epoch_num,4,'double');
    epoch_id_focal_giou=zeros(epoch_num,4,'double');
    epoch_id_wiouv2_giou=zeros(epoch_num,4,'double');
    epoch_id_aiouv2_giou=zeros(epoch_num,4,'double');
    epoch_id_wiouv3_giou=zeros(epoch_num,4,'double');
    epoch_id_aiouv3_giou=zeros(epoch_num,4,'double');
    epoch_id_per_giou=zeros(epoch_num,4,'double');
    
    loss_i=zeros(1715000,4,'double');
    loss_g=zeros(1715000,4,'double');
    loss_fg=zeros(1715000,4,'double');
    loss_w2g=zeros(1715000,4,'double');
    loss_a2g=zeros(1715000,4,'double');
    loss_w3g=zeros(1715000,4,'double');
    loss_a3g=zeros(1715000,4,'double');
    loss_pg=zeros(1715000,4,'double');
    
    mean_iou = repmat(0.2,1);
    mean_iou_g = repmat(0.2,1);
    mean_iou_fg = repmat(0.2,1);
    mean_iou_w2g = repmat(0.2,1);
    mean_iou_a2g = repmat(0.2,1);
    mean_iou_w3g = repmat(0.2,1);
    mean_iou_a3g = repmat(0.2,1);
    mean_iou_pg = repmat(0.2,1);
    mm1=0;
    for k=1:(0.8*epoch_num)				%do bounding box regression by gradient descent algorithm
        fprintf('进度：%.2f / 200......IoU 值：IoU-%.3f; GIoU-%.3f; FGIoU-%.3f; W2IoU-%.3f; A2IoU-%.3f; W3IoU-%.3f; A3IoU-%.3f; PerIoU-%.3f \n',k,mean_iou,mean_iou_g,mean_iou_fg,mean_iou_w2g,mean_iou_a2g,mean_iou_w3g,mean_iou_a3g,mean_iou_pg);
        for points=1:5000
            for gt_count=1:7
                for anchor_count=1:49
                    idx_anchor_count = 343*(points-1)+49*(gt_count-1)+anchor_count;
                    gt_tblr=to_tblr(gt(gt_count,:));
                    
                    % ---------------------------- IoU -------------------------- % 
                    pred_i_tblr=to_tblr(pred_i(idx_anchor_count,:));
                    iou_value=iou(pred_i_tblr,gt_tblr);
                    giou_value=giou(pred_i_tblr,gt_tblr);
                    mean_iou=(1-momentum)*mean_iou + momentum*giou_value;
                    diou=dIOU(pred_i_tblr,gt_tblr);
                    diou_xywh=to_xywh(diou);
                    pred_i(idx_anchor_count,1)=pred_i(idx_anchor_count,1)+learning_rate*(1-iou_value)*diou_xywh.dx;
                    pred_i(idx_anchor_count,2)=pred_i(idx_anchor_count,2)+learning_rate*(1-iou_value)*diou_xywh.dy;
                    pred_i(idx_anchor_count,3)=pred_i(idx_anchor_count,3)+learning_rate*(1-iou_value)*diou_xywh.dw;
                    pred_i(idx_anchor_count,4)=pred_i(idx_anchor_count,4)+learning_rate*(1-iou_value)*diou_xywh.dh;
                    epoch_id_iou(k,2:5)=pred_i(idx_anchor_count);
                    loss_i(idx_anchor_count,1:4)=abs(epoch_id_iou(k,2:5)-gt(gt_count,1:4))+loss_i(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    i_x(k)=abs(pred_i(idx_anchor_count,1)-gt(gt_count,1))+i_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    i_y(k)=abs(pred_i(idx_anchor_count,2)-gt(gt_count,2))+i_y(k);
                    i_w(k)=abs(pred_i(idx_anchor_count,3)-gt(gt_count,3))+i_w(k);
                    i_h(k)=abs(pred_i(idx_anchor_count,4)-gt(gt_count,4))+i_h(k);
                    
                    % ---------------------------- GIoU -------------------------- % 
                    pred_g_tblr=to_tblr(pred_g(idx_anchor_count,:));
                    giou_value=giou(pred_g_tblr,gt_tblr);
                    mean_iou_g=(1-momentum)*mean_iou_g + momentum*giou_value;
                    dgiou_xywh=dDIOU(pred_g(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);
                    pred_g(idx_anchor_count,1)=pred_g(idx_anchor_count,1)+learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_g(idx_anchor_count,2)=pred_g(idx_anchor_count,2)+learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_g(idx_anchor_count,3)=pred_g(idx_anchor_count,3)+learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_g(idx_anchor_count,4)=pred_g(idx_anchor_count,4)+learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_giou(k,2:5)=pred_g(idx_anchor_count);
                    loss_g(idx_anchor_count,1:4)=abs(epoch_id_giou(k,2:5)-gt(gt_count,1:4))+loss_g(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    g_x(k)=abs(pred_g(idx_anchor_count,1)-gt(gt_count,1))+g_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    g_y(k)=abs(pred_g(idx_anchor_count,2)-gt(gt_count,2))+g_y(k);
                    g_w(k)=abs(pred_g(idx_anchor_count,3)-gt(gt_count,3))+g_w(k);
                    g_h(k)=abs(pred_g(idx_anchor_count,4)-gt(gt_count,4))+g_h(k);
                    
                    % ---------------------------- Focal GIoU -------------------------- % 
                    pred_fg_tblr=to_tblr(pred_fg(idx_anchor_count,:));
                    giou_value=giou(pred_fg_tblr,gt_tblr);
                    mean_iou_fg=(1-momentum)*mean_iou_fg + momentum*giou_value;  %不断更新 mean IOU
                    dgiou_xywh=dDIOU(pred_fg(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);

                    focal_loss_value = focal_loss(giou_value);
                    pred_fg(idx_anchor_count,1)=pred_fg(idx_anchor_count,1)+focal_loss_value*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_fg(idx_anchor_count,2)=pred_fg(idx_anchor_count,2)+focal_loss_value*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_fg(idx_anchor_count,3)=pred_fg(idx_anchor_count,3)+focal_loss_value*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_fg(idx_anchor_count,4)=pred_fg(idx_anchor_count,4)+focal_loss_value*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_focal_giou(k,2:5)=pred_fg(idx_anchor_count);
                    loss_fg(idx_anchor_count,1:4)=abs(epoch_id_focal_giou(k,2:5)-gt(gt_count,1:4))+loss_fg(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    fg_x(k)=abs(pred_fg(idx_anchor_count,1)-gt(gt_count,1))+fg_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    fg_y(k)=abs(pred_fg(idx_anchor_count,2)-gt(gt_count,2))+fg_y(k);
                    fg_w(k)=abs(pred_fg(idx_anchor_count,3)-gt(gt_count,3))+fg_w(k);
                    fg_h(k)=abs(pred_fg(idx_anchor_count,4)-gt(gt_count,4))+fg_h(k);
                    
                    % ---------------------------- W2 GIoU -------------------------- % 
                    pred_w2g_tblr=to_tblr(pred_w2g(idx_anchor_count,:));
                    giou_value=giou(pred_w2g_tblr,gt_tblr);
                    mean_iou_w2g=(1-momentum)*mean_iou_w2g + momentum*giou_value;  %不断更新 mean IOU
                    dgiou_xywh=dDIOU(pred_w2g(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);

                    w2_value = wiouv2(giou_value,mean_iou_w2g);
                    pred_w2g(idx_anchor_count,1)=pred_w2g(idx_anchor_count,1)+w2_value*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_w2g(idx_anchor_count,2)=pred_w2g(idx_anchor_count,2)+w2_value*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_w2g(idx_anchor_count,3)=pred_w2g(idx_anchor_count,3)+w2_value*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_w2g(idx_anchor_count,4)=pred_w2g(idx_anchor_count,4)+w2_value*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_wiouv2_giou(k,2:5)=pred_w2g(idx_anchor_count);
                    loss_w2g(idx_anchor_count,1:4)=abs(epoch_id_wiouv2_giou(k,2:5)-gt(gt_count,1:4))+loss_w2g(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    w2g_x(k)=abs(pred_w2g(idx_anchor_count,1)-gt(gt_count,1))+w2g_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    w2g_y(k)=abs(pred_w2g(idx_anchor_count,2)-gt(gt_count,2))+w2g_y(k);
                    w2g_w(k)=abs(pred_w2g(idx_anchor_count,3)-gt(gt_count,3))+w2g_w(k);
                    w2g_h(k)=abs(pred_w2g(idx_anchor_count,4)-gt(gt_count,4))+w2g_h(k);
                    
                    % ---------------------------- A2 GIoU -------------------------- % 
                    pred_a2g_tblr=to_tblr(pred_a2g(idx_anchor_count,:));
                    giou_value=giou(pred_a2g_tblr,gt_tblr);
                    mean_iou_a2g=(1-momentum)*mean_iou_a2g + momentum*giou_value;  %不断更新 mean IOU
                    dgiou_xywh=dDIOU(pred_a2g(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);

                    a2_value = aiouv2(giou_value,mean_iou_a2g);
                    pred_a2g(idx_anchor_count,1)=pred_a2g(idx_anchor_count,1)+a2_value*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_a2g(idx_anchor_count,2)=pred_a2g(idx_anchor_count,2)+a2_value*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_a2g(idx_anchor_count,3)=pred_a2g(idx_anchor_count,3)+a2_value*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_a2g(idx_anchor_count,4)=pred_a2g(idx_anchor_count,4)+a2_value*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_aiouv2_giou(k,2:5)=pred_a2g(idx_anchor_count);
                    loss_a2g(idx_anchor_count,1:4)=abs(epoch_id_aiouv2_giou(k,2:5)-gt(gt_count,1:4))+loss_a2g(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    a2g_x(k)=abs(pred_a2g(idx_anchor_count,1)-gt(gt_count,1))+a2g_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    a2g_y(k)=abs(pred_a2g(idx_anchor_count,2)-gt(gt_count,2))+a2g_y(k);
                    a2g_w(k)=abs(pred_a2g(idx_anchor_count,3)-gt(gt_count,3))+a2g_w(k);
                    a2g_h(k)=abs(pred_a2g(idx_anchor_count,4)-gt(gt_count,4))+a2g_h(k);
                    
                    % ---------------------------- W3 GIoU -------------------------- % 
                    pred_w3g_tblr=to_tblr(pred_w3g(idx_anchor_count,:));
                    giou_value=giou(pred_w3g_tblr,gt_tblr);
                    mean_iou_w3g=(1-momentum)*mean_iou_w3g + momentum*giou_value;  %不断更新 mean IOU
                    dgiou_xywh=dDIOU(pred_w3g(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);

                    w3_value = wiouv3(giou_value,mean_iou_w3g);
                    pred_w3g(idx_anchor_count,1)=pred_w3g(idx_anchor_count,1)+w3_value*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_w3g(idx_anchor_count,2)=pred_w3g(idx_anchor_count,2)+w3_value*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_w3g(idx_anchor_count,3)=pred_w3g(idx_anchor_count,3)+w3_value*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_w3g(idx_anchor_count,4)=pred_w3g(idx_anchor_count,4)+w3_value*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_wiouv3_giou(k,2:5)=pred_w3g(idx_anchor_count);
                    loss_w3g(idx_anchor_count,1:4)=abs(epoch_id_wiouv3_giou(k,2:5)-gt(gt_count,1:4))+loss_w3g(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    w3g_x(k)=abs(pred_w3g(idx_anchor_count,1)-gt(gt_count,1))+w3g_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    w3g_y(k)=abs(pred_w3g(idx_anchor_count,2)-gt(gt_count,2))+w3g_y(k);
                    w3g_w(k)=abs(pred_w3g(idx_anchor_count,3)-gt(gt_count,3))+w3g_w(k);
                    w3g_h(k)=abs(pred_w3g(idx_anchor_count,4)-gt(gt_count,4))+w3g_h(k);
                    
                    % ---------------------------- A3 GIoU -------------------------- % 
                    pred_a3g_tblr=to_tblr(pred_a3g(idx_anchor_count,:));
                    giou_value=giou(pred_a3g_tblr,gt_tblr);
                    mean_iou_a3g=(1-momentum)*mean_iou_a3g + momentum*giou_value;  %不断更新 mean IOU
                    dgiou_xywh=dDIOU(pred_a3g(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);

                    a3_value = aiouv3(giou_value,mean_iou_a3g);
                    pred_a3g(idx_anchor_count,1)=pred_a3g(idx_anchor_count,1)+a3_value*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_a3g(idx_anchor_count,2)=pred_a3g(idx_anchor_count,2)+a3_value*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_a3g(idx_anchor_count,3)=pred_a3g(idx_anchor_count,3)+a3_value*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_a3g(idx_anchor_count,4)=pred_a3g(idx_anchor_count,4)+a3_value*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_aiouv3_giou(k,2:5)=pred_a3g(idx_anchor_count);
                    loss_a3g(idx_anchor_count,1:4)=abs(epoch_id_aiouv3_giou(k,2:5)-gt(gt_count,1:4))+loss_a3g(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    a3g_x(k)=abs(pred_a3g(idx_anchor_count,1)-gt(gt_count,1))+a3g_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    a3g_y(k)=abs(pred_a3g(idx_anchor_count,2)-gt(gt_count,2))+a3g_y(k);
                    a3g_w(k)=abs(pred_a3g(idx_anchor_count,3)-gt(gt_count,3))+a3g_w(k);
                    a3g_h(k)=abs(pred_a3g(idx_anchor_count,4)-gt(gt_count,4))+a3g_h(k);
                    
                    % ---------------------------- Per GIoU -------------------------- % 
                    pred_pg_tblr=to_tblr(pred_pg(idx_anchor_count,:));
                    giou_value=giou(pred_pg_tblr,gt_tblr);
                    mean_iou_pg=(1-momentum)*mean_iou_pg + momentum*giou_value;  %不断更新 mean IOU
                    dgiou_xywh=dDIOU(pred_pg(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);

                    per_value = PersonalizationFM(giou_value,mean_iou_pg,dataset_queality,k/epoch_num);
                    pred_pg(idx_anchor_count,1)=pred_pg(idx_anchor_count,1)+per_value*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_pg(idx_anchor_count,2)=pred_pg(idx_anchor_count,2)+per_value*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_pg(idx_anchor_count,3)=pred_pg(idx_anchor_count,3)+per_value*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_pg(idx_anchor_count,4)=pred_pg(idx_anchor_count,4)+per_value*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_per_giou(k,2:5)=pred_pg(idx_anchor_count);
                    loss_pg(idx_anchor_count,1:4)=abs(epoch_id_per_giou(k,2:5)-gt(gt_count,1:4))+loss_pg(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    pg_x(k)=abs(pred_pg(idx_anchor_count,1)-gt(gt_count,1))+pg_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    pg_y(k)=abs(pred_pg(idx_anchor_count,2)-gt(gt_count,2))+pg_y(k);
                    pg_w(k)=abs(pred_pg(idx_anchor_count,3)-gt(gt_count,3))+pg_w(k);
                    pg_h(k)=abs(pred_pg(idx_anchor_count,4)-gt(gt_count,4))+pg_h(k);
                    
                end
            end
        end
    end
    for k=(0.8*epoch_num+1):(0.9*epoch_num)				%do bounding box regression by gradient descent algorithm
        fprintf('进度：%.2f / 200......IoU 值：IoU-%.3f; GIoU-%.3f; FGIoU-%.3f; W2IoU-%.3f; A2IoU-%.3f; W3IoU-%.3f; A3IoU-%.3f; PerIoU-%.3f \n',k,mean_iou,mean_iou_g,mean_iou_fg,mean_iou_w2g,mean_iou_a2g,mean_iou_w3g,mean_iou_a3g,mean_iou_pg);
        for points=1:5000
            for gt_count=1:7
                for anchor_count=1:49
                    idx_anchor_count = 343*(points-1)+49*(gt_count-1)+anchor_count;
                    gt_tblr=to_tblr(gt(gt_count,:));
                    % ---------------------------- IoU -------------------------- % 
                    pred_i_tblr=to_tblr(pred_i(idx_anchor_count,:));
                    iou_value=iou(pred_i_tblr,gt_tblr);
                    giou_value=giou(pred_i_tblr,gt_tblr);
                    mean_iou=(1-momentum)*mean_iou + momentum*giou_value;
                    diou=dIOU(pred_i_tblr,gt_tblr);
                    diou_xywh=to_xywh(diou);
                    pred_i(idx_anchor_count,1)=pred_i(idx_anchor_count,1)+0.1*learning_rate*(1-iou_value)*diou_xywh.dx;
                    pred_i(idx_anchor_count,2)=pred_i(idx_anchor_count,2)+0.1*learning_rate*(1-iou_value)*diou_xywh.dy;
                    pred_i(idx_anchor_count,3)=pred_i(idx_anchor_count,3)+0.1*learning_rate*(1-iou_value)*diou_xywh.dw;
                    pred_i(idx_anchor_count,4)=pred_i(idx_anchor_count,4)+0.1*learning_rate*(1-iou_value)*diou_xywh.dh;
                    epoch_id_iou(k,2:5)=pred_i(idx_anchor_count);
                    loss_i(idx_anchor_count,1:4)=abs(epoch_id_iou(k,2:5)-gt(gt_count,1:4))+loss_i(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    i_x(k)=abs(pred_i(idx_anchor_count,1)-gt(gt_count,1))+i_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    i_y(k)=abs(pred_i(idx_anchor_count,2)-gt(gt_count,2))+i_y(k);
                    i_w(k)=abs(pred_i(idx_anchor_count,3)-gt(gt_count,3))+i_w(k);
                    i_h(k)=abs(pred_i(idx_anchor_count,4)-gt(gt_count,4))+i_h(k);
                    
                    % ---------------------------- GIoU -------------------------- % 
                    pred_g_tblr=to_tblr(pred_g(idx_anchor_count,:));
                    giou_value=giou(pred_g_tblr,gt_tblr);
                    mean_iou_g=(1-momentum)*mean_iou_g + momentum*giou_value;
                    dgiou_xywh=dDIOU(pred_g(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);
                    pred_g(idx_anchor_count,1)=pred_g(idx_anchor_count,1)+0.1*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_g(idx_anchor_count,2)=pred_g(idx_anchor_count,2)+0.1*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_g(idx_anchor_count,3)=pred_g(idx_anchor_count,3)+0.1*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_g(idx_anchor_count,4)=pred_g(idx_anchor_count,4)+0.1*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_giou(k,2:5)=pred_g(idx_anchor_count);
                    loss_g(idx_anchor_count,1:4)=abs(epoch_id_giou(k,2:5)-gt(gt_count,1:4))+loss_g(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    g_x(k)=abs(pred_g(idx_anchor_count,1)-gt(gt_count,1))+g_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    g_y(k)=abs(pred_g(idx_anchor_count,2)-gt(gt_count,2))+g_y(k);
                    g_w(k)=abs(pred_g(idx_anchor_count,3)-gt(gt_count,3))+g_w(k);
                    g_h(k)=abs(pred_g(idx_anchor_count,4)-gt(gt_count,4))+g_h(k);
                    
                    % ---------------------------- Focal GIoU -------------------------- % 
                    pred_fg_tblr=to_tblr(pred_fg(idx_anchor_count,:));
                    giou_value=giou(pred_fg_tblr,gt_tblr);
                    mean_iou_fg=(1-momentum)*mean_iou_fg + momentum*giou_value;  %不断更新 mean IOU
                    dgiou_xywh=dDIOU(pred_fg(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);

                    focal_loss_value = focal_loss(giou_value);
                    pred_fg(idx_anchor_count,1)=pred_fg(idx_anchor_count,1)+focal_loss_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_fg(idx_anchor_count,2)=pred_fg(idx_anchor_count,2)+focal_loss_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_fg(idx_anchor_count,3)=pred_fg(idx_anchor_count,3)+focal_loss_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_fg(idx_anchor_count,4)=pred_fg(idx_anchor_count,4)+focal_loss_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_focal_giou(k,2:5)=pred_fg(idx_anchor_count);
                    loss_fg(idx_anchor_count,1:4)=abs(epoch_id_focal_giou(k,2:5)-gt(gt_count,1:4))+loss_fg(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    fg_x(k)=abs(pred_fg(idx_anchor_count,1)-gt(gt_count,1))+fg_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    fg_y(k)=abs(pred_fg(idx_anchor_count,2)-gt(gt_count,2))+fg_y(k);
                    fg_w(k)=abs(pred_fg(idx_anchor_count,3)-gt(gt_count,3))+fg_w(k);
                    fg_h(k)=abs(pred_fg(idx_anchor_count,4)-gt(gt_count,4))+fg_h(k);
                    
                    % ---------------------------- W2 GIoU -------------------------- % 
                    pred_w2g_tblr=to_tblr(pred_w2g(idx_anchor_count,:));
                    giou_value=giou(pred_w2g_tblr,gt_tblr);
                    mean_iou_w2g=(1-momentum)*mean_iou_w2g + momentum*giou_value;  %不断更新 mean IOU
                    dgiou_xywh=dDIOU(pred_w2g(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);

                    w2_value = wiouv2(giou_value,mean_iou_w2g);
                    pred_w2g(idx_anchor_count,1)=pred_w2g(idx_anchor_count,1)+w2_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_w2g(idx_anchor_count,2)=pred_w2g(idx_anchor_count,2)+w2_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_w2g(idx_anchor_count,3)=pred_w2g(idx_anchor_count,3)+w2_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_w2g(idx_anchor_count,4)=pred_w2g(idx_anchor_count,4)+w2_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_wiouv2_giou(k,2:5)=pred_w2g(idx_anchor_count);
                    loss_w2g(idx_anchor_count,1:4)=abs(epoch_id_wiouv2_giou(k,2:5)-gt(gt_count,1:4))+loss_w2g(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    w2g_x(k)=abs(pred_w2g(idx_anchor_count,1)-gt(gt_count,1))+w2g_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    w2g_y(k)=abs(pred_w2g(idx_anchor_count,2)-gt(gt_count,2))+w2g_y(k);
                    w2g_w(k)=abs(pred_w2g(idx_anchor_count,3)-gt(gt_count,3))+w2g_w(k);
                    w2g_h(k)=abs(pred_w2g(idx_anchor_count,4)-gt(gt_count,4))+w2g_h(k);
                    
                    % ---------------------------- A2 GIoU -------------------------- % 
                    pred_a2g_tblr=to_tblr(pred_a2g(idx_anchor_count,:));
                    giou_value=giou(pred_a2g_tblr,gt_tblr);
                    mean_iou_a2g=(1-momentum)*mean_iou_a2g + momentum*giou_value;  %不断更新 mean IOU
                    dgiou_xywh=dDIOU(pred_a2g(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);

                    a2_value = aiouv2(giou_value,mean_iou_a2g);
                    pred_a2g(idx_anchor_count,1)=pred_a2g(idx_anchor_count,1)+a2_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_a2g(idx_anchor_count,2)=pred_a2g(idx_anchor_count,2)+a2_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_a2g(idx_anchor_count,3)=pred_a2g(idx_anchor_count,3)+a2_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_a2g(idx_anchor_count,4)=pred_a2g(idx_anchor_count,4)+a2_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_aiouv2_giou(k,2:5)=pred_a2g(idx_anchor_count);
                    loss_a2g(idx_anchor_count,1:4)=abs(epoch_id_aiouv2_giou(k,2:5)-gt(gt_count,1:4))+loss_a2g(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    a2g_x(k)=abs(pred_a2g(idx_anchor_count,1)-gt(gt_count,1))+a2g_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    a2g_y(k)=abs(pred_a2g(idx_anchor_count,2)-gt(gt_count,2))+a2g_y(k);
                    a2g_w(k)=abs(pred_a2g(idx_anchor_count,3)-gt(gt_count,3))+a2g_w(k);
                    a2g_h(k)=abs(pred_a2g(idx_anchor_count,4)-gt(gt_count,4))+a2g_h(k);
                    
                    % ---------------------------- W3 GIoU -------------------------- % 
                    pred_w3g_tblr=to_tblr(pred_w3g(idx_anchor_count,:));
                    giou_value=giou(pred_w3g_tblr,gt_tblr);
                    mean_iou_w3g=(1-momentum)*mean_iou_w3g + momentum*giou_value;  %不断更新 mean IOU
                    dgiou_xywh=dDIOU(pred_w3g(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);

                    w3_value = wiouv3(giou_value,mean_iou_w3g);
                    pred_w3g(idx_anchor_count,1)=pred_w3g(idx_anchor_count,1)+w3_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_w3g(idx_anchor_count,2)=pred_w3g(idx_anchor_count,2)+w3_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_w3g(idx_anchor_count,3)=pred_w3g(idx_anchor_count,3)+w3_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_w3g(idx_anchor_count,4)=pred_w3g(idx_anchor_count,4)+w3_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_wiouv3_giou(k,2:5)=pred_w3g(idx_anchor_count);
                    loss_w3g(idx_anchor_count,1:4)=abs(epoch_id_wiouv3_giou(k,2:5)-gt(gt_count,1:4))+loss_w3g(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    w3g_x(k)=abs(pred_w3g(idx_anchor_count,1)-gt(gt_count,1))+w3g_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    w3g_y(k)=abs(pred_w3g(idx_anchor_count,2)-gt(gt_count,2))+w3g_y(k);
                    w3g_w(k)=abs(pred_w3g(idx_anchor_count,3)-gt(gt_count,3))+w3g_w(k);
                    w3g_h(k)=abs(pred_w3g(idx_anchor_count,4)-gt(gt_count,4))+w3g_h(k);
                    
                    % ---------------------------- A3 GIoU -------------------------- % 
                    pred_a3g_tblr=to_tblr(pred_a3g(idx_anchor_count,:));
                    giou_value=giou(pred_a3g_tblr,gt_tblr);
                    mean_iou_a3g=(1-momentum)*mean_iou_a3g + momentum*giou_value;  %不断更新 mean IOU
                    dgiou_xywh=dDIOU(pred_a3g(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);

                    a3_value = aiouv3(giou_value,mean_iou_a3g);
                    pred_a3g(idx_anchor_count,1)=pred_a3g(idx_anchor_count,1)+a3_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_a3g(idx_anchor_count,2)=pred_a3g(idx_anchor_count,2)+a3_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_a3g(idx_anchor_count,3)=pred_a3g(idx_anchor_count,3)+a3_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_a3g(idx_anchor_count,4)=pred_a3g(idx_anchor_count,4)+a3_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_aiouv3_giou(k,2:5)=pred_a3g(idx_anchor_count);
                    loss_a3g(idx_anchor_count,1:4)=abs(epoch_id_aiouv3_giou(k,2:5)-gt(gt_count,1:4))+loss_a3g(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    a3g_x(k)=abs(pred_a3g(idx_anchor_count,1)-gt(gt_count,1))+a3g_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    a3g_y(k)=abs(pred_a3g(idx_anchor_count,2)-gt(gt_count,2))+a3g_y(k);
                    a3g_w(k)=abs(pred_a3g(idx_anchor_count,3)-gt(gt_count,3))+a3g_w(k);
                    a3g_h(k)=abs(pred_a3g(idx_anchor_count,4)-gt(gt_count,4))+a3g_h(k);
                    
                    % ---------------------------- Per GIoU -------------------------- % 
                    pred_pg_tblr=to_tblr(pred_pg(idx_anchor_count,:));
                    giou_value=giou(pred_pg_tblr,gt_tblr);
                    mean_iou_pg=(1-momentum)*mean_iou_pg + momentum*giou_value;  %不断更新 mean IOU
                    dgiou_xywh=dDIOU(pred_pg(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);

                    per_value = PersonalizationFM(giou_value,mean_iou_pg,dataset_queality,k/epoch_num);
                    pred_pg(idx_anchor_count,1)=pred_pg(idx_anchor_count,1)+per_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_pg(idx_anchor_count,2)=pred_pg(idx_anchor_count,2)+per_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_pg(idx_anchor_count,3)=pred_pg(idx_anchor_count,3)+per_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_pg(idx_anchor_count,4)=pred_pg(idx_anchor_count,4)+per_value*0.1*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_per_giou(k,2:5)=pred_pg(idx_anchor_count);
                    loss_pg(idx_anchor_count,1:4)=abs(epoch_id_per_giou(k,2:5)-gt(gt_count,1:4))+loss_pg(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    pg_x(k)=abs(pred_pg(idx_anchor_count,1)-gt(gt_count,1))+pg_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    pg_y(k)=abs(pred_pg(idx_anchor_count,2)-gt(gt_count,2))+pg_y(k);
                    pg_w(k)=abs(pred_pg(idx_anchor_count,3)-gt(gt_count,3))+pg_w(k);
                    pg_h(k)=abs(pred_pg(idx_anchor_count,4)-gt(gt_count,4))+pg_h(k);
                end
            end
        end
    end
    for k=(0.9*epoch_num+1):epoch_num				%do bounding box regression by gradient descent algorithm
        fprintf('进度：%.2f / 200......IoU 值：IoU-%.3f; GIoU-%.3f; FGIoU-%.3f; W2IoU-%.3f; A2IoU-%.3f; W3IoU-%.3f; A3IoU-%.3f; PerIoU-%.3f \n',k,mean_iou,mean_iou_g,mean_iou_fg,mean_iou_w2g,mean_iou_a2g,mean_iou_w3g,mean_iou_a3g,mean_iou_pg);
        for points=1:5000
            for gt_count=1:7
                for anchor_count=1:49
                    idx_anchor_count = 343*(points-1)+49*(gt_count-1)+anchor_count;
                    gt_tblr=to_tblr(gt(gt_count,:));
                    % ---------------------------- IoU -------------------------- % 
                    pred_i_tblr=to_tblr(pred_i(idx_anchor_count,:));
                    iou_value=iou(pred_i_tblr,gt_tblr);
                    giou_value=giou(pred_i_tblr,gt_tblr);
                    mean_iou=(1-momentum)*mean_iou + momentum*giou_value;
                    diou=dIOU(pred_i_tblr,gt_tblr);
                    diou_xywh=to_xywh(diou);
                    pred_i(idx_anchor_count,1)=pred_i(idx_anchor_count,1)+0.01*learning_rate*(1-iou_value)*diou_xywh.dx;
                    pred_i(idx_anchor_count,2)=pred_i(idx_anchor_count,2)+0.01*learning_rate*(1-iou_value)*diou_xywh.dy;
                    pred_i(idx_anchor_count,3)=pred_i(idx_anchor_count,3)+0.01*learning_rate*(1-iou_value)*diou_xywh.dw;
                    pred_i(idx_anchor_count,4)=pred_i(idx_anchor_count,4)+0.01*learning_rate*(1-iou_value)*diou_xywh.dh;
                    epoch_id_iou(k,2:5)=pred_i(idx_anchor_count);
                    loss_i(idx_anchor_count,1:4)=abs(epoch_id_iou(k,2:5)-gt(gt_count,1:4))+loss_i(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    i_x(k)=abs(pred_i(idx_anchor_count,1)-gt(gt_count,1))+i_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    i_y(k)=abs(pred_i(idx_anchor_count,2)-gt(gt_count,2))+i_y(k);
                    i_w(k)=abs(pred_i(idx_anchor_count,3)-gt(gt_count,3))+i_w(k);
                    i_h(k)=abs(pred_i(idx_anchor_count,4)-gt(gt_count,4))+i_h(k);
                    
                    % ---------------------------- GIoU -------------------------- % 
                    pred_g_tblr=to_tblr(pred_g(idx_anchor_count,:));
                    giou_value=giou(pred_g_tblr,gt_tblr);
                    mean_iou_g=(1-momentum)*mean_iou_g + momentum*giou_value;
                    dgiou_xywh=dDIOU(pred_g(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);
                    pred_g(idx_anchor_count,1)=pred_g(idx_anchor_count,1)+0.01*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_g(idx_anchor_count,2)=pred_g(idx_anchor_count,2)+0.01*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_g(idx_anchor_count,3)=pred_g(idx_anchor_count,3)+0.01*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_g(idx_anchor_count,4)=pred_g(idx_anchor_count,4)+0.01*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_giou(k,2:5)=pred_g(idx_anchor_count);
                    loss_g(idx_anchor_count,1:4)=abs(epoch_id_giou(k,2:5)-gt(gt_count,1:4))+loss_g(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    g_x(k)=abs(pred_g(idx_anchor_count,1)-gt(gt_count,1))+g_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    g_y(k)=abs(pred_g(idx_anchor_count,2)-gt(gt_count,2))+g_y(k);
                    g_w(k)=abs(pred_g(idx_anchor_count,3)-gt(gt_count,3))+g_w(k);
                    g_h(k)=abs(pred_g(idx_anchor_count,4)-gt(gt_count,4))+g_h(k);
                    
                    % ---------------------------- Focal GIoU -------------------------- % 
                    pred_fg_tblr=to_tblr(pred_fg(idx_anchor_count,:));
                    giou_value=giou(pred_fg_tblr,gt_tblr);
                    mean_iou_fg=(1-momentum)*mean_iou_fg + momentum*giou_value;  %不断更新 mean IOU
                    dgiou_xywh=dDIOU(pred_fg(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);

                    focal_loss_value = focal_loss(giou_value);
                    pred_fg(idx_anchor_count,1)=pred_fg(idx_anchor_count,1)+focal_loss_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_fg(idx_anchor_count,2)=pred_fg(idx_anchor_count,2)+focal_loss_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_fg(idx_anchor_count,3)=pred_fg(idx_anchor_count,3)+focal_loss_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_fg(idx_anchor_count,4)=pred_fg(idx_anchor_count,4)+focal_loss_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_focal_giou(k,2:5)=pred_fg(idx_anchor_count);
                    loss_fg(idx_anchor_count,1:4)=abs(epoch_id_focal_giou(k,2:5)-gt(gt_count,1:4))+loss_fg(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    fg_x(k)=abs(pred_fg(idx_anchor_count,1)-gt(gt_count,1))+fg_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    fg_y(k)=abs(pred_fg(idx_anchor_count,2)-gt(gt_count,2))+fg_y(k);
                    fg_w(k)=abs(pred_fg(idx_anchor_count,3)-gt(gt_count,3))+fg_w(k);
                    fg_h(k)=abs(pred_fg(idx_anchor_count,4)-gt(gt_count,4))+fg_h(k);
                    
                    % ---------------------------- W2 GIoU -------------------------- % 
                    pred_w2g_tblr=to_tblr(pred_w2g(idx_anchor_count,:));
                    giou_value=giou(pred_w2g_tblr,gt_tblr);
                    mean_iou_w2g=(1-momentum)*mean_iou_w2g + momentum*giou_value;  %不断更新 mean IOU
                    dgiou_xywh=dDIOU(pred_w2g(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);

                    w2_value = wiouv2(giou_value,mean_iou_w2g);
                    pred_w2g(idx_anchor_count,1)=pred_w2g(idx_anchor_count,1)+w2_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_w2g(idx_anchor_count,2)=pred_w2g(idx_anchor_count,2)+w2_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_w2g(idx_anchor_count,3)=pred_w2g(idx_anchor_count,3)+w2_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_w2g(idx_anchor_count,4)=pred_w2g(idx_anchor_count,4)+w2_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_wiouv2_giou(k,2:5)=pred_w2g(idx_anchor_count);
                    loss_w2g(idx_anchor_count,1:4)=abs(epoch_id_wiouv2_giou(k,2:5)-gt(gt_count,1:4))+loss_w2g(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    w2g_x(k)=abs(pred_w2g(idx_anchor_count,1)-gt(gt_count,1))+w2g_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    w2g_y(k)=abs(pred_w2g(idx_anchor_count,2)-gt(gt_count,2))+w2g_y(k);
                    w2g_w(k)=abs(pred_w2g(idx_anchor_count,3)-gt(gt_count,3))+w2g_w(k);
                    w2g_h(k)=abs(pred_w2g(idx_anchor_count,4)-gt(gt_count,4))+w2g_h(k);
                    
                    % ---------------------------- A2 GIoU -------------------------- % 
                    pred_a2g_tblr=to_tblr(pred_a2g(idx_anchor_count,:));
                    giou_value=giou(pred_a2g_tblr,gt_tblr);
                    mean_iou_a2g=(1-momentum)*mean_iou_a2g + momentum*giou_value;  %不断更新 mean IOU
                    dgiou_xywh=dDIOU(pred_a2g(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);

                    a2_value = aiouv2(giou_value,mean_iou_a2g);
                    pred_a2g(idx_anchor_count,1)=pred_a2g(idx_anchor_count,1)+a2_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_a2g(idx_anchor_count,2)=pred_a2g(idx_anchor_count,2)+a2_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_a2g(idx_anchor_count,3)=pred_a2g(idx_anchor_count,3)+a2_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_a2g(idx_anchor_count,4)=pred_a2g(idx_anchor_count,4)+a2_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_aiouv2_giou(k,2:5)=pred_a2g(idx_anchor_count);
                    loss_a2g(idx_anchor_count,1:4)=abs(epoch_id_aiouv2_giou(k,2:5)-gt(gt_count,1:4))+loss_a2g(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    a2g_x(k)=abs(pred_a2g(idx_anchor_count,1)-gt(gt_count,1))+a2g_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    a2g_y(k)=abs(pred_a2g(idx_anchor_count,2)-gt(gt_count,2))+a2g_y(k);
                    a2g_w(k)=abs(pred_a2g(idx_anchor_count,3)-gt(gt_count,3))+a2g_w(k);
                    a2g_h(k)=abs(pred_a2g(idx_anchor_count,4)-gt(gt_count,4))+a2g_h(k);
                    
                    % ---------------------------- W3 GIoU -------------------------- % 
                    pred_w3g_tblr=to_tblr(pred_w3g(idx_anchor_count,:));
                    giou_value=giou(pred_w3g_tblr,gt_tblr);
                    mean_iou_w3g=(1-momentum)*mean_iou_w3g + momentum*giou_value;  %不断更新 mean IOU
                    dgiou_xywh=dDIOU(pred_w3g(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);

                    w3_value = wiouv3(giou_value,mean_iou_w3g);
                    pred_w3g(idx_anchor_count,1)=pred_w3g(idx_anchor_count,1)+w3_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_w3g(idx_anchor_count,2)=pred_w3g(idx_anchor_count,2)+w3_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_w3g(idx_anchor_count,3)=pred_w3g(idx_anchor_count,3)+w3_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_w3g(idx_anchor_count,4)=pred_w3g(idx_anchor_count,4)+w3_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_wiouv3_giou(k,2:5)=pred_w3g(idx_anchor_count);
                    loss_w3g(idx_anchor_count,1:4)=abs(epoch_id_wiouv3_giou(k,2:5)-gt(gt_count,1:4))+loss_w3g(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    w3g_x(k)=abs(pred_w3g(idx_anchor_count,1)-gt(gt_count,1))+w3g_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    w3g_y(k)=abs(pred_w3g(idx_anchor_count,2)-gt(gt_count,2))+w3g_y(k);
                    w3g_w(k)=abs(pred_w3g(idx_anchor_count,3)-gt(gt_count,3))+w3g_w(k);
                    w3g_h(k)=abs(pred_w3g(idx_anchor_count,4)-gt(gt_count,4))+w3g_h(k);
                    
                    % ---------------------------- A3 GIoU -------------------------- % 
                    pred_a3g_tblr=to_tblr(pred_a3g(idx_anchor_count,:));
                    giou_value=giou(pred_a3g_tblr,gt_tblr);
                    mean_iou_a3g=(1-momentum)*mean_iou_a3g + momentum*giou_value;  %不断更新 mean IOU
                    dgiou_xywh=dDIOU(pred_a3g(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);

                    a3_value = aiouv3(giou_value,mean_iou_a3g);
                    pred_a3g(idx_anchor_count,1)=pred_a3g(idx_anchor_count,1)+a3_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_a3g(idx_anchor_count,2)=pred_a3g(idx_anchor_count,2)+a3_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_a3g(idx_anchor_count,3)=pred_a3g(idx_anchor_count,3)+a3_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_a3g(idx_anchor_count,4)=pred_a3g(idx_anchor_count,4)+a3_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_aiouv3_giou(k,2:5)=pred_a3g(idx_anchor_count);
                    loss_a3g(idx_anchor_count,1:4)=abs(epoch_id_aiouv3_giou(k,2:5)-gt(gt_count,1:4))+loss_a3g(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    a3g_x(k)=abs(pred_a3g(idx_anchor_count,1)-gt(gt_count,1))+a3g_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    a3g_y(k)=abs(pred_a3g(idx_anchor_count,2)-gt(gt_count,2))+a3g_y(k);
                    a3g_w(k)=abs(pred_a3g(idx_anchor_count,3)-gt(gt_count,3))+a3g_w(k);
                    a3g_h(k)=abs(pred_a3g(idx_anchor_count,4)-gt(gt_count,4))+a3g_h(k);
                    
                    % ---------------------------- Per GIoU -------------------------- % 
                    pred_pg_tblr=to_tblr(pred_pg(idx_anchor_count,:));
                    giou_value=giou(pred_pg_tblr,gt_tblr);
                    mean_iou_pg=(1-momentum)*mean_iou_pg + momentum*giou_value;  %不断更新 mean IOU
                    dgiou_xywh=dDIOU(pred_pg(idx_anchor_count,:),gt(gt_count,:));
                    % dgiou_xywh=to_xywh(dgiou);

                    per_value = PersonalizationFM(giou_value,mean_iou_pg,dataset_queality,k/epoch_num);
                    pred_pg(idx_anchor_count,1)=pred_pg(idx_anchor_count,1)+per_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dx;
                    pred_pg(idx_anchor_count,2)=pred_pg(idx_anchor_count,2)+per_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dy;
                    pred_pg(idx_anchor_count,3)=pred_pg(idx_anchor_count,3)+per_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dw;
                    pred_pg(idx_anchor_count,4)=pred_pg(idx_anchor_count,4)+per_value*0.01*learning_rate*(1-giou_value)*dgiou_xywh.dh;
                    epoch_id_per_giou(k,2:5)=pred_pg(idx_anchor_count);
                    loss_pg(idx_anchor_count,1:4)=abs(epoch_id_per_giou(k,2:5)-gt(gt_count,1:4))+loss_pg(idx_anchor_count,1:4); % 第几个target对应的第几个anchor 的loss
                    pg_x(k)=abs(pred_pg(idx_anchor_count,1)-gt(gt_count,1))+pg_x(k); %不管是哪个 anchor 和 target ，只看是哪个epoch的损失
                    pg_y(k)=abs(pred_pg(idx_anchor_count,2)-gt(gt_count,2))+pg_y(k);
                    pg_w(k)=abs(pred_pg(idx_anchor_count,3)-gt(gt_count,3))+pg_w(k);
                    pg_h(k)=abs(pred_pg(idx_anchor_count,4)-gt(gt_count,4))+pg_h(k);
                end
            end
        end
    end
    fprintf('完成回归，开始存储数据\n');
    for points=1:5000
        for gt_count=1:7
            for anchor_count=1:49
                idx_anchor_count = 343*(points-1)+49*(gt_count-1)+anchor_count;
                mm1=mm1+1;
                position_x(mm1)=pred(idx_anchor_count,1);
                position_y(mm1)=pred(idx_anchor_count,2);
                position_w(mm1)=pred(idx_anchor_count,3);
                position_h(mm1)=pred(idx_anchor_count,4);
                
                % ---------------------------- IoU -------------------------- % 
                final_error_iou(mm1)=abs(pred_i(idx_anchor_count,1)-gt(gt_count,1))+abs(pred_i(idx_anchor_count,2)-gt(gt_count,2))+abs(pred_i(idx_anchor_count,3)-gt(gt_count,3))+abs(pred_i(idx_anchor_count,4)-gt(gt_count,4)); % 每个 perd 和 anchor 的 loss
                iou0(idx_anchor_count,l)=loss_i(idx_anchor_count,1)+loss_i(idx_anchor_count,2)+loss_i(idx_anchor_count,3)+loss_i(idx_anchor_count,4); % target * anchor 的个数
                IoU_Loss(mm1)=iou0(idx_anchor_count,l);
                fprintf(F_i, '%d\t',mm1);
                fprintf(F_i, '%f\t',position_x(mm1));
                fprintf(F_i, '%f\t',position_y(mm1));
                fprintf(F_i, '%f\t',position_w(mm1));
                fprintf(F_i, '%f\t',position_h(mm1));
                fprintf(F_i, '%f\t',IoU_Loss(mm1));
                fprintf(F_i, '%f\n',final_error_iou(mm1));				%save results for every regression cases
                
                % ---------------------------- GIoU -------------------------- % 
                final_error_giou(mm1)=abs(pred_g(idx_anchor_count,1)-gt(gt_count,1))+abs(pred_g(idx_anchor_count,2)-gt(gt_count,2))+abs(pred_g(idx_anchor_count,3)-gt(gt_count,3))+abs(pred_g(idx_anchor_count,4)-gt(gt_count,4)); % 每个 perd 和 anchor 的 loss
                giou0(idx_anchor_count,l)=loss_g(idx_anchor_count,1)+loss_g(idx_anchor_count,2)+loss_g(idx_anchor_count,3)+loss_g(idx_anchor_count,4); % target * anchor 的个数
                GIoU_Loss(mm1)=giou0(idx_anchor_count,l);
                fprintf(F_g, '%d\t',mm1);
                fprintf(F_g, '%f\t',position_x(mm1));
                fprintf(F_g, '%f\t',position_y(mm1));
                fprintf(F_g, '%f\t',position_w(mm1));
                fprintf(F_g, '%f\t',position_h(mm1));
                fprintf(F_g, '%f\t',GIoU_Loss(mm1));
                fprintf(F_g, '%f\n',final_error_giou(mm1));				%save results for every regression cases
                
                % ---------------------------- Focal GIoU -------------------------- % 
                final_error_focal_giou(mm1)=abs(pred_fg(idx_anchor_count,1)-gt(gt_count,1))+abs(pred_fg(idx_anchor_count,2)-gt(gt_count,2))+abs(pred_fg(idx_anchor_count,3)-gt(gt_count,3))+abs(pred_fg(idx_anchor_count,4)-gt(gt_count,4)); % 每个 perd 和 anchor 的 loss
                focal_giou0(idx_anchor_count,l)=loss_fg(idx_anchor_count,1)+loss_fg(idx_anchor_count,2)+loss_fg(idx_anchor_count,3)+loss_fg(idx_anchor_count,4); % target * anchor 的个数
                Focal_GIoU_Loss(mm1)=focal_giou0(idx_anchor_count,l);
                fprintf(F_fg, '%d\t',mm1);
                fprintf(F_fg, '%f\t',position_x(mm1));
                fprintf(F_fg, '%f\t',position_y(mm1));
                fprintf(F_fg, '%f\t',position_w(mm1));
                fprintf(F_fg, '%f\t',position_h(mm1));
                fprintf(F_fg, '%f\t',Focal_GIoU_Loss(mm1));
                fprintf(F_fg, '%f\n',final_error_focal_giou(mm1));				%save results for every regression cases
                
                % ---------------------------- Wiouv2 GIoU -------------------------- % 
                final_error_wiouv2_giou(mm1)=abs(pred_w2g(idx_anchor_count,1)-gt(gt_count,1))+abs(pred_w2g(idx_anchor_count,2)-gt(gt_count,2))+abs(pred_w2g(idx_anchor_count,3)-gt(gt_count,3))+abs(pred_w2g(idx_anchor_count,4)-gt(gt_count,4)); % 每个 perd 和 anchor 的 loss
                wiouv2_giou0(idx_anchor_count,l)=loss_w2g(idx_anchor_count,1)+loss_w2g(idx_anchor_count,2)+loss_w2g(idx_anchor_count,3)+loss_w2g(idx_anchor_count,4); % target * anchor 的个数
                Wiouv2_Loss(mm1)=wiouv2_giou0(idx_anchor_count,l);
                fprintf(F_w2g, '%d\t',mm1);
                fprintf(F_w2g, '%f\t',position_x(mm1));
                fprintf(F_w2g, '%f\t',position_y(mm1));
                fprintf(F_w2g, '%f\t',position_w(mm1));
                fprintf(F_w2g, '%f\t',position_h(mm1));
                fprintf(F_w2g, '%f\t',Wiouv2_Loss(mm1));
                fprintf(F_w2g, '%f\n',final_error_wiouv2_giou(mm1));				%save results for every regression cases
                
                % ---------------------------- Aiouv2 GIoU -------------------------- % 
                final_error_aiouv2_giou(mm1)=abs(pred_a2g(idx_anchor_count,1)-gt(gt_count,1))+abs(pred_a2g(idx_anchor_count,2)-gt(gt_count,2))+abs(pred_a2g(idx_anchor_count,3)-gt(gt_count,3))+abs(pred_a2g(idx_anchor_count,4)-gt(gt_count,4)); % 每个 perd 和 anchor 的 loss
                aiouv2_giou0(idx_anchor_count,l)=loss_a2g(idx_anchor_count,1)+loss_a2g(idx_anchor_count,2)+loss_a2g(idx_anchor_count,3)+loss_a2g(idx_anchor_count,4); % target * anchor 的个数
                Aiouv2_Loss(mm1)=aiouv2_giou0(idx_anchor_count,l);
                fprintf(F_a2g, '%d\t',mm1);
                fprintf(F_a2g, '%f\t',position_x(mm1));
                fprintf(F_a2g, '%f\t',position_y(mm1));
                fprintf(F_a2g, '%f\t',position_w(mm1));
                fprintf(F_a2g, '%f\t',position_h(mm1));
                fprintf(F_a2g, '%f\t',Aiouv2_Loss(mm1));
                fprintf(F_a2g, '%f\n',final_error_aiouv2_giou(mm1));				%save results for every regression cases
                
                % ---------------------------- Wiouv3 GIoU -------------------------- % 
                final_error_wiouv3_giou(mm1)=abs(pred_w3g(idx_anchor_count,1)-gt(gt_count,1))+abs(pred_w3g(idx_anchor_count,2)-gt(gt_count,2))+abs(pred_w3g(idx_anchor_count,3)-gt(gt_count,3))+abs(pred_w3g(idx_anchor_count,4)-gt(gt_count,4)); % 每个 perd 和 anchor 的 loss
                wiouv3_giou0(idx_anchor_count,l)=loss_w3g(idx_anchor_count,1)+loss_w3g(idx_anchor_count,2)+loss_w3g(idx_anchor_count,3)+loss_w3g(idx_anchor_count,4); % target * anchor 的个数
                Wiouv3_Loss(mm1)=wiouv3_giou0(idx_anchor_count,l);
                fprintf(F_w3g, '%d\t',mm1);
                fprintf(F_w3g, '%f\t',position_x(mm1));
                fprintf(F_w3g, '%f\t',position_y(mm1));
                fprintf(F_w3g, '%f\t',position_w(mm1));
                fprintf(F_w3g, '%f\t',position_h(mm1));
                fprintf(F_w3g, '%f\t',Wiouv3_Loss(mm1));
                fprintf(F_w3g, '%f\n',final_error_wiouv3_giou(mm1));				%save results for every regression cases
                
                % ---------------------------- Aiouv3 GIoU -------------------------- % 
                final_error_aiouv3_giou(mm1)=abs(pred_a3g(idx_anchor_count,1)-gt(gt_count,1))+abs(pred_a3g(idx_anchor_count,2)-gt(gt_count,2))+abs(pred_a3g(idx_anchor_count,3)-gt(gt_count,3))+abs(pred_a3g(idx_anchor_count,4)-gt(gt_count,4)); % 每个 perd 和 anchor 的 loss
                aiouv3_giou0(idx_anchor_count,l)=loss_a3g(idx_anchor_count,1)+loss_a3g(idx_anchor_count,2)+loss_a3g(idx_anchor_count,3)+loss_a3g(idx_anchor_count,4); % target * anchor 的个数
                Aiouv3_Loss(mm1)=aiouv3_giou0(idx_anchor_count,l);
                fprintf(F_a3g, '%d\t',mm1);
                fprintf(F_a3g, '%f\t',position_x(mm1));
                fprintf(F_a3g, '%f\t',position_y(mm1));
                fprintf(F_a3g, '%f\t',position_w(mm1));
                fprintf(F_a3g, '%f\t',position_h(mm1));
                fprintf(F_a3g, '%f\t',Aiouv3_Loss(mm1));
                fprintf(F_a3g, '%f\n',final_error_aiouv3_giou(mm1));				%save results for every regression cases
                
                % ---------------------------- Per GIoU -------------------------- % 
                final_error_per_giou(mm1)=abs(pred_pg(idx_anchor_count,1)-gt(gt_count,1))+abs(pred_pg(idx_anchor_count,2)-gt(gt_count,2))+abs(pred_pg(idx_anchor_count,3)-gt(gt_count,3))+abs(pred_pg(idx_anchor_count,4)-gt(gt_count,4)); % 每个 perd 和 anchor 的 loss
                per_giou0(idx_anchor_count,l)=loss_pg(idx_anchor_count,1)+loss_pg(idx_anchor_count,2)+loss_pg(idx_anchor_count,3)+loss_pg(idx_anchor_count,4); % target * anchor 的个数
                Per_Loss(mm1)=per_giou0(idx_anchor_count,l);
                fprintf(F_pg, '%d\t',mm1);
                fprintf(F_pg, '%f\t',position_x(mm1));
                fprintf(F_pg, '%f\t',position_y(mm1));
                fprintf(F_pg, '%f\t',position_w(mm1));
                fprintf(F_pg, '%f\t',position_h(mm1));
                fprintf(F_pg, '%f\t',Per_Loss(mm1));
                fprintf(F_pg, '%f\n',final_error_per_giou(mm1));				%save results for every regression cases
            end
        end
    end
    fclose(F_i);fclose(F_g);fclose(F_fg);fclose(F_w2g);fclose(F_a2g);fclose(F_w3g);fclose(F_a3g);fclose(F_pg);
    fprintf('完成存储，开始画图\n');
    % This is the total error of 1715k regression cases in each epoch.
    iii=i_x+i_y+i_w+i_h;
    ggg=g_x+g_y+g_w+g_h;
    fgfgfg=fg_x+fg_y+fg_w+fg_h;
    w2gw2g=w2g_x+w2g_y+w2g_w+w2g_h;
    a2ga2g = a2g_x+a2g_y+a2g_w+a2g_h;
    w3gw3g = w3g_x+w3g_y+w3g_w+w3g_h;
    a3ga3g = a3g_x+a3g_y+a3g_w+a3g_h;
    pgpgpg = pg_x+pg_y+pg_w+pg_h;
    
    % Save the loss process of border regression to Excel
    xlswrite(excle_iou,iii,'sheet1','B2:B201');
    xlswrite(excle_iou,ggg,'sheet1','C2:C201');
    xlswrite(excle_iou,fgfgfg,'sheet1','D2:D201');
    xlswrite(excle_iou,w2gw2g,'sheet1','E2:E201');
    xlswrite(excle_iou,a2ga2g,'sheet1','F2:F201');
    xlswrite(excle_iou,w3gw3g,'sheet1','G2:G201');
    xlswrite(excle_iou,a3ga3g,'sheet1','H2:H201');
    xlswrite(excle_iou,pgpgpg,'sheet1','I2:I201');
    
    maker_idx = 1:25:200;
    figure,plot(iii,'--','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
    plot(ggg,'-o','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
    plot(fgfgfg,'-diamond','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
    plot(w2gw2g,'-*','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
    plot(a2ga2g,'-+','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
    plot(w3gw3g,'-x','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
    plot(a3ga3g,'-pentagram','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
    plot(pgpgpg,'-^','MarkerIndices',maker_idx,'LineWidth',1.5),legend('IoU','GIoU','Focal GIoU','WIoUv2 GIoU','AIoUv2 GIoU','WIoUv3 GIoU','AIoUv3 GIoU','PersonalizationFM GIoU'),xlabel('Iteration'),ylabel('error'); 
    
    fxy_iou=zeros(5000,1,'double');
    fxy_giou=zeros(5000,1,'double');
    fxy_focal_giou=zeros(5000,1,'double');
    fxy_wiouv2_giou=zeros(5000,1,'double');
    fxy_aiouv2_giou=zeros(5000,1,'double');
    fxy_wiouv3_giou=zeros(5000,1,'double');
    fxy_aiouv3_giou=zeros(5000,1,'double');
    fxy_per_giou=zeros(5000,1,'double');

    for u=1:5000
        for v=1:343
            n=(u-1)*343+v;
            fxy_iou(u)=fxy_iou(u)+final_error_iou(n);
            fxy_giou(u)=fxy_giou(u)+final_error_giou(n);
            fxy_focal_giou(u)=fxy_focal_giou(u)+final_error_focal_giou(n);
            fxy_wiouv2_giou(u)=fxy_wiouv2_giou(u)+final_error_wiouv2_giou(n);
            fxy_aiouv2_giou(u)=fxy_aiouv2_giou(u)+final_error_aiouv2_giou(n);
            fxy_wiouv3_giou(u)=fxy_wiouv3_giou(u)+final_error_wiouv3_giou(n);
            fxy_aiouv3_giou(u)=fxy_aiouv3_giou(u)+final_error_aiouv3_giou(n);
            fxy_per_giou(u)=fxy_per_giou(u)+final_error_per_giou(n);
        end
    end

    %plot point cloud map of regression error
    tri = delaunay(xx,yy);
    figure,trimesh(tri,xx,yy,fxy_iou),zlabel('total final error'); 
    figure,trimesh(tri,xx,yy,fxy_giou),zlabel('total final error'); 
    figure,trimesh(tri,xx,yy,fxy_focal_giou),zlabel('total final error');  
    figure,trimesh(tri,xx,yy,fxy_wiouv2_giou),zlabel('total final error');
    figure,trimesh(tri,xx,yy,fxy_aiouv2_giou),zlabel('total final error');
    figure,trimesh(tri,xx,yy,fxy_wiouv3_giou),zlabel('total final error');     
    figure,trimesh(tri,xx,yy,fxy_aiouv3_giou),zlabel('total final error');  
    figure,trimesh(tri,xx,yy,fxy_per_giou),zlabel('total final error');  

    F11=fopen('E:\matlab_project\simulation experiments\results\iou_reg.txt','a');
    F22=fopen('E:\matlab_project\simulation experiments\results\giou_reg.txt','a');
    F33=fopen('E:\matlab_project\simulation experiments\results\focal_giou_reg.txt','a');
    F44=fopen('E:\matlab_project\simulation experiments\results\wiouv2_giou_reg.txt','a');
    F55=fopen('E:\matlab_project\simulation experiments\results\aiouv2_giou_reg.txt','a');
    F66=fopen('E:\matlab_project\simulation experiments\results\wiouv3_giou_reg.txt','a');
    F77=fopen('E:\matlab_project\simulation experiments\results\aiouv3_giou_reg.txt','a');
    F88=fopen('E:\matlab_project\simulation experiments\results\per_giou_reg.txt','a');
    
    for v=1:epoch_num
        fprintf(F11, '%d\t',v);
        fprintf(F11, '%f\t',i_x(v));
        fprintf(F11, '%f\t',i_y(v));
        fprintf(F11, '%f\t',i_w(v));
        fprintf(F11, '%f\t',i_h(v));
        fprintf(F11, '%f\n',iii(v));
        fprintf(F22, '%d\t',v);
        fprintf(F22, '%f\t',g_x(v));
        fprintf(F22, '%f\t',g_y(v));
        fprintf(F22, '%f\t',g_w(v));
        fprintf(F22, '%f\t',g_h(v));
        fprintf(F22, '%f\n',ggg(v));
        fprintf(F33, '%d\t',v);
        fprintf(F33, '%f\t',fg_x(v));
        fprintf(F33, '%f\t',fg_y(v));
        fprintf(F33, '%f\t',fg_w(v));
        fprintf(F33, '%f\t',fg_h(v));
        fprintf(F33, '%f\n',fgfgfg(v));
        fprintf(F44, '%d\t',v);
        fprintf(F44, '%f\t',w2g_x(v));
        fprintf(F44, '%f\t',w2g_y(v));
        fprintf(F44, '%f\t',w2g_w(v));
        fprintf(F44, '%f\t',w2g_h(v));
        fprintf(F44, '%f\n',w2gw2g(v));
        fprintf(F55, '%d\t',v);
        fprintf(F55, '%f\t',a2g_x(v));
        fprintf(F55, '%f\t',a2g_y(v));
        fprintf(F55, '%f\t',a2g_w(v));
        fprintf(F55, '%f\t',a2g_h(v));
        fprintf(F55, '%f\n',a2ga2g(v));
        fprintf(F66, '%d\t',v);
        fprintf(F66, '%f\t',w3g_x(v));
        fprintf(F66, '%f\t',w3g_y(v));
        fprintf(F66, '%f\t',w3g_w(v));
        fprintf(F66, '%f\t',w3g_h(v));
        fprintf(F66, '%f\n',w3gw3g(v));
        fprintf(F77, '%d\t',v);
        fprintf(F77, '%f\t',a3g_x(v));
        fprintf(F77, '%f\t',a3g_y(v));
        fprintf(F77, '%f\t',a3g_w(v));
        fprintf(F77, '%f\t',a3g_h(v));
        fprintf(F77, '%f\n',a3ga3g(v));
        fprintf(F88, '%d\t',v);
        fprintf(F88, '%f\t',pg_x(v));
        fprintf(F88, '%f\t',pg_y(v));
        fprintf(F88, '%f\t',pg_w(v));
        fprintf(F88, '%f\t',pg_h(v));
        fprintf(F88, '%f\n',pgpgpg(v));
    end
    fclose(F11);
    fclose(F22);
    fclose(F33);
    fclose(F44);
    fclose(F55);
    fclose(F66);
    fclose(F77);    
    fclose(F88);    
    fprintf('祝贺，完成所有内容\n');
end


%--------------------------the following is to redraw from previous results----------------------------%
if is_regresion==0
    fprintf('Processing regresion_process.m ...\n');
    [i1,i2,i3,i4,i5,i6,i7]=textread('E:\matlab_project\simulation experiments\results\giou-1715k.txt','%d%f%f%f%f%f%f');
    [g1,g2,g3,g4,g5,g6,g7]=textread('E:\matlab_project\simulation experiments\results\giou-1715k.txt','%d%f%f%f%f%f%f');
    [fg1,fg2,fg3,fg4,fg5,fg6,fg7]=textread('E:\matlab_project\simulation experiments\results\focal_giou-1715k.txt','%d%f%f%f%f%f%f');
    [w2g1,w2g2,w2g3,w2g4,w2g5,w2g6,w2g7]=textread('E:\matlab_project\simulation experiments\results\wiouv2_giou-1715k.txt','%d%f%f%f%f%f%f');
    [a2g1,a2g2,a2g3,a2g4,a2g5,a2g6,a2g7]=textread('E:\matlab_project\simulation experiments\results\aiouv2_giou-1715k.txt','%d%f%f%f%f%f%f');
    [w3g1,w3g2,w3g3,w3g4,w3g5,w3g6,w3g7]=textread('E:\matlab_project\simulation experiments\results\wiouv3_giou-1715k.txt','%d%f%f%f%f%f%f');
    [a3g1,a3g2,a3g3,a3g4,a3g5,a3g6,a3g7]=textread('E:\matlab_project\simulation experiments\results\aiouv3_giou-1715k.txt','%d%f%f%f%f%f%f');
    [pg1,pg2,pg3,pg4,pg5,pg6,pg7]=textread('E:\matlab_project\simulation experiments\results\per_giou-1715k.txt','%d%f%f%f%f%f%f');
    
    fxy_iou=zeros(5000,1,'double');
    fxy_giou=zeros(5000,1,'double');
    fxy_focal_giou=zeros(5000,1,'double');
    fxy_wiouv2_giou=zeros(5000,1,'double');
    fxy_aiouv2_giou=zeros(5000,1,'double');
    fxy_wiouv3_giou=zeros(5000,1,'double');
    fxy_aiouv3_giou=zeros(5000,1,'double');
    fxy_per_giou=zeros(5000,1,'double');

    for u=1:5000
        xx(u)=i2(u*343);
        yy(u)=i3(u*343);
        for v=1:343
            n=(u-1)*343+v;
            fxy_iou(u)=fxy_giou(u)+g7(n);
            fxy_giou(u)=fxy_giou(u)+g7(n);
            fxy_focal_giou(u)=fxy_focal_giou(u)+fg7(n);
            fxy_wiouv2_giou(u)=fxy_wiouv2_giou(u)+w2g7(n);
            fxy_aiouv2_giou(u)=fxy_aiouv2_giou(u)+a2g7(n);
            fxy_wiouv3_giou(u)=fxy_wiouv3_giou(u)+w3g7(n);
            fxy_aiouv3_giou(u)=fxy_aiouv3_giou(u)+a3g7(n);
            fxy_per_giou(u)=fxy_per_giou(u)+pg7(n);
        end
    end
    %plot point cloud map of regression error
    tri = delaunay(xx,yy);
    figure,trimesh(tri,xx,yy,fxy_iou),zlabel('total final error'); 
    figure,trimesh(tri,xx,yy,fxy_giou),zlabel('total final error'); 
    figure,trimesh(tri,xx,yy,fxy_focal_giou),zlabel('total final error');  
    figure,trimesh(tri,xx,yy,fxy_wiouv2_giou),zlabel('total final error');
    figure,trimesh(tri,xx,yy,fxy_aiouv2_giou),zlabel('total final error');
    figure,trimesh(tri,xx,yy,fxy_wiouv3_giou),zlabel('total final error');     
    figure,trimesh(tri,xx,yy,fxy_aiouv3_giou),zlabel('total final error');  
    figure,trimesh(tri,xx,yy,fxy_per_giou),zlabel('total final error');  
    
    
    excle_iou = 'E:\matlab_project\simulation experiments\results\iou-1715k.xls';
    iii = xlsread(excle_iou,'sheet1','B2:B201');
    ggg = xlsread(excle_iou,'sheet1','C2:C201');
    fgfgfg = xlsread(excle_iou,'sheet1','D2:D201');
    w2gw2g = xlsread(excle_iou,'sheet1','E2:E201');
    a2ga2g = xlsread(excle_iou,'sheet1','F2:F201');
    w3gw3g = xlsread(excle_iou,'sheet1','G2:G201');
    a3ga3g = xlsread(excle_iou,'sheet1','H2:H201');
    pgpgpg = xlsread(excle_iou,'sheet1','I2:I201');

    maker_idx = 1:25:200;
    figure,plot(iii,'--','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
    plot(ggg,'-o','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
    plot(fgfgfg,'-diamond','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
%     plot(w2gw2g,'-*','MarkerIndices',maker_idx,'LineWidth',1.5);hold on  'WIoUv2 GIoU','AIoUv2 GIoU',
%     plot(a2ga2g,'-+','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
    plot(w3gw3g,'-x','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
    plot(a3ga3g,'-pentagram','MarkerIndices',maker_idx,'LineWidth',1.5);hold on
    plot(pgpgpg,'-^','MarkerIndices',maker_idx,'LineWidth',1.5),legend('IoU','GIoU','Focal GIoU','WIoUv3 GIoU','AIoUv3 GIoU','PersonalizationFM GIoU'),xlabel('Iteration'),ylabel('error'); 
    
end

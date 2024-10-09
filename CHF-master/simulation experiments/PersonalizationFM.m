% Calculate reweighted_value
function w=PersonalizationFM(IO,mean_iou_pg,data_quality,train_progress)
left_move_progress=max(0.4, min(1.5, abs((0.5+data_quality)*train_progress-1.5)));
mu=(1/(1-0.8*(1-mean_iou_pg)*(1-data_quality*power(train_progress,3))))*left_move_progress;
beta=(1-IO)/(1-mean_iou_pg)+((1.5-data_quality)*mean_iou_pg*(1-(0.9*train_progress*train_progress)));
delta=max(1.5*mean_iou_pg*mean_iou_pg+mean_iou_pg+data_quality,1.5);
alpha=power(0.5/delta,1/(0.5-delta));
w=(beta*mu)/((mean_iou_pg)*delta*power(alpha, beta*mu-delta));
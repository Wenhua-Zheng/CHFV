% Calculate reweighted_value
function w=aiouv3(IO,mean_iou_a3g)
mu=1/(1-0.8*(1-mean_iou_a3g));
beta=(1-IO)/(1-mean_iou_a3g);
delta=1.5*power(mean_iou_a3g,2)+mean_iou_a3g+0.9;
alpha=power(0.5/delta,1/(0.5-delta));
w=(beta*mu)/((mean_iou_a3g+0.2)*delta*power(alpha, beta*mu-delta));
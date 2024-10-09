% Calculate reweighted_value
function w=wiouv3(IO,mean_iou_w3g)
beta=(1-IO)/(1-mean_iou_w3g);
alpha=1.9;
delta=3;
w=beta/(delta*power(alpha, beta-delta));
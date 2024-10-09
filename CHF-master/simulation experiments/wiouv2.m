% Calculate reweighted_value
function w=wiouv2(IO,mean_iou_w2g)
w=power((1-IO)/(1-mean_iou_w2g), 0.5);
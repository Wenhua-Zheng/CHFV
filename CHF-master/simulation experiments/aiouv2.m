% Calculate reweighted_value
function w=aiouv2(IO,mean_iou_a2g)
w=power((IO)/(mean_iou_a2g), 0.4);
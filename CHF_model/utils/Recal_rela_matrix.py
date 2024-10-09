import torch
import torchvision
import time
from utils.general import xywh2xyxy

def pre_non_max_suppression(prediction, conf_thres=0.25, iou_thres=0.45, classes=None, agnostic=False,
                            multi_label=False,
                            labels=()):
    """Runs Non-Maximum Suppression (NMS) on inference results

    Returns:
         list of detections, on (n,6) tensor per image [xyxy, conf, cls]
    """

    nc = prediction.shape[2] - 5  # number of classes
    xc = prediction[..., 4] > conf_thres  # candidates

    # Settings
    min_wh, max_wh = 2, 4096  # (pixels) minimum and maximum box width and height
    max_det = 300  # maximum number of detections per image
    max_nms = 3000  # maximum number of boxes into torchvision.ops.nms()
    # max_det = 200  # maximum number of detections per image
    # max_nms = 400  # maximum number of boxes into torchvision.ops.nms()
    time_limit = 30.0  # seconds to quit after
    redundant = True  # require redundant detections
    multi_label &= nc > 1  # multiple labels per box (adds 0.5ms/img)
    merge = False  # use merge-NMS

    t = time.time()
    # output = [torch.zeros((0, 6), device=prediction.device)] * prediction.shape[0]
    output_all_classes = [torch.zeros((0, prediction.shape[2] + 1), device=prediction.device)] * prediction.shape[0]
    # output_all_classes = torch.zeros((prediction.shape[0], 0, prediction.shape[2] + 1), device=prediction.device)
    for xi, x in enumerate(prediction):  # image index, image inference
        # Apply constraints
        # x[((x[..., 2:4] < min_wh) | (x[..., 2:4] > max_wh)).any(1), 4] = 0  # width-height
        x = x[xc[xi]]  # confidence

        # Cat apriori labels if autolabelling
        if labels and len(labels[xi]):
            l = labels[xi]
            v = torch.zeros((len(l), nc + 5), device=x.device)
            v[:, :4] = l[:, 1:5]  # box
            v[:, 4] = 1.0  # conf
            v[range(len(l)), l[:, 0].long() + 5] = 1.0  # cls
            x = torch.cat((x, v), 0)

        # If none remain process next image
        if not x.shape[0]:
            continue

        # Compute conf
        if nc == 1:
            x[:, 5:] = x[:, 4:5]  # for models with one class, cls_loss is 0 and cls_conf is always 0.5,
            # so there is no need to multiplicate.
        else:
            x[:, 5:] *= x[:, 4:5]  # conf = obj_conf * cls_conf

        # 这里可以修改，保留一份原始x，要保留的是*conf还是没有未知啊。乘过的，对于低置信度（不确定）目标则加权效果更好，缺点呢？。
        whole_x = x
        # Box (center x, center y, width, height) to (x1, y1, x2, y2)
        box = xywh2xyxy(x[:, :4])

        # Detections matrix nx6 (xyxy, conf, cls)  得到类别概率大于 conf_thres 的框的序号位置
        if multi_label:
            i, j = (x[:, 5:] > conf_thres).nonzero(as_tuple=False).T
            x = torch.cat((box[i], x[i, j + 5, None], j[:, None].float()), 1)
        else:  # best class only
            # 这里的conf应该得再整整，不然whole_x比x数量多
            conf, j = x[:, 5:].max(1, keepdim=True)
            # x = torch.cat((box, conf, j.float()), 1)[conf.view(-1) > conf_thres]  # 重新cat每个检测框
            x = torch.cat((box, x[:, 4:5], j.float()), 1)

            # Filter by class
        if classes is not None:
            x = x[(x[:, 5:6] == torch.tensor(classes, device=x.device)).any(1)]

        # Apply finite constraint
        # if not torch.isfinite(x).all():
        #     x = x[torch.isfinite(x).all(1)]

        # Check shape
        n = x.shape[0]  # number of boxes
        if not n:  # no boxes
            continue
        elif n > max_nms:  # excess boxes
            x = x[x[:, 4].argsort(descending=True)[:max_nms]]  # sort by confidence

        # Batched NMS  将每个类的边框乘以一个数，异类不会被nms
        c = x[:, 5:6] * (0 if agnostic else max_wh)  # classes
        boxes, scores = x[:, :4] + c, x[:, 4]  # boxes (offset by class), scores
        i = torchvision.ops.nms(boxes, scores, iou_thres)  # NMS
        if i.shape[0] > max_det:  # limit detections 只提取300个 boxes
            i = i[:max_det]

        # # x[:, :4] = real_boxes
        # output[xi] = x[i]
        # (xi, box, conf, class, class_conf)
        output_all_classes[xi] = torch.cat((whole_x[i, 0:5], x[i, 5:], whole_x[i, 5:]), 1)
        if (time.time() - t) > time_limit:
            print(f'WARNING: NMS time limit {time_limit}s exceeded')
            break  # time limit exceeded
    t_output_all_classes = torch.zeros(
        (len(output_all_classes), output_all_classes[0].shape[0], output_all_classes[0].shape[1]),
        device=prediction.device)
    for idx, elem_output in enumerate(output_all_classes):
        t_output_all_classes[idx, :, :] = output_all_classes[idx]
    # t_output_all_classes[:, :, 0:4] = xyxy2xywh(t_output_all_classes[:, :, 0:4])
    return t_output_all_classes


# 获取每位药品的相关系数矩阵,以及每位药品的位置
def get_rela_mat(all_pers: dict, all_medication, device):
    # 获取药品的列表
    data_list = list(all_pers.values())

    # 定义相关系数矩阵
    med_len = len(all_medication)
    relation_mat = torch.zeros((med_len, med_len), dtype=torch.float, device=device)
    # relation_mat =[[0]*med_len for i in range(med_len)]
    # 建立每位药品在矩阵的索引序列
    med_seq = {k: v for v, k in enumerate(all_medication)}
    # 计算每个处方的药品间的出现次数（关系强弱）
    for elem_data in data_list:
        for idx, elem in enumerate(elem_data):
            for idy in range(idx + 1, len(elem_data)):
                relation_mat[med_seq[elem]][med_seq[elem_data[idy]]] += 5  # 横坐标系数增加
                relation_mat[med_seq[elem_data[idy]]][med_seq[elem]] += 5  # 纵坐标系数增加

    return torch.softmax(relation_mat, dim=1), med_seq  # 横向归一化，横向作为相关性权重


def recal_class_conf(pred: list, names: list, rela_mat: torch, med_seq: dict, weight: int = 0.4):
    new_pred = torch.zeros((pred.shape[0], pred.shape[1], pred.shape[2]-1), device=pred[0].device)
    for idx, elem_pred in enumerate(pred):
        # list -> dict{name:i}
        # names = {k: v for v, k in enumerate(names)}
        cla_and_num = [(names[int(c)], int((elem_pred[:, 5] == c).sum())) for c in elem_pred[:, 5].unique()]  # 这张图片预测的种类和数量
        # 这里可加入筛查，去除少和小的目标，可以把置信度也引入，得到新的pred



        cla_seq = torch.zeros((len(med_seq)), device=elem_pred.device)
        # 1，0 序列标注出所有出现的药
        for cm in cla_and_num:
            cla_seq[med_seq[cm[0]]] = 1.0
            # cla_seq = [med_seq[cm[0]] for cm in cla_and_num]  # 这张图片预测的种类和数量
        # process_class_conf
        new_class_conf = (1-weight)*elem_pred[:, 6:] + (weight * torch.sum((rela_mat * cla_seq), dim=1)).expand(elem_pred.shape[0], len(names))
        # [number, box, conf, calss_conf]
        new_pred[idx, :, :] = torch.cat((elem_pred[:, 0:5], new_class_conf), dim=1)
    return new_pred

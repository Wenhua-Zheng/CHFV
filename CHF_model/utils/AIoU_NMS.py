from typing import Tuple

from torch import Tensor
import torch


def box_area(boxes: Tensor) -> Tensor:
    """
    Computes the area of a set of bounding boxes, which are specified by its
    (x1, y1, x2, y2) coordinates.
    Arguments:
        boxes (Tensor[N, 4]): boxes for which the area will be computed. They
            are expected to be in (x1, y1, x2, y2) format
    Returns:
        area (Tensor[N]): area for each box
    """
    return (boxes[:, 2] - boxes[:, 0]) * (boxes[:, 3] - boxes[:, 1])


def box_iou(boxes1: Tensor, boxes2: Tensor) -> Tensor:
    """
    Return intersection-over-union (Jaccard index) of boxes.
    Both sets of boxes are expected to be in (x1, y1, x2, y2) format.
    Arguments:
        boxes1 (Tensor[N, 4])
        boxes2 (Tensor[M, 4])
    Returns:
        iou (Tensor[N, M]): the NxM matrix containing the pairwise IoU values for every element in boxes1 and boxes2
    """
    area1 = box_area(boxes1)  # 每个框的面积 (N,)
    area2 = box_area(boxes2)  # (M,)

    lt = torch.max(boxes1[:, None, :2], boxes2[:, :2])  # [N,M,2] # N中一个和M个比较； 所以由N，M 个
    rb = torch.min(boxes1[:, None, 2:], boxes2[:, 2:])  # [N,M,2]

    wh = (rb - lt).clamp(min=0)  # [N,M,2]  #小于0的为0  clamp 钳；夹钳；
    inter = wh[:, :, 0] * wh[:, :, 1]  # [N,M]

    iou = inter / (area1[:, None] + area2 - inter)
    return iou  # NxM， boxes1中每个框和boxes2中每个框的IoU值；


def nms(boxes: Tensor, scores: Tensor, iou_threshold: float):
    """
    :param boxes: [N, 4]， 此处传进来的框，是经过筛选（NMS之前选取过得分TopK）之后， 在传入之前处理好的；
    :param scores: [N]
    :param iou_threshold: 0.7
    :return:
    """
    keep = []  # 最终保留的结果， 在boxes中对应的索引；
    idxs = scores.argsort()  # 值从小到大的 索引
    while idxs.numel() > 0:  # 循环直到null； numel()： 数组元素个数
        # 得分最大框对应的索引, 以及对应的坐标
        max_score_index = idxs[-1]
        max_score_box = boxes[max_score_index][None, :]  # [1, 4]
        keep.append(max_score_index)
        if idxs.size(0) == 1:  # 就剩余一个框了；
            break
        idxs = idxs[:-1]  # 将得分最大框 从索引中删除； 剩余索引对应的框 和 得分最大框 计算IoU；
        other_boxes = boxes[idxs]  # [?, 4]
        ious = box_iou(max_score_box, other_boxes)  # 一个框和其余框比较 1XM
        idxs = idxs[ious[0] <= iou_threshold]

    keep = idxs.new(keep)  # Tensor
    return keep


def center_ratio(boxes1: Tensor, boxes2: Tensor) -> Tensor:
    # 框的高和宽的一半
    WH1 = (boxes1[:, 2:] - boxes1[:, :2]) / 2
    WH2 = (boxes2[:, 2:] - boxes2[:, :2]) / 2
    center1 = boxes1[:, :2] + WH1[:, :]
    center2 = boxes2[:, :2] + WH2[:, :]

    dis_xy = torch.abs(center2[:, :] - center1[:, :])

    # 获取中心距离的占比(比到另一个框)
    ratio_len = dis_xy / WH1
    # 框之间的宽高比例,越小说明差距越大，1则说明一摸一样
    v_temp = (WH1[:, 0] / WH1[:, 1]) / (WH2[:, 0] / WH2[:, 1])
    v = torch.tensor([1 - (1 / i) if i > 1 else 1 - i for i in v_temp], device=v_temp.device)

    return torch.clamp(ratio_len, 0, 1), v


def nom_score(ious: Tensor, max_score: Tensor, other_score: Tensor, truncation_valeue: float = 0.1) -> Tensor:
    if max_score < truncation_valeue:
        return ious
    scores_ratio = other_score / max_score
    sco_penalty = -1 * torch.pow(1.4, scores_ratio) + 2.15
    return ious * sco_penalty


def boxes_fusion(ious, max_score_real_box, other_real_boxes, max_score, other_score, BF_thres=0.95):
    score_ratio = max_score / (max_score + other_score)
    # [max_score_real_box=(score_ratio[id]*max_score_real_box)+((1-score_ratio[id])*other_real_boxes[id]) for id, i in enumerate(ious) if i > BF_thres]
    for id, i in enumerate(ious[0]):
        if i > BF_thres:
            max_score_real_box = (score_ratio[id] * max_score_real_box) + ((1 - score_ratio[id]) * other_real_boxes[id])
    return max_score_real_box


def aiou_nms(boxes: Tensor, scores: Tensor, iou_threshold: float, real_boxes,
             aiounms_v1=False, aiounms_v2=False, aiounms_v3=False, aiounms_v4=False, BF=True):
    """
    :param boxes: [N, 4]， 此处传进来的框，是经过筛选（NMS之前选取过得分TopK）之后， 在传入之前处理好的；
    :param scores: [N]
    :param iou_threshold: 0.7
    :return:
    """
    keep = []  # 最终保留的结果， 在boxes中对应的索引；
    idxs = scores.argsort()  # 值从小到大的 索引
    while idxs.numel() > 0:  # 循环直到null； numel()： 数组元素个数
        # 得分最大框对应的索引, 以及对应的坐标
        max_score_index = idxs[-1]
        max_score_box = boxes[max_score_index][None, :]  # [1, 4]
        max_score_real_box = real_boxes[max_score_index][None, :]  # [1, 4]  # -------------------------------------
        max_score = scores[max_score_index]
        keep.append(max_score_index)
        if idxs.size(0) == 1:  # 就剩余一个框了
            break
        idxs = idxs[:-1]  # 将得分最大框 从索引中删除； 剩余索引对应的框 和 得分最大框 计算IoU
        other_boxes = boxes[idxs]  # [?, 4]
        other_real_boxes = real_boxes[idxs]  # [?, 4]  # -------------------------------------
        other_score = scores[idxs]

        ious = box_iou(max_score_box, other_boxes)  # 一个框和其余框比较 1XM
        if BF:
            # 前端--BF 框融合 --------------------------------
            BF_boxes = boxes_fusion(ious, max_score_real_box, other_real_boxes, max_score, other_score, BF_thres=0.85)
            real_boxes[max_score_index][None, :] = BF_boxes
            # max_score_real_box = BF_boxes
            # idxs = idxs[ious[0] <= 0.9]
            #
            # if idxs.size(0) < 2:  # 就剩余一个框了
            #     break
            # other_boxes = boxes[idxs]  # [?, 4]
            # other_real_boxes = real_boxes[idxs]  # [?, 4]  # -------------------------------------
            # other_score = scores[idxs]
            # ious = box_iou(max_score_box, other_boxes)  # 一个框和其余框比较 1XM
            # # 前端--BF 框融合 end --------------------------------

        # aiou-nms
        if aiounms_v1:
            distance_ratio, wh_ratio = center_ratio(max_score_box, other_boxes)
            disx_penalty = -1 * torch.pow(1.7, distance_ratio[:, 0]) + 2.09
            disy_penalty = -1 * torch.pow(1.7, distance_ratio[:, 1]) + 2.09
            ious = ious * disx_penalty * disy_penalty
        if aiounms_v2:
            distance_ratio, wh_ratio = center_ratio(max_score_box, other_boxes)
            wh_penalty = -1 * torch.pow(1.8, wh_ratio) + 2.10
            ious = ious * wh_penalty
        if aiounms_v3:
            ious = nom_score(ious, max_score, other_score)
        if aiounms_v4:
            distance_ratio, wh_ratio = center_ratio(max_score_box, other_boxes)
            sco_ratio = nom_score(max_score, other_score)
            disx_penalty = -1 * torch.pow(1.7, distance_ratio[:, 0]) + 2.09
            disy_penalty = -1 * torch.pow(1.7, distance_ratio[:, 1]) + 2.09
            wh_penalty = -1 * torch.pow(1.8, wh_ratio) + 2.10
            sco_penalty = -1 * torch.pow(1.4, sco_ratio) + 2.15
            ious = ious * disx_penalty * disy_penalty * wh_penalty * sco_penalty

        # if BF:
        #     # 前端--BF 框融合 --------------------------------
        #     BF_boxes = boxes_fusion(ious, max_score_real_box, other_real_boxes, max_score, other_score, BF_thres=0.85)
        #     real_boxes[max_score_index][None, :] = BF_boxes
        idxs = idxs[ious[0] <= iou_threshold]
    keep = idxs.new(keep)  # Tensor
    return keep, real_boxes

# CHFV Model: Chinese herbal formula verification model

By [Wenhua Zheng](https://orcid.org/0009-0007-1002-809),   [Jianqiang Du](https://orcid.org/0000-0001-5584-9181), [Yanchen Zhu](https://orcid.org/0000-0002-6123-6880), Yang Yuan, Zhikai Zhang, Shaokun Lan

This repository is an official implementation of the paper [CHFV Model: Chinese herbal formula verification model](https://github.com/Wenhua-Zheng/CHFV).



## Comparative experiment

We designed the CHFV model to verify Chinese herbal formula images. However, the challenge of large intra-class variance and small inter-class variance among Chinese herbal medicines complicates their recognition. To address the difficulty in distinguishing between different Chinese herbal medicines within these formulas, we propose a priori knowledge matrix, which significantly enhances the model's performance. On the CHF44 dataset, the model's accuracy shows substantial improvement after the introduction of the confidence reconstruction algorithm. Furthermore, the increase in computation time on the RTX6000 is minimal.

| Model | Other | ACC          | FPS  |
| ----- | ----- | ------------ | ---- |
| CHF   | None  | 85.25        | 1.83 |
| CHF   | Recon | 89.75(+4.50) | 1.73 |

Use pretrained cm54.pt to predict CHF44 Dataset:[Click here to download cm54.pt and CHF44 Dataset](https://github.com/Wenhua-Zheng/CHFV/releases)

``` shell
python CHF_model/main.py --language English --conf_reweight True --weights cm54.pt --source inference/prescriptions
```


## Simulation experiments

To compare the capabilities of various focusing mechanisms, we designed simulation experiments based on the method proposed by Zheng et al. to analyze the loss space. We simulated all possible scenarios encountered in practice, including variations in bounding box distance, scale, and aspect ratio. A total of 200 regression tests were conducted across 7 scenarios (IoU Loss, GIoU Loss, Focal GIoU Loss, W2 GIoU Loss, A2 GIoU Loss, W3 GIoU Loss, A3 GIoU Loss, Personalization GIoU Loss). 

Regress all possible cases.

```matlab
matlab simulation experiments/real_1715k.m --is_regresion = 1
```

use the previous results directly to draw a graph.

```matlab
matlab simulation experiments/real_1715k.m --is_regresion = 0
```

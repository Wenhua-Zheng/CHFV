from PIL import Image, ImageFont, ImageDraw
import cv2
import numpy as np
import torch
import json
# Enter text on the image
def plot_words(img, text, textSize, pos, color):
    imgPIL = Image.fromarray(cv2.cvtColor(img, cv2.COLOR_BGR2RGB))
    drawPIL = ImageDraw.Draw(imgPIL)
    fontText = ImageFont.truetype("font/simsun.ttc", textSize, encoding="utf-8")
    drawPIL.text(pos, text, color, font=fontText)

    return cv2.cvtColor(np.asarray(imgPIL), cv2.COLOR_RGB2BGR)


# Create a specified color background image
def visualization_image(save_path, pers_img, pers_name: str, pers_list: list, cv_list: list, language: str):
    bg_img = np.zeros((900, 1680, 3), np.uint8)

    # background
    bg_img[:, :] = (213, 232, 253)
    # bg_img[:, :] = (196, 228, 255)
    # Formula decoction module
    bg_img[80:120, 840:1100] = (174, 179, 254)
    bg_img[120:880, 840:1100] = (222, 241, 244)
    cv2.rectangle(bg_img, (840, 80), (1100, 880), (154, 178, 130), thickness=2, lineType=cv2.LINE_AA)
    cv2.rectangle(bg_img, (840, 80), (1100, 120), (154, 178, 130), thickness=2, lineType=cv2.LINE_AA)
    # Identify the herbal medicine module
    bg_img[80:120, 1120:1380] = (174, 179, 254)
    bg_img[120:880, 1120:1380] = (222, 241, 244)
    cv2.rectangle(bg_img, (1120, 80), (1380, 880), (154, 178, 130), thickness=2, lineType=cv2.LINE_AA)
    cv2.rectangle(bg_img, (1120, 80), (1380, 120), (154, 178, 130), thickness=2, lineType=cv2.LINE_AA)
    # Abnormal herbal medicine module
    bg_img[80:120, 1400:1660] = (174, 179, 254)
    bg_img[120:880, 1400:1660] = (222, 241, 244)
    cv2.rectangle(bg_img, (1400, 80), (1660, 880), (154, 178, 130), thickness=2, lineType=cv2.LINE_AA)
    cv2.rectangle(bg_img, (1400, 80), (1660, 120), (154, 178, 130), thickness=2, lineType=cv2.LINE_AA)

    bg_img[80:880, 20:820] = pers_img  # Put the detection result image into the interface

    # 可视化固定文字模块
    if language is 'Chinese':
        imgPutText = plot_words(bg_img, text="方剂名称：", textSize=30, pos=(20, 30), color=(0, 0, 0))
        imgPutText = plot_words(imgPutText, text="匹配结果：", textSize=30, pos=(840, 30), color=(0, 0, 0))
        imgPutText = plot_words(imgPutText, text="方剂饮片", textSize=25, pos=(920, 90), color=(0, 0, 0))
        imgPutText = plot_words(imgPutText, text="识别饮片", textSize=25, pos=(1200, 90), color=(0, 0, 0))
        imgPutText = plot_words(imgPutText, text="异常饮片", textSize=25, pos=(1480, 90), color=(0, 0, 0))
    else:
        imgPutText = plot_words(bg_img, text="Perscription Name:", textSize=30, pos=(20, 30), color=(0, 0, 0))
        imgPutText = plot_words(imgPutText, text="Matching Results:", textSize=30, pos=(840, 30), color=(0, 0, 0))
        imgPutText = plot_words(imgPutText, text="Perscription", textSize=25, pos=(900, 90), color=(0, 0, 0))
        imgPutText = plot_words(imgPutText, text="Recognized", textSize=25, pos=(1180, 90), color=(0, 0, 0))
        imgPutText = plot_words(imgPutText, text="Wrong", textSize=25, pos=(1500, 90), color=(0, 0, 0))


    # Visualization of recognition results
    cv_list = set(cv_list)
    if (set(pers_list) == cv_list):
        if language is 'Chinese':
            imgPutText = plot_words(imgPutText, text="正确", textSize=30, pos=(990, 30), color=(0, 0, 0))
        else:
            imgPutText = plot_words(imgPutText, text="Correct", textSize=30, pos=(1120, 30), color=(0, 0, 0))
    else:
        if language is 'Chinese':
            imgPutText = plot_words(imgPutText, text="错误——请检测是否出现异常！！！", textSize=30, pos=(990, 30),
                                color=(205, 0, 0))
        else:
            imgPutText = plot_words(imgPutText, text="Error, please verify!!!", textSize=30, pos=(1120, 30),
                                    color=(205, 0, 0))

    dif_list = list(cv_list.union(set(pers_list)) - cv_list.intersection(set(pers_list)))
    s_pers = ''
    s_cv = ''
    s_dif = ''
    pers_list.sort()
    cv_list = list(cv_list)
    cv_list.sort()
    dif_list.sort()
    for i in pers_list:
        s_pers = s_pers + i + '\n'
    for i in cv_list:
        s_cv = s_cv + i + '\n'
    for i in dif_list:
        s_dif = s_dif + i + '\n'

    if language is 'Chinese':
        imgPutText = plot_words(imgPutText, text=pers_name, textSize=30, pos=(170, 30), color=(0, 0, 0))
    else:
        imgPutText = plot_words(imgPutText, text=pers_name, textSize=30, pos=(300, 30), color=(0, 0, 0))
    imgPutText = plot_words(imgPutText, text=s_pers, textSize=20, pos=(850, 130), color=(0, 0, 0))
    imgPutText = plot_words(imgPutText, text=s_cv, textSize=20, pos=(1130, 130), color=(0, 0, 0))
    imgPutText = plot_words(imgPutText, text=s_dif, textSize=20, pos=(1410, 130), color=(205, 0, 0))

    cv2.imwrite(save_path, imgPutText)
    # cv2.imshow('test', imgPutText)
    # cv2.waitKey()

def load_txt_dict(path):
    with open(path, "r", encoding='UTF-8-sig') as file:
        data = json.loads(file.read())
        # print(data)
        file.close()
    return data

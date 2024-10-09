chinese_collect = {'乌梅': 1, '粳米': 2, '知母': 7, '生姜': 8, '松子仁': 1, '五味子': 6, '枳实': 2, '白芍': 5,
                   '黄连': 3,
                   '麦冬': 4, '石膏': 3, '茯苓': 13, '栀子': 3, '紫苏叶': 4, '款冬花': 5, '桑皮': 6, '半夏': 18,
                   '熟地黄': 1,
                   '黄芪': 4, '荆芥': 2, '葛根': 2, '炙甘草': 16, '当归': 3, '大枣': 12, '小麦': 2, '陈皮': 7,
                   '柴胡': 2, '前胡': 6, '紫菀': 4, '厚朴': 3, '生地黄': 1, '枳壳': 3, '杏仁': 13, '瓜蒌仁': 4,
                   '白术': 5, '桔梗': 9, '桂枝': 7, '干姜': 8, '黄芩': 10, '麻黄': 10, '桑叶': 1, '细辛': 4, '阿胶': 2,
                   '肉桂': 2, '甘草': 14, '紫苏子': 2, '白附片': 3, '白果': 1, '防风': 1, '人参': 10, '浙贝母': 8,
                   '百部': 3, '白前': 2, '化橘红': 2}

english_collect = {'Smoked Plum': 1, 'Japonica Rice': 2, 'Common Anemarrhena Rhizome': 7, 'Ginger': 8, 'Pine Nut': 1,
                   'Magnoliavine Fruit': 6, 'Fructus Aurantii Immaturus': 2, 'White Paeony Root': 5, 'Coptis Root': 3,
                   'Dwarf Lily Tuber': 4, 'Gypsum': 3, 'Indian Buead': 13, 'Common Gardenia Fruit': 3,
                   'Cultibated Purple Perilla Leaf': 4, 'Tussilago': 5, 'Cortex Mori': 6, 'Pinellia Ternata': 18,
                   'Boiled Rehmannia Glutinosa': 1,
                   'Milkvetch Root': 4, 'Fineleaf Schizonepeta Herb': 2, 'Lobed Kudzuvine Root': 2,
                   'Broil Liquorice Root': 16, 'Chinese Angelica': 3, 'Jujube': 12, 'Wheat': 2,
                   'Tangerine Peel': 7,
                   'Starwort Root': 2, 'Radix Peucedani Root': 6, 'Tatarian Aster Root': 4,
                   'Officinal magnolia bark': 3, 'Rehmannia Glutinosa': 1, 'Immature Trifoliate-orange Fruit': 3,
                   'Bitter Apricot Seed': 13, 'Snakegourd Seed': 4,
                   'Largehead Atractylodes Rh': 5, 'Platycodon Grandiflorum': 9, 'Cmnamomi Mmulus': 7,
                   'Dried Ginger': 8, 'Baical Skullcap Root': 10, 'Chinese Ephedrs Herb': 10, 'Mulberry Leave': 1,
                   'Manchurian Wildginger': 4, 'Ass-hide Gelatin': 2,
                   'Cassia Bark': 2, 'Liquorice Root': 14, 'Fructus Perillae': 2,
                   'Prepared Common Monkshood Daughter Root': 3, 'Ginkgo Biloba': 1, 'Divaricate Saposhniovia Root': 1,
                   'Ginseng': 10, 'Thunberbg Fritillary Bulb': 8,
                   'Poppy Capsule': 2, 'Stemona Root': 3, 'Willowleaf Swallowwort Rhizome': 2, 'Pummelo Peel': 2}

chinese2english = {'乌梅': 'Smoked Plum', '粳米': 'Japonica Rice', '知母': 'Common Anemarrhena Rhizome',
                   '生姜': 'Ginger', '松子仁': 'Pine Nut', '五味子': 'Magnoliavine Fruit',
                   '枳实': 'Fructus Aurantii Immaturus', '白芍': 'White Paeony Root', '黄连': 'Coptis Root',
                   '麦冬': 'Dwarf Lily Tuber', '石膏': 'Gypsum', '茯苓': 'Indian Buead',
                   '栀子': 'Common Gardenia Fruit', '紫苏叶': 'Cultibated Purple Perilla Leaf', '款冬花': 'Tussilago',
                   '桑皮': 'Cortex Mori', '半夏': 'Pinellia Ternata', '熟地黄': 'Boiled Rehmannia Glutinosa',
                   '黄芪': 'Milkvetch Root', '荆芥': 'Fineleaf Schizonepeta Herb', '葛根': 'Lobed Kudzuvine Root',
                   '炙甘草': 'Broil Liquorice Root', '当归': 'Chinese Angelica', '大枣': 'Jujube', '小麦': 'Wheat',
                   '陈皮': 'Tangerine Peel', '柴胡': 'Starwort Root', '前胡': 'Radix Peucedani Root',
                   '紫菀': 'Tatarian Aster Root', '厚朴': 'Officinal magnolia bark', '生地黄': 'Rehmannia Glutinosa',
                   '枳壳': 'Immature Trifoliate-orange Fruit', '杏仁': 'Bitter Apricot Seed',
                   '瓜蒌仁': 'Snakegourd Seed', '白术': 'Largehead Atractylodes Rh', '桔梗': 'Platycodon Grandiflorum',
                   '桂枝': 'Cmnamomi Mmulus', '干姜': 'Dried Ginger', '黄芩': 'Baical Skullcap Root',
                   '麻黄': 'Chinese Ephedrs Herb', '桑叶': 'Mulberry Leave', '细辛': 'Manchurian Wildginger',
                   '阿胶': 'Ass-hide Gelatin', '肉桂': 'Cassia Bark', '甘草': 'Liquorice Root',
                   '紫苏子': 'Fructus Perillae', '白附片': 'Prepared Common Monkshood Daughter Root',
                   '白果': 'Ginkgo Biloba', '防风': 'Divaricate Saposhniovia Root', '人参': 'Ginseng',
                   '浙贝母': 'Thunberbg Fritillary Bulb', '百部': 'Stemona Root',
                   '白前': 'Willowleaf Swallowwort Rhizome', '化橘红': 'Pummelo Peel'}


english_prescriptions_name = {"止嗽散": 'Cough Powder', "定喘汤": 'Asthma-Reliving Decoction', "二陈汤": 'Erchen decoction',
                              "百部丸": 'Baibu Powder', "止咳宁嗽": 'Zhike Ningsou Decoction', "厚朴麻黄汤": 'Houpu Mahuang Decoction',
                              "杏苏散": 'Xingsu Powder', "三拗汤": 'Sanao Decoction', "加减七气汤": 'Qiqi Decoction',
                              "半瓜丸": 'Bangua Powder', "清咽宁肺汤": 'Qingyan Ningfei Decoction',
                              "清金化痰汤": 'Qingjin Huatan Decoction', "二母宁嗽汤": 'Anemarrhena and Fritillaria Cough-Quieting Decoction',
                              "清金降火汤": 'Qingjin Jianghuo Decoction', "温肺汤": 'Wenfei Decoction', "苏子汤": 'Suzi Decoction',
                              "理中汤": 'Lizhong Decoction', "加味补肺汤": 'Bufei Decoction', "黄芪汤": 'Huangqi Decoction',
                              "加味人参黄芪汤": 'Renshen Huangqi Decoction', "人参款花散": 'Renshen Kuanhua Decoction',
                              "九仙散": 'Jiuxian Powder', "小青龙汤": 'Small Qinglong Decoction', "大青龙汤": 'Major Blue Dragon Decoction',
                              "山东中草药手册：治感冒咳嗽": 'SD Ganmao Kesou Decoction', "白芍甘草汤": 'Baishao Gancao Decoction',
                              "小柴胡汤": 'Small Chaihu Decoction', "大柴胡汤": 'Major Chaihu Decoction', "甘草附子汤": 'Gancao Fuzi Decoction',
                              "苓桂术甘汤": 'Lingguishugan Decoction', "麻杏甘石汤": 'Maxinganshi Decoction', "葛根汤": 'Gegen Decoction',
                              "葛根芩莲汤": 'Gegenlinglian Decoction', "白虎汤": 'Baihu Decoction', "桂枝汤": 'Guizhi Decoction',
                              "麻黄汤": 'Mahuang Decoction', "人参汤": 'Renshen Decoction', "真武汤": 'Zhenwu Decoction',
                              "半夏泻心汤": 'Banxia Xiexin Decoction', "半夏厚朴汤": 'Banxia Houpu Decoction',
                              "甘草泻心汤": 'Gancao Xiexin Decoction', "附子粳米汤": 'Fuzi Jingmi Decoction', "甘麦大枣汤": 'Ganmai Dazao Decoction'
                              }

prescriptions = {
    # -----------------------咳嗽---------------------------
    # 常用
    "止嗽散": ['紫菀', '百部', '白前', '桔梗', '荆芥', '陈皮', '炙甘草'],
    "定喘汤": ['白果', '麻黄', '紫苏子', '甘草', '款冬花', '杏仁', '桑皮', '黄芩', '半夏'],
    # "清燥救肺汤": ['桑叶', '石膏', '阿胶', '麦冬', '杏仁', '枇杷叶', '沙参', '胡麻仁', '甘草'],
    "二陈汤": ['半夏', '化橘红', '茯苓', '炙甘草'],
    # "百合固金汤": ['生地黄', '熟地黄', '麦冬', '百合', '白芍', '当归', '浙贝母', '甘草', '玄参', '桔梗'],
    # "养阴清肺汤": ['生地黄', '麦冬', '甘草', '玄参', '浙贝母', '牡丹皮', '薄荷', '白芍'],
    # "桑杏汤": ['桑叶', '杏仁', '沙参', '浙贝母', '豆豉', '栀子', '梨皮'],

    "百部丸": ['百部', '麻黄', '杏仁', '松子仁'],
    # "百部汤": ['百部', '薏米', '百合', '麦冬', '桑皮', '茯苓', '沙参', '黄芪', '地骨皮'],
    "止咳宁嗽": ['桔梗', '荆芥', '百部', '紫菀', '白前', '前胡', '款冬花', '麻黄', '陈皮', '杏仁', '防风'],
    # "痰核消散汤": ['柴胡', '郁金', '党参', '白术', '茯苓', '陈皮', '白芥子', '海藻', '僵蚕', '浙贝母', '夏枯草', '半夏',
    #                '土鳖虫', '桂枝', '甘草'],
    # "麦冬汤": ['麦冬', '半夏', '人参', '甘草', '粳米', '大枣'],
    "厚朴麻黄汤": ['厚朴', '麻黄', '石膏', '杏仁', '半夏', '干姜', '细辛', '小麦', '五味子'],

    # 86岁老中医毕生总结的治咳七法：https://www.sohu.com/a/508784028_120099896
    "杏苏散": ['杏仁', '紫苏叶', '桔梗', '枳壳', '前胡', '半夏', '陈皮', '茯苓', '炙甘草', '大枣'],
    "三拗汤": ['麻黄', '杏仁', '甘草'],
    # "桑菊饮": ['桑叶', '菊花', '薄荷', '杏仁', '桔梗', '甘草', '连翘', '芦根'],
    # "加减银翘散": ['金银花', '连翘', '桔梗', '薄荷', '芥穗', '牛蒡子', '浙贝母', '杏仁', '豆豉', '甘草'],
    # "加减流气饮子": ['厚朴', '紫苏叶', '陈皮', '大腹皮', '瓜蒌皮', '桔梗', '枳壳', '半夏', '茯苓', '香附', '炙甘草'],
    "加减七气汤": ['厚朴', '半夏', '茯苓', '白芍', '紫苏叶', '陈皮', '杏仁', '桔梗', '前胡', '桑皮', '浙贝母'],
    # "苏子降气汤": ['紫苏子', '厚朴', '半夏', '前胡', '沉香', '当归', '甘草', '生姜'],
    # "加味沉香降气汤": ['香附', '陈皮', '紫苏子', '桑皮', '砂仁', '沉香', '桔梗', '莱菔子', '甘草'],
    # "三子养亲汤": ['紫苏子', '白芥子', '莱菔子'],
    "半瓜丸": ['半夏', '瓜蒌仁', '桔梗', '枳壳', '知母'],
    # "桃仁散": ['桃仁', '桑皮', '茯苓', '橘络', '紫苏梗', '紫苏叶', '槟榔'],
    # "加味当归饮": ['大黄', '当归', '紫苏木', '生地黄', '白芍', '桔梗', '浙贝母'],
    "清咽宁肺汤": ['桔梗', '栀子', '黄芩', '桑皮', '前胡', '知母', '浙贝母', '甘草'],
    # "清肺汤": ['黄芩', '桔梗', '茯苓', '桑皮', '陈皮', '浙贝母', '天冬', '栀子', '杏仁', '麦冬', '甘草', '当归'],
    "清金化痰汤": ['黄芩', '栀子', '桔梗', '麦冬', '桑皮', '浙贝母', '知母', '瓜蒌仁', '化橘红', '茯苓', '甘草'],
    "二母宁嗽汤": ['石膏', '知母', '浙贝母', '栀子', '黄芩', '瓜蒌仁', '茯苓', '陈皮', '枳实', '甘草'],
    "清金降火汤": ['杏仁', '前胡', '桔梗', '浙贝母', '瓜蒌仁', '石膏', '枳壳', '陈皮', '黄芩', '茯苓', '甘草',
                   '半夏'],
    # "石膏散": ['石膏', '炙甘草', '桔梗', '枇杷叶', '浙贝母', '桑皮', '栀子'],
    # "加减洗肺散":['天冬','麦冬','五味子','沙参','杏仁','桑皮','枇杷叶','六一散'],
    # "加味玉露散": ['石膏', '滑石', '寒水石', '白药', '甘草', '桑皮', '枇杷叶', '麦冬', '竹叶', '五味子', '桔梗'],
    # "清金白虎汤": ['石膏', '知母', '竹叶', '党参', '桑皮', '地骨皮', '桔梗', '甘草', '乌梅'],
    "温肺汤": ['干姜', '半夏', '杏仁', '陈皮', '甘草', '细辛', '阿胶', '生姜', '大枣'],
    "苏子汤": ['紫苏子', '干姜', '半夏', '肉桂', '人参', '陈皮', '茯苓', '甘草'],
    # "加减三奇汤": ['陈皮', '桔梗', '青皮', '紫苏梗', '半夏', '杏仁', '金沸草', '枳壳', '干姜', '甘草', '沉香'],
    # "半夏温肺汤": ['半夏', '茯苓', '细辛', '干姜', '肉桂', '桔梗', '陈皮', '复花', '人参', '白术', '甘草'],
    "理中汤": ['人参', '白术', '干姜', '甘草'],
    "加味补肺汤": ['熟地黄', '肉桂', '人参', '紫菀', '黄芪', '桑皮', '五味子'],
    "黄芪汤": ['黄芪', '白芍', '麦冬', '五味子', '前胡', '人参', '细辛', '当归', '茯苓', '半夏', '大枣', '生姜'],
    # "生脉地黄汤": ['人参', '麦冬', '五味子', '生地黄', '山药', '山萸', '茯苓', '牡丹皮', '泽泻'],
    # "加减地黄汤": ['熟地黄', '生地黄', '山药', '山萸', '麦冬', '川贝', '茯苓', '甘草', '枸杞', '地骨皮', '阿胶'],
    "加味人参黄芪汤": ['人参', '黄芪', '白术', '陈皮', '茯苓', '甘草', '当归', '五味子', '麦冬', '紫菀', '款冬花'],
    # "加味白术汤": ['人参', '白术', '化橘红', '半夏', '茯苓', '浙贝母', '甘草', '前胡', '白附片', '神曲'],
    # "紫菀散": ['紫菀', '阿胶', '人参', '沙参', '麦冬', '川贝', '甘草', '茯苓', '桔梗', '五味子'],
    # "二冬膏": ['天冬', '麦冬', '蜂蜜'],
    # "沙参麦冬汤": ['沙参', '麦冬', '玉竹', '甘草', '桑叶', '生扁豆', '白药'],
    # "润肺丸": ['诃子', '五倍子', '五味子', '甘草', '蜜丸噙化'],
    # "人参款花散": ['人参', '款冬花', '知母', '浙贝母', '半夏', '罂粟壳'],
    # "九仙散": ['人参', '款冬花', '桔梗', '桑皮', '五味子', '阿胶', '浙贝母', '乌梅', '罂粟壳', '干姜', '大枣'],
    # "加味诃黎勒丸": ['诃子', '海粉', '瓜蒌仁', '青黛', '杏仁', '马兜铃', '百合', '乌梅', '五味子'],
    # -----------------------咳嗽结束---------------------------

    # -----------------------伤寒发热-----------------------
    # "防风通圣散": ['防风', '大黄', '芒硝', '荆芥', '麻黄', '栀子', '白芍', '连翘', '甘草', '桔梗', '川芎', '当归',
    #                '石膏', '滑石', '薄荷', '黄芩', '白术'],
    # "川芎茶调散": ['川芎', '荆芥', '白芷', '羌活', '甘草', '细辛', '防风', '薄荷'],
    "小青龙汤": ['麻黄', '桂枝', '干姜', '细辛', '五味子', '白芍', '半夏', '炙甘草'],
    "大青龙汤": ['麻黄', '桂枝', '炙甘草', '杏仁', '生姜', '大枣', '石膏'],
    "山东中草药手册：治感冒咳嗽": ['浙贝母', '知母', '桑叶', '杏仁', '紫苏叶'],
    # "山东中草药手册：治痈毒肿痛": ['浙贝母', '连翘各', '金银花', '蒲公英'],
    "白芍甘草汤": ['白芍', '甘草'],
    "小柴胡汤": ['柴胡', '人参', '黄芩', '半夏', '炙甘草'],
    "大柴胡汤": ['柴胡', '枳实', '生姜', '黄芩', '白芍', '半夏', '大枣'],
    # "当归四逆汤": ['当归', '桂枝', '白芍', '细辛', '通草', '大枣', '炙甘草'],
    "甘草附子汤": ['炙甘草', '白附片', '白术', '桂枝'],
    # "柴桂汤": ['柴胡', '桂枝', '白药', '牡蛎', '炮姜', '甘草'],
    # "黄连阿胶汤": ['黄连', '黄芩', '白芍', '阿胶', '鸡子黄'],
    # "麻黄升麻汤": ['麻黄', '升麻', '当归', '知母', '黄芩', '葳蕤', '白芍', '天冬', '桂枝', '茯苓', '炙甘草', '石膏',
    #                '白术', '干姜'],
    "苓桂术甘汤": ['茯苓', '桂枝', '白术', '炙甘草'],
    # "五苓散": ['桂枝', '猪苓', '泽泻', '白术', '茯苓', '桂枝'],
    "麻杏甘石汤": ['麻黄', '杏仁', '炙甘草', '石膏'],
    "葛根汤": ['葛根', '麻黄', '生姜', '桂枝', '白芍', '炙甘草', '大枣'],
    "葛根芩莲汤": ['葛根', '炙甘草', '黄芩', '黄连'],
    "白虎汤": ['知母', '石膏', '炙甘草', '粳米'],
    # "射干麻黄汤": ['射干', '麻黄', '生姜', '细辛', '紫菀', '款冬花', '五味子', '大枣', '半夏'],
    "桂枝汤": ['桂枝', '白芍', '生姜', '大枣', '炙甘草'],
    "麻黄汤": ['麻黄', '桂枝', '杏仁', '炙甘草'],
    # -----------------------伤寒发热结束---------------------------

    # -----------------------气血-----------------------
    "人参汤": ['人参', '麦冬', '生地黄', '当归', '白芍', '黄芪', '茯苓', '炙甘草'],
    # "桂枝茯苓丸": ['桂枝', '茯苓', '牡丹', '桃仁', '白芍'],
    # "当归白芍散": ['当归', '白芍', '茯苓', '白术', '泽泻', '川芎'],
    # "芎归胶艾汤": ['川芎', '阿胶', '甘草', '艾叶', '当归', '白芍', '熟地黄'],
    # "温经汤": ['吴茱萸', '当归', '白芍', '川芎', '人参', '桂枝', '阿胶', '牡丹皮', '生姜', '甘草', '半夏', '麦冬'],
    "真武汤": ['茯苓', '白芍', '白术', '生姜', '白附片'],

    # -----------------------肠道-----------------------
    # "桃核承气汤": ['桃核', '桂枝', '大黄', '炙甘草', '芒硝'],
    # "赤石脂禹余粮汤":['赤石脂','禹余粮'],

    # -----------------------呕吐-----------------------
    "半夏泻心汤": ['半夏', '黄芩', '干姜', '人参', '炙甘草', '黄连', '大枣'],
    "半夏厚朴汤": ['半夏', '厚朴', '茯苓', '生姜', '紫苏叶'],
    "甘草泻心汤": ['甘草', '黄芩', '干姜', '半夏', '大枣', '黄连'],
    "附子粳米汤": ['白附片', '半夏', '甘草', '大枣', '粳米'],

    # -----------------------祛邪-----------------------
    # "排脓散": ['黄芪', '白芷', '五味子', '人参'],
    "甘麦大枣汤": ['甘草', '小麦', '大枣']
}

all_medicine = set()
for i in list(prescriptions.values()):
    for j in i:
        all_medicine.add(j)

med_count = dict()
for i in list(all_medicine):
    med_count[i] = 0

for i in list(prescriptions.values()):
    for j in i:
        med_count[j] = med_count[j] + 1

chinese2english = {}
c = list(chinese_collect.keys())
e = list(english_collect.keys())
for idx in range(len(chinese_collect)):
    chinese2english[c[idx]] = e[idx]

english_prescriptions = {}
for k_elem in list(prescriptions.keys()):
    med_list = []
    for m_elem in prescriptions[k_elem]:
        med_list.append(chinese2english[m_elem])

    english_prescriptions[english_prescriptions_name[k_elem]] = med_list

english_c = [chinese2english[tmp] for tmp in c]

print("test")

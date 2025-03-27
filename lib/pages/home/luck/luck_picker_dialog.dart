import 'package:clover/common/api.dart';
import 'package:clover/common/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

class LuckPickerDialog extends StatefulWidget {
  @override
  _LuckPickerDialogState createState() => _LuckPickerDialogState();
}

class _LuckPickerDialogState extends State<LuckPickerDialog> {
  int selectedLuck = 5;
  TextEditingController infoController = TextEditingController();

  var _isLoading = false;

  void _addRecord() async {
    if (_isLoading) return;

    String inputText = infoController.text.trim();

    // if (inputText.isEmpty) {
    //   TDToast.showWarning('请输入内容',
    //       direction: IconTextDirection.horizontal, context: context);
    //   return;
    // }

    setState(() {
      _isLoading = true;
    });

    var params = {
      'content': inputText,
      'type': 'luck',
      'luckValue': selectedLuck
    };

    try {
      await addDayRecordDetail(null, params);
      Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();

      TDToast.showText('记录添加成功', context: context);
      infoController.clear();
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop(); // 关闭弹层
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      TDToast.showText('添加失败请重试', context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLuck = luckData[selectedLuck];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 2.0,
            colors: [
              currentLuck['color'].withOpacity(1.0),
              currentLuck['color'].withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // 顶部固定区域：标题和使用介绍
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      '选择你的运气',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '运气值从 0 - 10 代表着从坏到好，如果不记录的情况下，默认是 5',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(1, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // 中间固定区域：运气名称、输入框和 tips
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                                CrossAxisAlignment.center, // 整体居中对齐
                            children: [
                              GestureDetector(
                                onHorizontalDragUpdate: (details) {
                                  setState(() {
                                    double sensitivity = 0.05;
                                    selectedLuck -=
                                        (details.delta.dx * sensitivity)
                                            .round();
                                    selectedLuck = selectedLuck.clamp(0, 10);
                                  });
                                },
                                child: Text(
                                  currentLuck['name'],
                                  textAlign: TextAlign.center, // 文字居中
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.6),
                                        offset: Offset(3, 3),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: infoController,
                                style: TextStyle(color: Colors.white),
                                cursorColor: Colors.white,
                                maxLines: 4,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.black.withOpacity(0.2),
                                  hintText: currentLuck['placeholder'],
                                  hintStyle: TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              SizedBox(height: 20), // 为 tips 提供上间距
                              SizedBox(
                                height: 100, // 固定 tips 区域高度
                                width: double.infinity, // tips 宽度占满
                                child: SingleChildScrollView(
                                  child: Wrap(
                                    spacing: 8.0,
                                    runSpacing: 8.0,
                                    alignment:
                                        WrapAlignment.center, // tips 居中对齐
                                    children:
                                        (currentLuck['tips'] as List<String>)
                                            .map((tip) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            infoController.text = tip;
                                          });
                                        },
                                        child: _buildTipBubble(
                                            tip, currentLuck['color']),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 底部预留空间
                  SizedBox(height: 150), // 为滑块和按钮留出空间
                ],
              ),
              // 底部固定区域：滑块和按钮
              Positioned(
                left: 10,
                right: 10,
                bottom: 90,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 12,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 18),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 22),
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                    thumbColor: currentLuck['color'],
                    overlayColor: currentLuck['color'].withOpacity(0.3),
                    trackShape: RoundedRectSliderTrackShape(),
                  ),
                  child: Slider(
                    value: selectedLuck.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: currentLuck['name'],
                    onChanged: (double value) {
                      setState(() {
                        selectedLuck = value.round();
                      });
                    },
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 20,
                child: ElevatedButton(
                  onPressed: () {
                    _addRecord();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.6),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    '记录运气',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              // 关闭按钮
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipBubble(String tip, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        tip,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  void dispose() {
    infoController.dispose();
    super.dispose();
  }
}

// 优化后的 luckData，包含更多 tips 选项
final List<Map<String, dynamic>> luckData = [
  {
    'luckValue': 0,
    'color': Color(0xFFD32F2F),
    'name': '运气极差',
    'placeholder': '今天发生了什么倒霉的事？',
    'tips': [
      '丢了钱包',
      '踩到狗屎',
      '错过了最后一班车',
      '手机摔坏了',
      '被雨淋湿全身',
      '考试不及格',
    ],
  },
  {
    'luckValue': 1,
    'color': Color(0xFFE64A19),
    'name': '霉运连连',
    'placeholder': '有什么让你感到很郁闷的事？',
    'tips': [
      '迟到了还被批评',
      '手机掉水里',
      '买的东西坏了',
      '忘带重要文件',
      '排队排到崩溃',
      '丢了耳机',
    ],
  },
  {
    'luckValue': 2,
    'color': Color(0xFFFF5722),
    'name': '稍微不顺',
    'placeholder': '今天有些小波折，是什么呢？',
    'tips': [
      '手机没电了',
      '忘带钥匙',
      '排队等太久',
      '公交车没赶上',
      '点餐出错',
      '天气突然变差',
    ],
  },
  {
    'luckValue': 3,
    'color': Color(0xFFFF7043),
    'name': '有点不顺',
    'placeholder': '今天有些小烦恼，可以写下来哦！',
    'tips': [
      '下雨没带伞',
      '咖啡洒了',
      '公交晚点',
      '电脑卡顿',
      '忘充电器',
      '鞋子磨脚',
    ],
  },
  {
    'luckValue': 4,
    'color': Color(0xFFFFA726),
    'name': '平淡无奇',
    'placeholder': '今天平淡无奇，想记录些什么？',
    'tips': [
      '吃了顿普通午餐',
      '看了部电影',
      '天气一般',
      '刷了会手机',
      '走路回家',
      '睡了个午觉',
    ],
  },
  {
    'luckValue': 5,
    'color': Color(0xFFFFCA28),
    'name': '普通的一天',
    'placeholder': '今天过得普通，有什么想说？',
    'tips': [
      '捡到一块钱',
      '遇见老朋友',
      '买到打折商品',
      '吃了顿家常饭',
      '天气还不错',
      '完成日常任务',
      '听了几首歌',
    ],
  },
  {
    'luckValue': 6,
    'color': Color(0xFFAED581),
    'name': '小确幸',
    'placeholder': '今天有什么小幸运？',
    'tips': [
      '买咖啡有折扣',
      '天气很好',
      '收到小礼物',
      '找到好座位',
      '赶上末班车',
      '吃到喜欢的零食',
    ],
  },
  {
    'luckValue': 7,
    'color': Color(0xFF81C784),
    'name': '运气不错',
    'placeholder': '今天过得还不错，想分享什么？',
    'tips': [
      '中了个小奖',
      '工作顺利完成',
      '吃到好吃的',
      '朋友送了东西',
      '路上没堵车',
      '买到心仪的东西',
    ],
  },
  {
    'luckValue': 8,
    'color': Color(0xFF66BB6A),
    'name': '运气很好',
    'placeholder': '今天有什么让你开心的事情？',
    'tips': [
      '朋友请吃饭',
      '意外加薪',
      '找到好停车位',
      '抽中优惠券',
      '考试成绩不错',
      '收到表扬',
      '买到限时特价',
    ],
  },
  {
    'luckValue': 9,
    'color': Color(0xFF4CAF50),
    'name': '超好运',
    'placeholder': '今天发生了什么让你惊喜的事？',
    'tips': [
      '抽中限量版礼物',
      '考试全对',
      '遇到心动的人',
      '捡到大红包',
      '项目大获成功',
      '旅行计划顺利',
    ],
  },
  {
    'luckValue': 10,
    'color': Color(0xFF388E3C),
    'name': '运气爆棚',
    'placeholder': '天降鸿运！写下你的好运吧！',
    'tips': [
      '彩票中大奖',
      '梦想成真',
      '一切顺利',
      '收到意外大礼',
      '升职加薪',
      '旅行全免费',
      '遇到贵人相助',
    ],
  },
];

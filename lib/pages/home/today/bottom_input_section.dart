import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/common/provider.dart';
import '/common/api.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class WordCloud extends StatelessWidget {
  final List<String> sentences;
  final Function(String) onSentenceTap;

  WordCloud({required this.sentences, required this.onSentenceTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center, // 居中布局
        spacing: 8.0, // 句子之间的水平间距
        runSpacing: 8.0, // 句子之间的垂直间距
        children: sentences.map((sentence) {
          return AnimatedWordItem(
            sentence: sentence,
            onTap: () => onSentenceTap(sentence),
          );
        }).toList(),
      ),
    );
  }
}

// 带动画的词项组件
class AnimatedWordItem extends StatefulWidget {
  final String sentence;
  final VoidCallback onTap;

  const AnimatedWordItem({required this.sentence, required this.onTap});

  @override
  _AnimatedWordItemState createState() => _AnimatedWordItemState();
}

class _AnimatedWordItemState extends State<AnimatedWordItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 初始化动画控制器
    _controller = AnimationController(
      duration: Duration(milliseconds: 500), // 动画时长 500ms
      vsync: this,
    );

    // 透明度动画：从 0 到 1
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // 缩放动画：从 0.5 到 1
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // 随机延迟启动动画
    Future.delayed(Duration(milliseconds: (500 * math.Random().nextDouble()).toInt()), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // 释放动画控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value, // 透明度
            child: Transform.scale(
              scale: _scaleAnimation.value, // 缩放
              child: child,
            ),
          );
        },
        child: _SentenceItem(sentence: widget.sentence), // 自定义词项组件
      ),
    );
  }
}

// 自定义词项组件
class _SentenceItem extends StatelessWidget {
  final String sentence;

  const _SentenceItem({required this.sentence});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        sentence,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class Category {
  final String label;
  final Color color;

  Category({required this.label, required this.color});
}

class BottomInputSection extends StatefulWidget {
  @override
  _BottomInputSectionState createState() => _BottomInputSectionState();
}

class _BottomInputSectionState extends State<BottomInputSection>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isInputVisible = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  // 维护一个句子数组
  List<String> sentences = [
    "今天心情很好",
    "工作有点累",
    "学习新知识很有趣",
    "和朋友一起吃饭",
    "天气真不错",
    "需要好好休息",
    "计划明天去旅行",
    "最近有点忙",
    "感觉压力很大",
    "期待周末的到来",
    "今天完成了重要任务",
    "喝了一杯咖啡提神",
    "晚上去健身房锻炼",
    "看了一部好电影",
    "和家人通了电话",
    "整理了一下房间",
    "读了一本有趣的书",
    "尝试了一道新菜",
    "听了一首喜欢的歌",
    "今天早睡早起",
  ];

  // 维护一个分类数组
  List<Category> categories = [
    Category(label: '生活', color: Color.fromARGB(128, 0, 0, 255)), // 50% 透明度的蓝色
    Category(label: '睡眠', color: Color.fromARGB(128, 128, 0, 128)), // 50% 透明度的紫色
    Category(label: '工作', color: Color.fromARGB(128, 0, 128, 0)), // 50% 透明度的绿色
    Category(label: '学习', color: Color.fromARGB(128, 255, 165, 0)), // 50% 透明度的橙色
    Category(label: '饮食', color: Color.fromARGB(128, 255, 0, 0)), // 50% 透明度的红色
    Category(label: '运动', color: Color.fromARGB(128, 0, 128, 128)), // 50% 透明度的青色
    Category(label: '娱乐', color: Color.fromARGB(128, 255, 192, 203)), // 50% 透明度的粉色
    Category(label: '旅行', color: Color.fromARGB(128, 75, 0, 130)), // 50% 透明度的靛蓝色
    Category(label: '购物', color: Color.fromARGB(128, 255, 193, 7)), // 50% 透明度的琥珀色
    Category(label: '健康', color: Color.fromARGB(128, 0, 255, 255)), // 50% 透明度的青色
    Category(label: '心情', color: Color.fromARGB(128, 0, 255, 0)), // 50% 透明度的酸橙色
    Category(label: '社交', color: Color.fromARGB(128, 165, 42, 42)), // 50% 透明度的棕色
    Category(label: '家庭', color: Color.fromARGB(128, 255, 140, 0)), // 50% 透明度的深橙色
    Category(label: '宠物', color: Color.fromARGB(128, 96, 125, 139)), // 50% 透明度的蓝灰色
    Category(label: '其他', color: Color.fromARGB(128, 128, 128, 128)), // 50% 透明度的灰色
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addRecord() async {
    if (_isLoading) return;

    String inputText = _controller.text.trim();

    if (inputText.isEmpty) {
      TDToast.showWarning('请输入内容',
          direction: IconTextDirection.horizontal, context: context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var params = {
      'content': inputText,
      'type': 'prompt',
    };

    try {
      await addDayRecordDetail(null, params);
      Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();

      TDToast.showText('记录添加成功', context: context);
      _controller.clear();
      setState(() {
        _isInputVisible = false;
        _isLoading = false;
      });
      _animationController.reverse();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      TDToast.showText('添加失败请重试', context: context);
    }
  }

  void _showInputSection() {
    setState(() {
      _isInputVisible = true;
    });
    Future.delayed(Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    _animationController.forward();
  }

  void _closeInputSection() {
    setState(() {
      _isInputVisible = false;
    });
    _focusNode.unfocus();
    _animationController.reverse();
  }

  void _onSentenceTap(String sentence) {
    _controller.text = sentence;
    _focusNode.requestFocus();
  }

  // 刷新词云内容
  void _refreshWordCloud() {
    setState(() {
      sentences = [
        "新的句子1",
        "新的句子2",
        "新的句子3",
        "新的句子4",
        "新的句子5",
        "新的句子6",
        "新的句子7",
        "新的句子8",
        "新的句子9",
        "新的句子10",
      ]..shuffle(); // 随机打乱顺序
    });
  }

  // 刷新分类内容
  void _refreshCategories() {
    setState(() {
      categories = [
        Category(label: '新分类1', color: Color.fromARGB(128, 0, 0, 255)),
        Category(label: '新分类2', color: Color.fromARGB(128, 128, 0, 128)),
        Category(label: '新分类3', color: Color.fromARGB(128, 0, 128, 0)),
        Category(label: '新分类4', color: Color.fromARGB(128, 255, 165, 0)),
        Category(label: '新分类5', color: Color.fromARGB(128, 255, 0, 0)),
      ]..shuffle(); // 随机打乱顺序
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_isInputVisible)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeInputSection,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ),
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isInputVisible)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // 关闭按钮和刷新按钮
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(Icons.refresh, color: Colors.white),
                              onPressed: _refreshWordCloud,
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.white),
                              onPressed: _closeInputSection,
                            ),
                          ],
                        ),

                        // 词云组件
                        WordCloud(
                          sentences: sentences,
                          onSentenceTap: _onSentenceTap,
                        ),

                        // 分类标签和刷新按钮
                        SizedBox(height: 12), // 添加间距
                        Container(
                          height: 32, // 分类标签的高度
                          child: Row(
                            children: [
                              Expanded(
                                child: ListView(
                                  scrollDirection: Axis.horizontal, // 水平滚动
                                  children: [
                                    SizedBox(width: 4), // 左侧留白
                                    ...categories.map((category) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 4),
                                        child: GestureDetector(
                                          onTap: () {
                                            // 处理分类标签点击事件
                                            print('点击了分类: ${category.label}');
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: category.color, // 使用分类的颜色
                                              borderRadius: BorderRadius.circular(20), // 圆角
                                            ),
                                            alignment: Alignment.center, // 文字水平居中
                                            child: Text(
                                              category.label,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                              // 分类刷新按钮
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: GestureDetector(
                                  onTap: _refreshCategories,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800], // 刷新按钮的颜色
                                      borderRadius: BorderRadius.circular(20), // 圆角
                                    ),
                                    alignment: Alignment.center, // 文字水平居中
                                    child: Icon(
                                      Icons.refresh,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 4),
                GestureDetector(
                  onTap: _showInputSection,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: _isInputVisible,
                    style: TextStyle(color: Colors.white, fontSize: 11),
                    maxLines: 5, // 设置为多行输入框
                    minLines: 2, // 最小显示 3 行
                    decoration: InputDecoration(
                      hintText: '记录一下',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12), // 调整内边距
                    ),
                  ),
                ),
                if (_isInputVisible)
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _animationController,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                        child: Row(
                          children: [
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '每次记录消耗一枚时光币',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 32,
                              width: 72,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _addRecord,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: EdgeInsets.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        "保存记录",
                                        style: TextStyle(
                                            fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
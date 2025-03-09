import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/common/provider.dart';
import '/common/api.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

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
          return GestureDetector(
            onTap: () => onSentenceTap(sentence),
            child: _SentenceItem(sentence: sentence), // 使用自定义组件
          );
        }).toList(),
      ),
    );
  }
}

// 自定义句子组件，用于添加点击效果
class _SentenceItem extends StatefulWidget {
  final String sentence;

  const _SentenceItem({required this.sentence});

  @override
  __SentenceItemState createState() => __SentenceItemState();
}

class __SentenceItemState extends State<_SentenceItem> {
  bool _isPressed = false; // 是否按下

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 100), // 动画效果
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: _isPressed ? Colors.grey[600] : Colors.transparent, // 按下时背景色变化
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        widget.sentence,
        style: TextStyle(
          color: _isPressed ? Colors.grey[300] : Colors.white, // 按下时文字颜色变化
          fontSize: 12.0, // 固定文字大小为 12px
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
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
  final List<String> sentences = [
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
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: _closeInputSection,
                          ),
                        ),
                        // 添加词云组件
                        WordCloud(
                          sentences: sentences,
                          onSentenceTap: _onSentenceTap,
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 6),
                GestureDetector(
                  onTap: _showInputSection,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: _isInputVisible,
                    style: TextStyle(color: Colors.white, fontSize: 11),
                    decoration: InputDecoration(
                      hintText: '记录一下',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                              child: Row(
                                children: [
                                  Icon(Icons.photo_camera, color: Colors.white),
                                  SizedBox(width: 8),
                                  Icon(Icons.attach_file, color: Colors.white),
                                ],
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
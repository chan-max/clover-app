import 'package:clover/common/api.dart';
import 'package:clover/common/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'word_cloud.dart';
import 'category_tabs.dart';

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

  List<String> sentences = [
    "今天心情很好",
    "工作有点累",
    "学习新知识很有趣",
    "和朋友一起吃饭",
    "天气真不错",
  ];

  List<Category> categories = [
    Category(label: '生活', color: Color.fromARGB(128, 0, 0, 255)),
    Category(label: '工作', color: Color.fromARGB(128, 0, 128, 0)),
    Category(label: '学习', color: Color.fromARGB(128, 255, 165, 0)),
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

  void _refreshWordCloud() {
    setState(() {
      sentences = [
        "新的句子1",
        "新的句子2",
        "新的句子3",
      ]..shuffle();
    });
  }

  void _refreshCategories() {
    setState(() {
      categories = [
        Category(label: '新分类1', color: Color.fromARGB(128, 0, 0, 255)),
        Category(label: '新分类2', color: Color.fromARGB(128, 128, 0, 128)),
      ]..shuffle();
    });
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
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
                        WordCloud(
                          sentences: sentences,
                          onSentenceTap: (sentence) {
                            _controller.text = sentence;
                            _focusNode.requestFocus();
                          },
                        ),
                        SizedBox(height: 12),
                        Container(
                          height: 32,
                          child: CategoryTabs(
                            categories: categories,
                            onRefresh: _refreshCategories,
                          ),
                        ),
                      ],
                    ),
                  ),
                GestureDetector(
                  onTap: _showInputSection,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: _isInputVisible,
                    style: TextStyle(color: Colors.white, fontSize: 11),
                    maxLines: 5,
                    minLines: 2,
                    decoration: InputDecoration(
                      hintText: '记录一下',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
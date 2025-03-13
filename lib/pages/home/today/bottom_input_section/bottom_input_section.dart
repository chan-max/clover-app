import 'package:clover/common/api.dart';
import 'package:clover/common/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'word_cloud.dart';
import 'category_tabs.dart';

class BottomInputSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
        child: ElevatedButton(
          onPressed: () => _showInputSection(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            "添加记录",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showInputSection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return InputBottomSheet();
      },
    );
  }
}

class InputBottomSheet extends StatefulWidget {
  @override
  _InputBottomSheetState createState() => _InputBottomSheetState();
}

class _InputBottomSheetState extends State<InputBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

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
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              WordCloud(
                sentences: sentences,
                onSentenceTap: (sentence) {
                  _controller.text = sentence;
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
              SizedBox(height: 12),
              TextField(
                controller: _controller,
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
              SizedBox(height: 12),
              Padding(
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
            ],
          ),
        ),
      ),
    );
  }
}
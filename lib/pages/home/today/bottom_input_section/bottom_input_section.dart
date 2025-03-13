import 'package:clover/common/api.dart';
import 'package:clover/common/provider.dart';
import 'package:clover/pages/common/recordPromptTutorial.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import 'word_cloud.dart';
import 'category_tabs.dart';

class BottomInputSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: SizedBox(
        width: double.infinity, // 让按钮宽度占满
        child: ElevatedButton(
          onPressed: () => _showInputSection(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.symmetric(vertical: 12), // 水平方向已由 `SizedBox` 控制
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
    Category(
        label: '碎片', color: Color.fromARGB(128, 169, 169, 169)), // 深灰色（零碎记录）
    Category(
        label: '心情', color: Color.fromARGB(128, 255, 105, 180)), // 热粉色（情绪记录）
    Category(label: '状态', color: Color.fromARGB(128, 255, 165, 0)), // 橙色（身体状态）
    Category(
        label: '运气', color: Color.fromARGB(128, 0, 191, 255)), // 深天蓝（幸运、随机事件）
    Category(label: '睡眠', color: Color.fromARGB(128, 75, 0, 130)), // 靛蓝色（安静、夜晚）
    Category(label: '饮食', color: Color.fromARGB(128, 0, 128, 0)), // 绿色（健康饮食）
    Category(
        label: '运动', color: Color.fromARGB(128, 220, 20, 60)), // 猩红色（活力、运动）
    Category(
        label: '事件', color: Color.fromARGB(128, 70, 130, 180)), // 钢蓝色（重要事情）
    Category(
        label: '学习', color: Color.fromARGB(128, 30, 144, 255)), // 道奇蓝（学习、思考）
    Category(label: '健康', color: Color.fromARGB(128, 255, 69, 0)), // 橙红色（健康管理）
    Category(
        label: '旅行', color: Color.fromARGB(128, 46, 139, 87)), // 海洋绿（旅行、出行）
    Category(label: '购物', color: Color.fromARGB(128, 186, 85, 211)), // 紫罗兰红（消费）
    Category(
        label: '娱乐', color: Color.fromARGB(128, 255, 140, 0)), // 暗橙色（电影、游戏）
    Category(
        label: '工作', color: Color.fromARGB(128, 105, 105, 105)), // 暗灰色（任务、工作）
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
      categories = []..shuffle();
    });
  }

  _onCategoryClick(categoryName) {
    // 根据分类名去查询相关prompt
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
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.white),
                    onPressed: _refreshWordCloud,
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
                  onCategoryClick: _onCategoryClick,
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
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                child: Row(
                  children: [
                    SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RecordPromptTutorial(), // 目标页面
                                ),
                              );
                            },
                            child: Text(
                              '如何编写高效记录提示词？',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 12, // 链接文字更大
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          SizedBox(height: 4), // 间距
                          Text(
                            '每次记录消耗一枚时光币',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10, // 说明文字略小
                            ),
                          ),
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
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/common/provider.dart';
import '/common/record/record.dart';

class RecordTypeBottomSheet extends StatefulWidget {
  final Function(String) onOptionSelected;

  const RecordTypeBottomSheet({super.key, required this.onOptionSelected});

  @override
  _RecordTypeBottomSheetState createState() => _RecordTypeBottomSheetState();
}

class _RecordTypeBottomSheetState extends State<RecordTypeBottomSheet>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  late TabController _tabController;

  List<Map<String, dynamic>> allOptions = []; // 存放所有分类选项
  List<Map<String, dynamic>> commonOptions = []; // 存放常用分类选项

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this); // 初始化 TabController，长度为 2，表示有两个 Tab
    _fetchDayrecord();
  }

  void _fetchDayrecord() {
    final dayrecord = Provider.of<AppDataProvider>(context, listen: false)
        .getData('dayrecord');

    // 假设 `recordTypeOptions` 是原始的所有选项
    setState(() {
      isLoading = false;
      allOptions = recordTypeOptions; // 将所有选项赋值给 allOptions
      commonOptions = recordTypeOptions
          .where((option) => option['isCommon'] == true)
          .toList(); // 过滤常用选项
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: Colors.white, // 设置背景颜色为白色
          body: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 8),
              // TabBar 和 TabBarView
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '常用'),
                  Tab(text: '所有'),
                  Tab(text: '记录'),
                ],
              ),
              const SizedBox(height: 8),
              // 使用 Expanded 来让 TabBarView 占满剩余高度
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRecordGrid(allOptions), // 显示所有分类
                    _buildRecordGrid(commonOptions), // 显示常用分类
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 创建展示记录类型选项的 Wrap
  Widget _buildRecordGrid(List<Map<String, dynamic>> options) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // 增加外部 padding
      child: Wrap(
        alignment: WrapAlignment.center, // 使记录项在水平上居中
        spacing: 16, // 横向间距
        runSpacing: 16, // 纵向间距
        children: options.map((option) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context);
              widget.onOptionSelected(option['type']);
            },
            child: IntrinsicWidth(
              // 让每个项的宽度自适应
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 16), // 增加内边距
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16), // 增加圆角
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // 让 Row 根据内容宽度自适应
                  crossAxisAlignment: CrossAxisAlignment.center, // 使图标和文字垂直居中
                  children: [
                    Image.asset(
                      option['logo'],
                      width: 16, // 缩小图标的大小
                      height: 16, // 缩小图标的大小
                    ),
                    const SizedBox(width: 8), // 图标与文字之间的间距
                    Text(
                      option['label'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12, // 缩小字体大小
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis, // 防止文字溢出
                      textAlign: TextAlign.center, // 文字居中显示
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

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

class _RecordTypeBottomSheetState extends State<RecordTypeBottomSheet> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDayrecord();
  }

  void _fetchDayrecord() {
    final dayrecord =
        Provider.of<AppDataProvider>(context, listen: false).getData('dayrecord');

    setState(() {
      isLoading = false;
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
          backgroundColor: Colors.transparent,
          body: Scrollbar(
            thickness: 1, // 滚动条的厚度
            radius: const Radius.circular(4), // 圆角滚动条
            child: SingleChildScrollView( // 包裹最外层，支持滚动
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
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
                    GridView.builder(
                      shrinkWrap: true, // 让 GridView 自适应内容大小
                      padding: EdgeInsets.zero, // 去掉 GridView 默认的边距
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 每行 2 列
                        crossAxisSpacing: 12, // 横向间距
                        mainAxisSpacing: 12, // 纵向间距
                      ),
                      itemCount: recordTypeOptions.length,
                      itemBuilder: (context, index) {
                        final option = recordTypeOptions[index];

                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            widget.onOptionSelected(option['type']);
                          },
                          child: Container(
                            height: 64, // 设置固定的高度
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade100,
                                  blurRadius: 4.0,
                                  spreadRadius: 0.5,
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  option['logo'],
                                  width: 32,
                                  height: 32,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        option['label'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        option['description'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        softWrap: true, // 允许换行
                                        overflow: TextOverflow.visible, // 不使用省略号
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

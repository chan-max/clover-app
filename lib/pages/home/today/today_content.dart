import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/common/provider.dart';
import '/common/api.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import './bottom_input_section.dart';
import './top_menu.dart'; // 引入功能区组件

class TodayContent extends StatelessWidget {
  void _deleteRecord(BuildContext context, String recordId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData.dark(), // 使用深色主题
          child: AlertDialog(
            backgroundColor: Colors.black, // 设置背景为黑色
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // 设置圆角
              side: BorderSide(
                color: Colors.grey[700]!, // 设置灰色边框
                width: 1, // 边框宽度
              ),
            ),
            elevation: 8, // 设置阴影
            title: Text(
              '确认删除',
              style: TextStyle(
                color: Colors.white, // 设置标题文字为白色
              ),
            ),
            content: Text(
              '你确定要删除这条记录吗？此操作无法撤销。',
              style: TextStyle(
                color: Colors.white, // 设置内容文字为白色
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 取消删除
                },
                child: Text(
                  '取消',
                  style: TextStyle(
                    color: Colors.white, // 设置取消按钮文字为白色
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  var dayRecord = Provider.of<AppDataProvider>(context, listen: false).getData('dayrecord');
                  var pid = dayRecord['id'];

                  Map<String, dynamic> postData = {
                    'pid': pid,
                    'id': recordId,
                  };
                  try {
                    await deleteDayrecordDetail(postData);
                    // 检查组件是否仍然挂载
                    if (context.mounted) {
                      await Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();
                      TDToast.showText('记录已删除', context: context);
                      Navigator.of(context).pop(); // 关闭对话框
                    }
                  } catch (e) {
                    // 检查组件是否仍然挂载
                    if (context.mounted) {
                      TDToast.showText('删除失败', context: context);
                    }
                  }
                },
                child: Text(
                  '删除',
                  style: TextStyle(
                    color: Colors.red, // 设置删除按钮文字为红色
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appDataProvider = Provider.of<AppDataProvider>(context);
    final userInfo = appDataProvider.getData('userInfo');

    if (userInfo == null) {
      return Center(child: CircularProgressIndicator(color: Color(0xFF00F5E1)));
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFF000000),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 功能区
          TopMenu(
            onButton1Pressed: () {
              // 跳转到页面1
              Navigator.pushNamed(context, '/page1');
            },
            onButton2Pressed: () {
              // 跳转到页面2
              Navigator.pushNamed(context, '/page2');
            },
            onButton3Pressed: () {
              // 跳转到页面3
              Navigator.pushNamed(context, '/page3');
            },
          ),
          SizedBox(height: 16), // 添加间距
          Expanded(
            child: Consumer<AppDataProvider>(
              builder: (context, appDataProvider, child) {
                var dayRecord = appDataProvider.getData('dayrecord');
                List<Map<String, dynamic>> records = [];

                if (dayRecord['record'] != null) {
                  records = List<Map<String, dynamic>>.from(dayRecord['record']);
                }

                var length = dayRecord['record']?.length ?? 0;

                return ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  children: [
                    Text(
                      '今日记录 $length 条',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                    SizedBox(height: 16),
                    records.isEmpty
                        ? Container(
                            width: double.infinity,
                            height: 400,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/img/banner/nodata.png',
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  '今天还没有记录哦，快来添加吧！',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF888888),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: records.map((record) {
                              Widget customContent;
                              switch (record['type']) {
                                case 'sleep':
                                  customContent = Text(
                                    '睡眠质量: ${record['quality'] ?? '未知'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                    ),
                                  );
                                  break;
                                case 'mood':
                                  customContent = Text(
                                    '心情指数: ${record['moodLevel'] ?? '未知'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                    ),
                                  );
                                  break;
                                case 'diet':
                                  customContent = Text(
                                    '饮食情况: ${record['mealDetails'] ?? '未知'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                    ),
                                  );
                                  break;
                                case 'exercise':
                                  customContent = Text(
                                    '运动时长: ${record['duration'] ?? '未知'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                    ),
                                  );
                                  break;
                                case 'fragment':
                                  customContent = Text(
                                    '碎片: ${record['duration'] ?? '未知'}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF666666),
                                    ),
                                  );
                                  break;
                                default:
                                  customContent = SizedBox();
                              }

                              return Container(
                                margin: EdgeInsets.only(bottom: 12),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: Offset(0, 4),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '时间: ${record['createTime'] ?? '未知'}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF666666),
                                            ),
                                          ),
                                          Text(
                                            '内容: ${record['content'] ?? '无内容'}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF666666),
                                            ),
                                          ),
                                          customContent,
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Color(0xFFFF2D55)),
                                      onPressed: () {
                                        _deleteRecord(context, record['id']);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ],
                );
              },
            ),
          ),
          BottomInputSection(),
        ],
      ),
    );
  }
}
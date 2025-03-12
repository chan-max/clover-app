import 'package:clover/views/topBar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 引入日期格式化工具
import 'package:provider/provider.dart';
import '/common/provider.dart';
import '/common/api.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import './bottom_input_section/bottom_input_section.dart';
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
                  var dayRecord =
                      Provider.of<AppDataProvider>(context, listen: false)
                          .getData('dayrecord');
                  var pid = dayRecord['id'];

                  Map<String, dynamic> postData = {
                    'pid': pid,
                    'id': recordId,
                  };
                  try {
                    await deleteDayrecordDetail(postData);
                    // 检查组件是否仍然挂载
                    if (context.mounted) {
                      await Provider.of<AppDataProvider>(context, listen: false)
                          .fetchDayRecord();
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

  void _showRecordDetails(BuildContext context, Map<String, dynamic> record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 允许高度根据内容扩展
      backgroundColor: Colors.transparent, // 背景透明
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75, // 弹层高度为屏幕高度的 75%
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black87, Colors.black54], // 渐变背景
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), // 顶部圆角
              topRight: Radius.circular(20),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16), // 内边距
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 拖动条
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[700], // 拖动条颜色
                    borderRadius: BorderRadius.circular(2), // 圆角
                  ),
                ),
              ),
              SizedBox(height: 20), // 间距
              // 记录详情标题
              Text(
                '记录详情',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20), // 间距
              // 记录内容
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 时间
                      Text(
                        '时间: ${record['createTime'] ?? '未知时间'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 12), // 间距
                      // 内容
                      Text(
                        '内容: ${record['content'] ?? '无内容'}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 12), // 间距
                      Text(
                        '${record}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 12), // 间距
                      // 根据类型显示额外信息
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12), // 间距
              // 操作按钮
              // 操作按钮
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4), // 左右留出 20 的间距
                child: SizedBox(
                  width: double.infinity, // 宽度占满
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context), // 关闭弹层
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent, // 按钮背景色
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // 圆角
                      ),
                      padding: EdgeInsets.symmetric(vertical: 8), // 内边距
                    ),
                    child: Text(
                      '关闭',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
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
      appBar: CustomAppBar(),
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFF000000),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 功能区
          // TopMenu(
          //   onButton1Pressed: () {
          //     // 跳转到页面1
          //     Navigator.pushNamed(context, '/page1');
          //   },
          //   onButton2Pressed: () {
          //     // 跳转到页面2
          //     Navigator.pushNamed(context, '/page2');
          //   },
          //   onButton3Pressed: () {
          //     // 跳转到页面3
          //     Navigator.pushNamed(context, '/page3');
          //   },
          // ),
          SizedBox(height: 16), // 添加间距
          Expanded(
            child: Stack(
              children: [
                // 今日记录数量（固定在顶部）
                Positioned(
                  top: 0,
                  left: 16,
                  right: 16,
                  child: Consumer<AppDataProvider>(
                    builder: (context, appDataProvider, child) {
                      var dayRecord = appDataProvider.getData('dayrecord');
                      var length = dayRecord['record']?.length ?? 0;

                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black, // 背景色
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '今日记录 ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                              TextSpan(
                                text: '$length',
                                style: TextStyle(
                                  fontSize: 24, // 数字部分更大
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00F5E1), // 数字部分颜色更突出
                                ),
                              ),
                              TextSpan(
                                text: ' 条',
                                style: TextStyle(
                                  fontSize: 16, // “条”字保持原大小
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 记录列表
                Padding(
                  padding: EdgeInsets.only(top: 60), // 为顶部固定内容留出空间
                  child: Consumer<AppDataProvider>(
                    builder: (context, appDataProvider, child) {
                      var dayRecord = appDataProvider.getData('dayrecord');
                      List<Map<String, dynamic>> records = [];

                      if (dayRecord['record'] != null) {
                        records =
                            List<Map<String, dynamic>>.from(dayRecord['record'])
                                .reversed
                                .toList();
                      }

                      return ListView(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
                        children: [
                          if (records.isEmpty)
                            Container(
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
                          else
                            Column(
                              children: records.map((record) {
                                // 格式化时间
                                String formattedTime = '未知时间';
                                if (record['createTime'] != null) {
                                  DateTime dateTime =
                                      DateTime.parse(record['createTime']);
                                  formattedTime = DateFormat('yyyy-MM-dd HH:mm')
                                      .format(dateTime);
                                }

                                Widget customContent;
                                switch (record['type']) {
                                  case 'sleep':
                                    customContent = Text(
                                      '睡眠质量: ${record['quality'] ?? '未知'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF888888),
                                      ),
                                    );
                                    break;
                                  case 'mood':
                                    customContent = Text(
                                      '心情指数: ${record['moodLevel'] ?? '未知'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF888888),
                                      ),
                                    );
                                    break;
                                  case 'diet':
                                    customContent = Text(
                                      '饮食情况: ${record['mealDetails'] ?? '未知'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF888888),
                                      ),
                                    );
                                    break;
                                  case 'exercise':
                                    customContent = Text(
                                      '运动时长: ${record['duration'] ?? '未知'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF888888),
                                      ),
                                    );
                                    break;
                                  case 'fragment':
                                    customContent = Text(
                                      '碎片: ${record['duration'] ?? '未知'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF888888),
                                      ),
                                    );
                                    break;
                                  default:
                                    customContent = SizedBox();
                                }

                                return GestureDetector(
                                  onTap: () {
                                    _showRecordDetails(context, record);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 6), // 缩小间距
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 12), // 缩小内边距
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                formattedTime,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF888888),
                                                ),
                                              ),
                                              SizedBox(height: 4), // 缩小间距
                                              Text(
                                                record['content'] ?? '无内容',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(
                                                      0xFFFFFFFF), // 内容文字为白色
                                                ),
                                              ),
                                              SizedBox(height: 4), // 缩小间距
                                              customContent,
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Color(
                                                  0x66ff0000)), // 删除按钮颜色改为浅灰色
                                          iconSize: 20, // 缩小图标大小
                                          onPressed: () {
                                            _deleteRecord(
                                                context, record['id']);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          BottomInputSection(),
        ],
      ),
    );
  }
}

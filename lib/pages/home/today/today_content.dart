import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/components/record_type_bottom_sheet.dart';
import '/common/provider.dart';
import '/common/api.dart';
import '/common/record/record.dart';


class TodayContent extends StatelessWidget {
  Future<Map<String, dynamic>> _getUserInfo(BuildContext context) async {
    final appDataProvider = Provider.of<AppDataProvider>(context, listen: true);
    final userInfo = await appDataProvider.getData('userInfo');
    return userInfo ?? {};
  }

  

void _deleteRecord(BuildContext context, String recordId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('确认删除'),
        content: Text('你确定要删除这条记录吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 取消删除
            },
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // 关闭对话框
              var dayRecord = Provider.of<AppDataProvider>(context, listen: false).getData('dayrecord');
              var pid = dayRecord['id'];

              Map<String, dynamic> postData = {
                'pid': pid,
                'id': recordId,
              };

              try {
                await deleteDayrecordDetail(postData);
                Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('记录已删除', style: TextStyle(color: Colors.white)),
                    backgroundColor: Color(0xFF00F5E1),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('删除失败: $e', style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
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

    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String formattedDayOfWeek = DateFormat('EEEE').format(DateTime.now());

    return Scaffold(
      backgroundColor: Color(0xFF000000),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 300.0,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: Color(0xFF000000),
              flexibleSpace: Padding(
                padding: const EdgeInsets.all(0.0),
                child: FlexibleSpaceBar(
                  centerTitle: true,
                  collapseMode: CollapseMode.parallax,
                  title: LayoutBuilder(
                    builder: (context, constraints) {
                      double top = constraints.biggest.height;
                      if (top <= kToolbarHeight) {
                        return Text(
                          "今天的记录",
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      } else {
                        return SizedBox();
                      }
                    },
                  ),
                  background: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          color: Color(0xFF1A1A1A),
                        ),
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.2,
                            child: Image.asset(
                              "assets/img/banner/today_banner.jpg",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '今天是：$formattedDate',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '星期$formattedDayOfWeek',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFAAAAAA),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ];
        },
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
                    children: [
                      SizedBox(height: 36),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showBottomSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF222222), // Teal background
                    foregroundColor: Colors.black, // Black text/icon
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999.0), // Rounded corners
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, size: 16,color: Color.fromRGBO(255, 255, 255, .7),),
                      SizedBox(width: 4),
                      Text(
                        '添加记录',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, .7),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
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
    );
  }

void _showBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black, // 背景设置为黑色
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.95, // 让弹窗接近全屏
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // 适配键盘弹出
          left: 16.0,
          right: 16.0,
          top: 20.0,
        ),
        child: _BottomSheetContent(),
      );
    },
  );
}
}


class _BottomSheetContent extends StatefulWidget {
  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<_BottomSheetContent> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 200), () {
      _focusNode.requestFocus(); // 让输入框自动获取焦点
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "请输入内容",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '在这里输入...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: Colors.grey[900], // 深灰色背景
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed:  () async {

               String inputText = _controller.text.trim(); // 获取输入框的值并去除首尾空格

                if (inputText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('请输入内容')),
                  );
                  return;
                }

                var params = {
                  'content': inputText, // 传递输入的内容
                  'type': 'prompt', // 可以添加其他字段，比如记录类型
                };

                await addDayRecordDetail(null, params);

                // 更新数据
                Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('日记保存成功')),
                );

                Navigator.pop(context); // 关闭 BottomSheet

          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: Size(double.infinity, 48),
          ),
          child: Text("确认"),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
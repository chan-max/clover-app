import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/common/provider.dart';
import '/common/api.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';

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
                    TDToast.showText('记录已删除', context: context);
                } catch (e) {
                    TDToast.showText('删除失败', context: context);
            
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
            _BottomInputSection(),
          ],
        ),
      ),
    );
  }
}
class _BottomInputSection extends StatefulWidget {
  @override
  _BottomInputSectionState createState() => _BottomInputSectionState();
}

class _BottomInputSectionState extends State<_BottomInputSection> {
  final TextEditingController _controller = TextEditingController();

  
  bool _isInputVisible = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addRecord() async {
    String inputText = _controller.text.trim();

    if (inputText.isEmpty) {

        TDToast.showWarning('请输入内容',
            direction: IconTextDirection.horizontal, context: context);
      return;
    }

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
        _isInputVisible = false; // 添加成功后关闭输入框和按钮
      });
    } catch (e) {
      TDToast.showText('添加失败请重试', context: context);
    }
  }

  void _showInputSection() {
    setState(() {
      _isInputVisible = true;
    });
  }

  void _closeInputSection() {
    setState(() {
      _isInputVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 蒙层
        if (_isInputVisible)
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeInputSection, // 点击蒙层时关闭
              behavior: HitTestBehavior.opaque, // 确保蒙层可以捕获点击事件
              child: Container(
                color: Colors.black.withOpacity(0.6), // 黑色带透明度
              ),
            ),
          ),
        // 输入框和按钮区域
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isInputVisible)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '记录你的每一天',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '写下今天的感受或计划，让每一天都更有意义。',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.emoji_emotions, color: Colors.greenAccent),
                            SizedBox(width: 8),
                            Text(
                              '心情记录',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.blueAccent),
                            SizedBox(width: 8),
                            Text(
                              '每日计划',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.orangeAccent),
                            SizedBox(width: 8),
                            Text(
                              '成就打卡',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: _showInputSection, // 点击输入框时显示按钮
                  child: TextField(
                    controller: _controller,
                    enabled: _isInputVisible, // 如果输入框已显示，则启用输入
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '添加记录...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                if (_isInputVisible)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addRecord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                        ),
                        child: Text("保存记录"),
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
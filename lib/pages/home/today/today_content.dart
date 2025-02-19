import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/components/record_type_bottom_sheet.dart';
import '/common/provider.dart';
import '/common/api.dart';
import '/common/record/record.dart';

class TodayContent extends StatelessWidget {
  Future<Map<String, dynamic>> _getUserInfo(BuildContext context) async {
    final appDataProvider =
        Provider.of<AppDataProvider>(context, listen: false);
    final userInfo = await appDataProvider.getData('userInfo');
    return userInfo ?? {};
  }

  void _deleteRecord(BuildContext context, String recordId) async {
    var dayRecord = Provider.of<AppDataProvider>(context, listen: false)
        .getData('dayrecord');
    var pid = dayRecord['id'];

    Map<String, dynamic> postData = {
      'pid': pid,
      'id': recordId,
    };

    try {
      await deleteDayrecordDetail(postData);
      Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('记录已删除')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appDataProvider = Provider.of<AppDataProvider>(context);
    final userInfo = appDataProvider.getData('userInfo');

    if (userInfo == null) {
      return Center(child: CircularProgressIndicator());
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String formattedDayOfWeek = DateFormat('EEEE').format(DateTime.now());

    return Scaffold(
      backgroundColor: Color(0xffffffff),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 300.0,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: Color(0xffffffff),
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
                            color: Colors.black,
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
                          color: Color(0xFF1CAE81),
                        ),
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.1,
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
                                    color: Colors.white),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '星期$formattedDayOfWeek',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white70),
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
        body: Consumer<AppDataProvider>(
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
                            fontSize: 18, fontWeight: FontWeight.bold),
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
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => _showBottomSheet(context),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Color(0xFF00D0A9),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 32, vertical: 12),
                                    ),
                                    child: Text(
                                      '添加记录',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: records.map((record) {
                                // 查找 type 对应的项
                                var typeInfo = recordTypeOptions.firstWhere(
                                  (item) => item['type'] == record['type'],
                                  orElse: () => {
                                    'label': '未知',
                                    'logo': 'assets/img/default.png'
                                  },
                                );

                                // 预留 customContent 部分，根据不同 type 显示自定义内容
                                Widget customContent;

                                switch (record['type']) {
                                  case 'sleep':
                                    customContent = Text(
                                      '睡眠质量: ${record['quality'] ?? '未知'}',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    );
                                    break;
                                  case 'mood':
                                    customContent = Text(
                                      '心情指数: ${record['moodLevel'] ?? '未知'}',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    );
                                    break;
                                  case 'diet':
                                    customContent = Text(
                                      '饮食情况: ${record['mealDetails'] ?? '未知'}',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    );
                                    break;
                                  case 'exercise':
                                    customContent = Text(
                                      '运动时长: ${record['duration'] ?? '未知'}',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    );
                                    break;
                                  case 'fragment':
                                    customContent = Text(
                                      '碎片: ${record['duration'] ?? '未知'}',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    );
                                    break;
                                  default:
                                    customContent = SizedBox(); // 默认不显示内容
                                }

                                return Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Color.fromRGBO(149, 157, 165, 0.2),
                                        offset: Offset(0, 8),
                                        blurRadius: 24,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      // 显示缩略图
                                      Image.asset(
                                        typeInfo['logo'],
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(width: 12),

                                      // 文字信息
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              typeInfo['label'], // 显示标题
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              '时间: ${record['createTime'] ?? '未知'}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey),
                                            ),
                                            Text(
                                              '内容: ${record['content'] ?? '无内容'}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey),
                                            ),
                                            // 显示特定的内容
                                            customContent,
                                          ],
                                        ),
                                      ),

                                      // 删除按钮
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBottomSheet(context),
        label: const Text(
          '记录',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
        ),
        icon: const Icon(Icons.edit_calendar, size: 20, color: Colors.white),
        backgroundColor: const Color(0xFF00D0A9),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return RecordTypeBottomSheet(
          onOptionSelected: (selectType) {
            String routeName = '${selectType}Record';
            if (routeName.isNotEmpty) {
              Navigator.pushNamed(context, routeName);
            }
          },
        );
      },
    );
  }
}

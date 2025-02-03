import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 用于格式化日期
import 'package:provider/provider.dart'; // 引入provider
// 用于获取加入日期
import '/components/record_type_bottom_sheet.dart';
import '/common/provider.dart'; // 假设你已经创建了这个Provider类

class TodayContent extends StatelessWidget {
  Future<Map<String, dynamic>> _getUserInfo(BuildContext context) async {
    // 这里假设你是从 provider 或其他异步方法获取用户信息
    final appDataProvider =
        Provider.of<AppDataProvider>(context, listen: false);
    final userInfo = await appDataProvider.getData('userInfo');
    print(123);
    print(userInfo);
    return userInfo ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppDataProvider>(
        builder: (context, appDataProvider, child) {
          // 从 Provider 获取数据
          final userInfo = appDataProvider.getData('userInfo');

          if (userInfo == null) {
            // 如果 userInfo 还没有加载出来，可以显示一个加载中的界面
            return Center(child: CircularProgressIndicator());
          }

          String formattedDate =
              DateFormat('yyyy-MM-dd').format(DateTime.now());
          String formattedDayOfWeek = DateFormat('EEEE').format(DateTime.now());

          // 获取创建时间和生日
          final createTime = userInfo['createTime'] != null
              ? DateTime.parse(userInfo['createTime'])
              : DateTime.now(); // 默认当前时间
          final birthday = userInfo['birthday'] != null
              ? DateTime.parse(userInfo['birthday'])
              : DateTime(1999, 1, 1); // 默认生日：1999年1月1日

          final today = DateTime.now();
          final daysSinceBirth = today.difference(birthday).inDays;
          final daysUsingApp = today.difference(createTime).inDays;

          return SafeArea(
            child: Column(
              children: [
                // 深绿色背景 + 圆角
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.35, // 增加绿色区域高度
                  decoration: BoxDecoration(
                    color: Color(0xFF00D0A9), // 更深的绿色
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16), // 圆角
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 30.0),
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
                          style: TextStyle(fontSize: 18, color: Colors.white70),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '你加入的日期：${DateFormat('yyyy-MM-dd').format(createTime)}',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '你一共活了：$daysSinceBirth 天',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '你已经使用该App：$daysUsingApp 天',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                // 下半部分，白色背景
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '今天的总结',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        _buildTodaySummary(), // 自定义显示今天的总结
                        SizedBox(height: 30),

                        // 获取并展示dayrecord中的记录数据
                        Text(
                          '记录列表',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),

                        // 使用Consumer监听数据变化并刷新UI
                        Consumer<AppDataProvider>(
                          builder: (context, appDataProvider, child) {
                            final dayrecord =
                                appDataProvider.getData('dayrecord');

                            if (dayrecord == null ||
                                dayrecord['record'] == null ||
                                dayrecord['record'].isEmpty) {
                              return Center(child: Text('暂无记录'));
                            }

                            return ListView.builder(
                              shrinkWrap: true, // 让列表适应高度
                              itemCount: dayrecord['record'].length,
                              itemBuilder: (context, index) {
                                var record = dayrecord['record'][index];
                                return ListTile(
                                  leading: Icon(Icons.access_alarm),
                                  title: Text('记录类型: ${record['type']}'),
                                  subtitle: Text(
                                      '时间: ${record['time'] ?? '未知'}'), // 如果有时间字段
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showBottomSheet(context);
        },
        label: const Text(
          '记录',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        icon: const Icon(
          Icons.edit_calendar,
          size: 20,
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF00D0A9),
      ),
    );
  }

  Widget _buildTodaySummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.directions_walk, color: Colors.green),
            SizedBox(width: 8),
            Text('步数: 5000步'),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.access_alarm, color: Colors.blue),
            SizedBox(width: 8),
            Text('睡眠: 7小时30分钟'),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.fitness_center, color: Colors.orange),
            SizedBox(width: 8),
            Text('体重: 70kg'),
          ],
        ),
      ],
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return RecordTypeBottomSheet(
          onOptionSelected: (selectType) {
            String routeName;
            switch (selectType) {
              case 'sleep':
                routeName = 'sleepRecord';
                break;
              case 'period':
                routeName = 'periodRecord';
                break;
              case 'mood':
                routeName = 'moodRecord';
                break;
              case 'feeling':
                routeName = 'feelingRecord';
                break;
              case 'height':
                routeName = 'heightRecord';
                break;
              case 'weight':
                routeName = 'weightRecord';
                break;
              default:
                routeName = '';
                break;
            }
            if (routeName.isNotEmpty) {
              Navigator.pushNamed(context, routeName);
            }
          },
        );
      },
    );
  }
}

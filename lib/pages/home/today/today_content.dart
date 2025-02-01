import 'package:flutter/material.dart';
import '/components/record_type_bottom_sheet.dart';
import 'package:intl/intl.dart'; // 用于格式化日期
import 'package:shared_preferences/shared_preferences.dart'; // 用于获取加入日期

class TodayContent extends StatelessWidget {
  Future<String> _getJoinDate() async {
    final prefs = await SharedPreferences.getInstance();
    // 假设你已存储用户加入时间为 joinDate
    return prefs.getString('joinDate') ?? '未知'; // 如果没有找到加入时间，显示未知
  }

  Future<int> _getTotalDays() async {
    final prefs = await SharedPreferences.getInstance();
    final joinDateString = prefs.getString('joinDate');
    if (joinDateString != null) {
      final joinDate = DateTime.parse(joinDateString);
      final today = DateTime.now();
      return today.difference(joinDate).inDays; // 返回总天数
    }
    return 0; // 如果没有加入日期，返回0
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future.wait([_getJoinDate(), _getTotalDays()]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('加载失败'));
          }

          String joinDate = snapshot.data![0];
          int totalDays = snapshot.data![1];

          String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
          String formattedDayOfWeek = DateFormat('EEEE').format(DateTime.now());

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '今天是：$formattedDate',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '星期$formattedDayOfWeek',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  Text(
                    '你加入的日期：$joinDate',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '你一共活了：${totalDays}天',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 30),
                  Text(
                    '今天的总结',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  _buildTodaySummary(), // 自定义显示今天的总结
                  SizedBox(height: 30),
                ],
              ),
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
    // 这里你可以根据需求自定义今天的总结显示，可以展示从数据库获取的数据
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

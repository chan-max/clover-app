import 'package:flutter/material.dart';
import 'package:clover/common/api.dart';
import './dayrecord_card.dart'; // 引入 DayRecordCard 组件
import './sleep_card.dart'; // 引入 SleepCard 组件
import './168.dart';
import './health_score.dart';
import './banner_title.dart';
import './latesty7.dart';

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  dynamic dayrecord; // 存储 dayrecord 数据
  bool isLoading = true; // 控制加载状态

  @override
  void initState() {
    super.initState();
    _fetchDayrecord(); // 页面初始化时调用接口获取数据
  }

  // 获取 dayrecord 数据
  Future<void> _fetchDayrecord() async {
    try {
      final res = await getDayrecord(); // 调用接口获取数据
      setState(() {
        dayrecord = res; // 更新 dayrecord 数据
        isLoading = false; // 设置为加载完成
      });
    } catch (e) {
      setState(() {
        isLoading = false; // 如果发生错误，结束加载状态
      });
      print('Error fetching dayrecord: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      body: SingleChildScrollView(
        // 包裹 Column 使其支持滚动
        child: Column(
          children: <Widget>[
            SizedBox(height: 4),
            BannerTitle(),
            HealthScoreCard(),
            RecentWeekCard(),
            DayRecordCard(), // 传入 dayrecord 数据到 DayRecordCard
            SleepCard(dayrecord: dayrecord), // 新添加的 SleepCard
            // 添加六个卡片，并布局为一行两个
            SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12.0), // 设置卡片组的左右 padding
              child: GridView.builder(
                shrinkWrap: true, // 不限制高度，适应内容
                physics:
                    NeverScrollableScrollPhysics(), // 禁用滚动，已由 SingleChildScrollView 控制
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 每行两个卡片
                  crossAxisSpacing: 2, // 水平方向的间距
                  mainAxisSpacing: 2, // 垂直方向的间距
                ),
                itemCount: 6, // 设置卡片的数量为6
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 0, // 移除默认的阴影
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // 设置圆角
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white, // 设置卡片背景色为白色
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromRGBO(149, 157, 165, 0.2),
                            offset: const Offset(0, 4),
                            blurRadius: 16,
                            spreadRadius: 0,
                          ),
                        ], // 应用自定义阴影
                      ),
                      child: Center(
                        child: Text(
                          'Card ${index + 1}', // 设置每个卡片的内容
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Diet168Card(),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

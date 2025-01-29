import 'package:flutter/material.dart';
import 'dart:math';

class BannerTitle extends StatefulWidget {
  @override
  _BannerTitleState createState() => _BannerTitleState();
}

class _BannerTitleState extends State<BannerTitle> {
  late String dailyTip;

  // 提前定义一些每日建议
  final List<String> tips = [
    '多喝水，每天至少8杯水！',
    '保持充足睡眠，每晚至少7小时！',
    '每天坚持30分钟运动！',
    '饮食均衡，多吃水果和蔬菜！',
    '保护眼睛，每隔1小时休息一下！',
    '保持好心情，试着深呼吸放松！',
    '每天坚持阅读10分钟，丰富自己！',
    '注意坐姿，避免长时间久坐！',
  ];

  @override
  void initState() {
    super.initState();
    // 每次组件加载时随机获取一个每日建议
    dailyTip = getDailyTip();
  }

  // 获取每日建议逻辑
  String getDailyTip() {
    final random = Random();
    return tips[random.nextInt(tips.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.lightBlueAccent.shade100,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '今日建议',
            style: TextStyle(
              fontSize: 16, // 更小的标题文字
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6), // 调整间距
          Text(
            dailyTip,
            style: const TextStyle(
              fontSize: 14, // 更小的正文文字
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:clover/pages/home/record/sleep/record.dart';
// 导入首页
// 导入登录页面
import 'package:clover/pages/home/record/period/record.dart';
import 'package:clover/pages/home/record/mood/record.dart';
import 'package:clover/pages/home/record/feeling/record.dart';
import 'package:clover/pages/home/record/height/record.dart';
import 'package:clover/pages/home/record/height/height_analyze.dart';
import 'package:clover/pages/home/record/weight/record.dart';
// 所有页面路由管理
class AppRoutes {
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      'sleepRecord': (context) => SleepRecordPage(),
      'periodRecord': (context) => PeriodRecordPage(),
      'moodRecord': (context) => MoodRecordPage(),
      'feelingRecord': (context) => FeelingRecordPage(),
      'heightRecord': (context) => HeightRecordPage(),
      'heightAnalyze': (context) => HeightAnalyzePage(),
      'weightRecord': (context) => WeightRecordPage(),
      // 可以根据需求添加其他页面的路由
    };
  }
}

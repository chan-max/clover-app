import 'package:clover/common/api.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

class SleepCard extends StatelessWidget {
  final dynamic dayrecord;

  const SleepCard({super.key, required this.dayrecord});

  Future<Map<String, dynamic>> fetchAnalyzeData() async {
    var res = await getMyAnalyze();
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(149, 157, 165, 0.2),
            offset: const Offset(0, 4),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部标题部分
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/img/record/sleep.png',
                      width: 12,
                      height: 12,
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      '我的睡眠',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF428B38),
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Color(0xffdddddd),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 使用 FutureBuilder 显示接口数据
            FutureBuilder<Map<String, dynamic>>(
              future: fetchAnalyzeData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("加载失败"));
                } else {
                  final analyzeData = snapshot.data ?? {};
                  final suggestedSleepTimeHour =
                      analyzeData['suggestedSleepTimeHour'] ?? 23;
                  final suggestedSleepTimeMinute =
                      analyzeData['suggestedSleepTimeMinute'] ?? 8;
                  final suggestedSleepDuration =
                      analyzeData['suggestedSleepDuration'] ?? 8.0;
                  final totalSleep = dayrecord['totalSleep'] ?? 6.5;
                  final sleepPercentage =
                      (totalSleep / suggestedSleepDuration * 100).clamp(0, 100);

                  return Padding(
                    padding: const EdgeInsets.all(8.0), // 统一设置内容的 padding
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 左侧文字内容
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 最佳睡眠时间
                            Row(
                              children: [
                                const Text(
                                  '最佳睡眠时间: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  '${suggestedSleepTimeHour.toString().padLeft(2, '0')}:${suggestedSleepTimeMinute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF428B38),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // 最佳睡眠时长
                            Row(
                              children: [
                                const Text(
                                  '最佳睡眠时长: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  '$suggestedSleepDuration小时',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xffFF8C00),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // 右侧环形图
                        Padding(
                          padding: const EdgeInsets.all(16), // 设置额外的左侧 padding
                          child: SizedBox(
                            height: 60, // 更小的环形图高度
                            width: 60, // 更小的环形图宽度
                            child: PieChart(
                              PieChartData(
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 0,
                                centerSpaceRadius: 24,
                                sections: showingSections(sleepPercentage),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections(double sleepPercentage) {
    return [
      PieChartSectionData(
        color: const Color(0xFF428B38),
        value: sleepPercentage,
        title: '${sleepPercentage.toInt()}%',
        radius: 20, // 环形扇形更小
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: const Color(0xffF4F5F6),
        value: 100 - sleepPercentage,
        title: '${(100 - sleepPercentage).toInt()}%',
        radius: 20,
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ];
  }
}

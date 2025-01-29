import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '/common/provider.dart';

class RecentWeekCard extends StatelessWidget {
  const RecentWeekCard({super.key});

  @override
  Widget build(BuildContext context) {
    // 从 Provider 获取最近 7 天的记录数据
    var dayRecordLatest7 =
        Provider.of<AppDataProvider>(context).getData('dayrecordLatest7');

    // 将 dayRecordLatest7 转换为柱状图所需的数据
    List<BarChartGroupData> barChartData =
        dayRecordLatest7?.map<BarChartGroupData>((record) {
              String date = record['date'] ?? "未知日期";
              int count = record['record']?.length ?? 0; // 获取 record 字段的长度

              return BarChartGroupData(
                x: dayRecordLatest7.indexOf(record), // x轴表示天数
                barRods: [
                  // 前景柱状图
                  BarChartRodData(
                    toY: count.toDouble(),
                    color: const Color(0xff00D0A9), // 设置柱状图颜色
                    width: 18, // 调整柱状图宽度
                    borderRadius: BorderRadius.circular(16), // 让柱状图有圆角
                    backDrawRodData: BackgroundBarChartRodData(
                      toY: double.infinity, // 设置背景条形图的最大高度
                      color: const Color(0xffE0E0E0), // 浅灰色背景，始终显示
                    ),
                  ),
                ],
              );
            })?.toList() ??
            [];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // 卡片外间距
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(149, 157, 165, 0.2),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12), // 卡片内间距调整为 12
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 使用 Row 包裹标题和按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "最近七天记录数量",
                  style: TextStyle(
                    fontSize: 12, // 标题文字变小
                    fontWeight: FontWeight.bold,
                    color: Color(0xff666666),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: Color(0xff333333),
                    size: 20, // 图标变小
                  ),
                  onPressed: () {
                    // 点击按钮后可以执行的功能，比如打开更多功能
                    print("更多功能按钮被点击");
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 增加一个容器，控制柱状图的宽度为80%
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.8, // 设置容器的宽度为80%（这里可以调整）
                height: 160, // 设置柱状图的高度
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(
                      show: false, // 去掉所有网格线
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false), // 不显示左侧的纵向标题
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false), // 不显示右侧的纵向标题
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false), // 不显示上侧的纵向标题
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false), // 去掉所有边框线
                    barGroups: barChartData, // 设置柱状图数据
                    alignment: BarChartAlignment.spaceBetween, // 设置柱状图之间的间隔
                  ),
                ),
              ),
            ),

            // **增加一段居中的文字**：用于提示记录的活跃度
            const SizedBox(height: 12), // 间隔
            Center(
              child: Text(
                "记录活跃度：保持积极，持续记录生活！", // 提示内容
                style: TextStyle(
                  fontSize: 14, // 设置字体大小
                  color: const Color(0xff666666), // 设置字体颜色
                  fontWeight: FontWeight.w500, // 设置字体粗细
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthScoreCard extends StatelessWidget {
  const HealthScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xffffffff),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(149, 157, 165, 0.15),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: const HealthScore(),
      ),
    );
  }
}

class HealthScore extends StatelessWidget {
  const HealthScore({super.key});

  @override
  Widget build(BuildContext context) {
    final double healthScore = 85; // 综合健康评分
    final double bodyScore = 80; // 身体评分
    final double moodScore = 90; // 心情评分
    final double luckScore = 75; // 运气评分

    return Column(
      children: [
        // 顶部大圆环
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "综合健康评分",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 150, // 缩小大圆环尺寸
              height: 150, // 缩小大圆环尺寸
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      borderData: FlBorderData(show: false),
                      centerSpaceRadius: 50, // 更小的中心空白部分
                      sectionsSpace: 0,
                      sections: _buildPieChartSections(
                        healthScore,
                        const Color(0xFF428B38),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      "$healthScore",
                      style: const TextStyle(
                        fontSize: 24, // 调整字体大小
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF428B38),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 下方三个小圆环居中显示
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // 居中对齐
          children: [
            _buildSmallPieChart(bodyScore, const Color(0xffA8E6A6), '健康'),
            const SizedBox(width: 24), // 添加间距
            _buildSmallPieChart(moodScore, const Color(0xffF7A8B8), '心情'),
            const SizedBox(width: 24), // 添加间距
            _buildSmallPieChart(luckScore, const Color(0xffFFE28A), '运气'),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // 构建单个小圆环
  Widget _buildSmallPieChart(double score, Color color, String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 40, // 更小的圆环尺寸
          height: 40, // 更小的圆环尺寸
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  borderData: FlBorderData(show: false),
                  centerSpaceRadius: 14, // 更小的中心空白部分
                  sectionsSpace: 0,
                  sections: _buildPieChartSections(score, color),
                ),
              ),
              Center(
                child: Text(
                  "$score",
                  style: TextStyle(
                    fontSize: 10, // 更小的字体
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 8, // 调整子标题字体大小
            fontWeight: FontWeight.bold,
            color: Colors.grey, // 设置为浅灰色
          ),
        ),
      ],
    );
  }

  // 构建饼图数据
  List<PieChartSectionData> _buildPieChartSections(double score, Color color) {
    return [
      PieChartSectionData(
        color: color,
        value: score,
        radius: 6, // 圆环宽度更窄
        showTitle: false, // 不显示环上的文字
      ),
      PieChartSectionData(
        color: const Color(0xffF4F5F6),
        value: 100 - score,
        radius: 6, // 圆环宽度更窄
        showTitle: false, // 不显示环上的文字
      ),
    ];
  }
}

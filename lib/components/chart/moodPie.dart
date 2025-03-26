import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MoodPieSection {
  final Color color;
  final double value;
  final String label;
  final double radius;

  MoodPieSection({
    required this.color,
    required this.value,
    required this.label,
    required this.radius,
  });
}

class MoodPie extends StatefulWidget {
  final List<MoodPieSection>? sections;

  const MoodPie({Key? key, this.sections}) : super(key: key);

  @override
  State<MoodPie> createState() => _MoodPieState();
}

class _MoodPieState extends State<MoodPie> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final sections = widget.sections ?? _defaultSections();
    return AspectRatio(
      aspectRatio: 1.3,
      child: Column(
        children: <Widget>[
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse?.touchedSection == null) {
                          touchedIndex = -1;
                        } else {
                          touchedIndex =
                              pieTouchResponse!.touchedSection!.touchedSectionIndex;
                        }
                      });
                    },
                  ),
                  startDegreeOffset: 180,
                  borderData: FlBorderData(show: true),
                  sectionsSpace: 2,
                  centerSpaceRadius: 0,
                  sections: _buildSections(sections),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(List<MoodPieSection> sections) {
    return List.generate(
      sections.length,
      (i) {
        final section = sections[i];
        final isTouched = i == touchedIndex;
        final fontSize = isTouched ? 18.0 : 16.0;
        final radius = isTouched ? section.radius + 10 : section.radius;

        // 计算百分比
        final total = sections.fold<double>(0, (sum, item) => sum + item.value);
        final percentage = (section.value / total * 100).toStringAsFixed(1);

        return PieChartSectionData(
          color: section.color,
          value: section.value,
          title: section.label, // 内部显示 label
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titlePositionPercentageOffset: 0.55, // 内部文字位置
          borderSide: isTouched
              ? const BorderSide(color: Colors.white, width: 6)
              : const BorderSide(color: Colors.transparent),
          badgeWidget: _buildBadgeWidget(percentage, section.color, isTouched), // 外部文字
          badgePositionPercentageOffset: 0.98, // 外部文字位置
        );
      },
    );
  }

  Widget _buildBadgeWidget(String percentage, Color color, bool isTouched) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$percentage%',
        style: TextStyle(
          fontSize: isTouched ? 14.0 : 12.0,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<MoodPieSection> _defaultSections() {
    return [
      MoodPieSection(color: Colors.blue, value: 30, label: 'Happy', radius: 80),
      MoodPieSection(color: Colors.yellow, value: 25, label: 'Excited', radius: 70),
      MoodPieSection(color: Colors.pink, value: 20, label: 'Sad', radius: 60),
      MoodPieSection(color: Colors.green, value: 25, label: 'Calm', radius: 75),
    ];
  }
}
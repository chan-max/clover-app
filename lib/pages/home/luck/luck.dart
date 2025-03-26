import 'package:flutter/material.dart';

class LuckPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '运势预测',
          style: TextStyle(fontSize: 13),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Center(
            child: Text(
              '', // 可替换为其他内容
              style: TextStyle(color: Colors.white),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  _showLuckPicker(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  '记录运气',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLuckPicker(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, animation, secondaryAnimation) {
        return LuckPickerDialog();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 300),
    );
  }
}

class LuckPickerDialog extends StatefulWidget {
  @override
  _LuckPickerDialogState createState() => _LuckPickerDialogState();
}

class _LuckPickerDialogState extends State<LuckPickerDialog> {
  int selectedLuck = 5; // 默认中间值

  final List<Map<String, dynamic>> luckData = List.generate(
    11, // 0-10，共11项
    (index) {
      Color color;
      if (index <= 2) {
        color = Color.lerp(Color(0xFFD32F2F), Color(0xFFFF5722), index / 2)!;
      } else if (index <= 5) {
        color = Color.lerp(Color(0xFFFF5722), Color(0xFFFFCA28), (index - 2) / 3)!;
      } else if (index <= 8) {
        color = Color.lerp(Color(0xFFFFCA28), Color(0xFF81C784), (index - 5) / 3)!;
      } else {
        color = Color.lerp(Color(0xFF81C784), Color(0xFF4CAF50), (index - 8) / 2)!;
      }
      return {
        'luckValue': index,
        'color': color,
        'label': index == 0
            ? '运气极差'
            : index == 10
                ? '运气爆棚'
                : '运气$index',
      };
    },
  );

  @override
  Widget build(BuildContext context) {
    final currentLuck = luckData[selectedLuck];
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 2.0, // 增大半径，让渐变更自然
            colors: [
              currentLuck['color'].withOpacity(1.0), // 中心颜色鲜明
              currentLuck['color'].withOpacity(0.6), // 边缘颜色淡化
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '选择你的运气',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 40),
                  Container(
                    height: 200,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          double sensitivity = 0.05;
                          selectedLuck -= (details.delta.dx * sensitivity).round();
                          selectedLuck = selectedLuck.clamp(0, 10);
                        });
                      },
                      child: Center(
                        child: Text(
                          currentLuck['label'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
              Positioned(
                left: 20,
                top: 20,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 90, // 调整位置，保证按钮不重叠
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 12,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 18),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 22),
                    ),
                    child: Slider(
                      value: selectedLuck.toDouble(),
                      min: 0,
                      max: 10,
                      divisions: 10,
                      activeColor: currentLuck['color'],
                      inactiveColor: currentLuck['color'].withOpacity(0.6),
                      label: currentLuck['label'],
                      onChanged: (double value) {
                        setState(() {
                          selectedLuck = value.round();
                        });
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 20,
                child: ElevatedButton(
                  onPressed: () {
                    // 模拟发送数据到后台，打印当前选择的运气值
                    print('选择的运气值: ${currentLuck['label']}');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.6), // 半透明背景
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 20), // 增大按钮高度
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    '记录运气',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

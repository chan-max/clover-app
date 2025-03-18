import 'package:clover/pages/home/today/yestoday/yestoday.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clover/common/notification.dart';

class TopMenu extends StatelessWidget {
  final VoidCallback onButton1Pressed;
  final VoidCallback onButton2Pressed;
  final VoidCallback onButton3Pressed;

  const TopMenu({
    Key? key,
    required this.onButton1Pressed,
    required this.onButton2Pressed,
    required this.onButton3Pressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Color(0xFF000000),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              Get.to(YestodayAnalyzePage());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00F5E1),
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('昨日分析'),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("通知"),
                  content: Text("这是一个内部通知"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("关闭"),
                    ),
                  ],
                ),
              );

              NotificationService().showNotification(
                id: 1,
                title: "提醒",
                body: "你的任务需要完成啦！",
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00F5E1),
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('页面2'),
          ),
          ElevatedButton(
            onPressed: onButton3Pressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00F5E1),
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('页面3'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class RecordPromptTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('记录词指南', style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 页面简介
              Text(
                '欢迎来到记录词的编写教程！',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '在此，我们将帮助您了解如何编写高效的生活记录提示词。',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),

              // 提示词编写技巧
              Text(
                '1. 清晰简洁：',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '确保您的提示词简单明了，避免过多的冗余信息。一个简洁的提示词可以帮助我们更好地进行分析。',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 20),

              // 提示词的例子
              Text(
                '2. 提供足够的细节：',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '好的提示词应包括一些足够的细节，这样我们才能提供更精确的分析。例如：“今天去健身房锻炼了1小时，感到很有活力。”',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 20),

              // 提示用户提供更好的记录
              Text(
                '3. 提供真实的反映：',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '请确保每个记录都是真实的反映，这有助于我们更准确地分析您的生活模式。',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 20),

              // 自我责任感和鼓励
              Text(
                '4. 自我责任感：',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '我们希望您可以编写高质量的提示词，以便于我们用于分析和统计，对自己的每一个生活记录负责。这样能帮助您更好地理解自己的生活状况，也让我们的分析更加精准。',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 40),

              // 结尾提示
              Text(
                '感谢您的参与，愿我们一起走向更健康、更有规律的生活！',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

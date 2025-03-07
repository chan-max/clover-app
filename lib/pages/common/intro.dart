import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:get/get.dart';

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "欢迎来到应用",
          body: "记录你的每一天，让生活更有意义。",
          image: _buildImage('assets/onboarding1.png'),
          decoration: _pageDecoration(),
        ),
        PageViewModel(
          title: "智能数据分析",
          body: "帮你分析每日数据，提供健康建议。",
          image: _buildImage('assets/onboarding2.png'),
          decoration: _pageDecoration(),
        ),
        PageViewModel(
          title: "开启你的旅程",
          body: "现在就开始使用，让生活更有条理。",
          image: _buildImage('assets/onboarding3.png'),
          decoration: _pageDecoration(),
          footer: ElevatedButton(
            onPressed: () =>  Get.back(),
            child: Text("开始使用"),
          ),
        ),
      ],
      onDone: () => Get.offAndToNamed('/home'),
      onSkip: () =>  Get.offAndToNamed('/home'), // 跳过按钮
      showSkipButton: true,
      skip: Text("跳过", style: TextStyle(fontWeight: FontWeight.bold)),
      next: Icon(Icons.arrow_forward),
      done: Text("完成", style: TextStyle(fontWeight: FontWeight.bold)),
      dotsDecorator: DotsDecorator(
        size: Size(8.0, 8.0),
        color: Colors.grey,
        activeSize: Size(16.0, 8.0),
        activeColor: Colors.greenAccent,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    return Center(child: Image.asset(path, width: 250));
  }

  PageDecoration _pageDecoration() {
    return PageDecoration(
      titleTextStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      bodyTextStyle: TextStyle(fontSize: 16),
      imagePadding: EdgeInsets.all(20),
    );
  }
}

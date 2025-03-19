import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clover/pages/user/signin.dart';
import 'package:clover/pages/home/profile/profile_content.dart';
import 'package:clover/pages/home/settings_content.dart';
import 'package:clover/pages/home/calendar/calendar.dart';
import 'package:clover/pages/home/notifications_content.dart';
import 'package:provider/provider.dart';
import '/pages/home/today/today_content.dart';
import '/common/provider.dart';
import 'package:clover/views/topBar.dart';
import 'package:clover/pages/common/intro.dart'; // 引导页
import 'package:get/get.dart';
import 'package:clover/pages/home/health/health.dart';
import 'package:clover/pages/home/mood/mood.dart';
import 'package:clover/pages/home/luck/luck.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    TodayContent(),
    HealthPage(),
    MoodPage(),
    LuckPage(),
    // ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    print('initState');
    Provider.of<AppDataProvider>(context, listen: false).init();

    // _checkIntroScreen();
  }

  Future<void> _checkIntroScreen() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasSeenIntro = prefs.getBool('hasSeenIntro') ?? false;

    if (!hasSeenIntro) {
      await prefs.setBool('hasSeenIntro', true);
      Get.toNamed('/intro');
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF000000),
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFFFFFFFF),
        unselectedItemColor: const Color(0xFF666666),
        selectedFontSize: 9.0,
        unselectedFontSize: 7.0,
        selectedIconTheme: const IconThemeData(size: 28.0),
        unselectedIconTheme: const IconThemeData(size: 24.0),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note),
            label: '今日记录',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.health_and_safety),
            label: '健康管理',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sentiment_satisfied),
            label: '心情日记',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph),
            label: '运势分析',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.person),
          //   label: '个人中心',
          // ),
        ],
        selectedLabelStyle: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          color: Color(0xFF666666),
        ),
      ),
    );
  }
}

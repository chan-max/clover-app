import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clover/pages/user/signin.dart';
import 'package:clover/pages/home/profile_content.dart';
import 'package:clover/pages/home/settings_content.dart';
import 'package:clover/pages/home/statistics_content.dart';
import 'package:clover/pages/home/notifications_content.dart';
// 导入新创建的组件
import 'package:provider/provider.dart';
import '/pages/home/today//today_content.dart';
import '/common/provider.dart'; // 导入你的 AppDataProvider

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // 页面列表，部分页面显示自定义导航栏
  final List<Widget> _pages = [
    TodayContent(), // 不显示导航栏
    StatisticsContent(), // 不包含导航栏
    NotificationsContent(), // 不包含导航栏
    SettingsContent(), // 不包含导航栏
    ProfileContent(), // 不包含导航栏
  ];

  @override
  void initState() {
    super.initState();
    // 在页面初始化时调用 AppDataProvider 的 init 方法来加载数据
    Provider.of<AppDataProvider>(context, listen: false).init();
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
    final currentChild = _pages[_currentIndex];

    // 如果当前子组件是 Scaffold，并且包含 appBar，则使用子组件的导航栏
    PreferredSizeWidget? appBar;
    if (currentChild is Scaffold && currentChild.appBar != null) {
      appBar = currentChild.appBar as PreferredSizeWidget; // 子组件的导航栏
    } else {
      appBar = AppBar(
        title: const Text('四叶草'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      );
    }

    return Scaffold(
        // appBar: appBar,
        backgroundColor: Color(0xffffffff),
        body: SafeArea(
          // 在这里包裹 SafeArea
          child: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xffffffff),
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: const Color(0xFF00D0A9),
          unselectedItemColor: const Color(0xFFdddddd),
          selectedFontSize: 9.0, // 增大选中标签文字的大小
          unselectedFontSize: 7.0,
          selectedIconTheme: IconThemeData(size: 26.0), // 增大选中图标的大小
          unselectedIconTheme: IconThemeData(size: 24.0), // 设定未选中图标的大小
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_calendar),
              label: '记录今天',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: '回忆过去',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.widgets),
              label: '更多工具',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '设置',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '个人中心',
            ),
          ],
        ));
  }
}

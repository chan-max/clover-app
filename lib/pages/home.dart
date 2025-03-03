import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clover/pages/user/signin.dart';
import 'package:clover/pages/home/profile/profile_content.dart';
import 'package:clover/pages/home/settings_content.dart';
import 'package:clover/pages/home/calendar/calendar.dart';
import 'package:clover/pages/home/notifications_content.dart';
import 'package:provider/provider.dart';
import '/pages/home/today/today_content.dart';
import '/common/provider.dart'; // 导入你的 AppDataProvider

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  
  int _currentIndex = 0;

  // 页面列表，部分页面显示自定义导航栏
  final List<Widget> _pages = [
    TodayContent(),
    DayRecordPage(),
    NotificationsContent(),
    SettingsContent(),
    ProfilePage(),
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

    // 定义 AppBar，黑色背景，白色文字，TikTok风格的退出按钮
    PreferredSizeWidget? appBar = AppBar(
      backgroundColor: const Color(0xFF000000), // 黑色背景
      elevation: 0, // 移除阴影，与TikTok简洁风格一致
      title: const Text(
        '四叶草',
        style: TextStyle(
          color: Color(0xFFFFFFFF), // 白色标题
          fontWeight: FontWeight.bold,
          fontSize: 14
        ),
      ),
      actions: [
        IconButton(
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          color: Color(0xFF00F5E1), // TikTok风格的青色
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      backgroundColor: const Color(0xFF000000), // 深黑色背景
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF000000), // 黑色导航栏
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: const Color(0xFFFFFFFF), // TikTok青色选中色
        unselectedItemColor: const Color(0xFF666666), // 未选中为灰色
        selectedFontSize: 10.0, // 选中文字稍大
        unselectedFontSize: 8.0, // 未选中文字较小
        selectedIconTheme: const IconThemeData(size: 28.0), // 选中图标更大
        unselectedIconTheme: const IconThemeData(size: 24.0), // 未选中图标
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
        selectedLabelStyle: const TextStyle(
          color: Color(0xFFFFFFFF), // 选中标签为白色
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          color: Color(0xFF666666), // 未选中标签为灰色
        ),
      ),
    );
  }
}
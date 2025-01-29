import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clover/pages/user/signin.dart';
import 'package:clover/pages/home/home_content/home_content.dart';
import 'package:clover/pages/home/profile_content.dart';
import 'package:clover/pages/home/settings_content.dart';
import 'package:clover/pages/home/statistics_content.dart';
import 'package:clover/pages/home/notifications_content.dart';
import '/components/record_type_bottom_sheet.dart'; // 导入新创建的组件
import 'package:provider/provider.dart';
import '/common/provider.dart'; // 导入你的 AppDataProvider

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // 页面列表，部分页面显示自定义导航栏
  final List<Widget> _pages = [
    HomeContent(), // 不显示导航栏
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

  // 弹出底部列表的方法
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 让弹窗高度自适应
      builder: (BuildContext context) {
        return RecordTypeBottomSheet(
          onOptionSelected: (selectType) {
            // 构建跳转的路径
            String routeName;
            switch (selectType) {
              case 'sleep':
                routeName = 'sleepRecord';
                break;
              // 更多 case 语句可以根据需求添加
              case 'period':
                routeName = 'periodRecord';
                break;
              case 'mood':
                routeName = 'moodRecord';
                break;
              case 'feeling':
                routeName = 'feelingRecord';
                break;
              case 'height':
                routeName = 'heightRecord';
                break;
              case 'weight':
                routeName = 'weightRecord';
                break;
              default:
                routeName = '';
                break;
            }
            // 使用 Navigator.pushNamed 跳转到对应的路由
            Navigator.pushNamed(context, routeName);
          },
        );
      },
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
        selectedFontSize: 8.0,
        unselectedFontSize: 8.0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list_rounded),
            label: '功能',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: '通知',
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showBottomSheet(context); // 点击浮动按钮弹出底部选择列表
        },
        label: const Text('记录',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xffffffff))),
        icon: const Icon(
          Icons.edit_calendar,
          size: 20, // 设置图标大小
          color: Color(0xffffffff), // 设置图标颜色
        ),
        backgroundColor: const Color(0xFF00D0A9),
      ),
    );
  }
}

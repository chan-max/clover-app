import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '底部导航栏示例',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // 当前选中的索引

  // 页面列表
  final List<Widget> _pages = [
    Center(child: Text('首页')),
    Center(child: Text('分类')),
    Center(child: Text('设置')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // 更新当前选中的索引
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('底部导航栏示例'),
      ),
      body: _pages[_currentIndex], // 显示当前页面
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: '分类',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
        currentIndex: _currentIndex, // 当前选中的索引
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped, // 点击事件处理
      ),
    );
  }
}

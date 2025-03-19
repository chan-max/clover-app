import 'package:clover/common/notification.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 用于本地存储
import './pages/user/signin.dart'; // 导入登录页面
import './pages/home.dart'; // 导入首页
import 'package:clover/common/api.dart';
import 'package:provider/provider.dart';
import '/common/provider.dart';
import 'package:get/get.dart';
import 'package:clover/common/router_get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  // 在 main 中初始化 NotificationService
  await NotificationService().init(
    onNotificationClicked: (response) {
      print('Notification clicked with payload: ${response.payload}');
    },
  );

  print('app run');

  runApp(
    NotificationWrapper(
      child: ChangeNotifierProvider(
        create: (context) => AppDataProvider(),
        child: MyApp(isLoggedIn: token != null),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn; // 是否已登录

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: '四叶草',
      navigatorKey: navigatorKey, // 绑定全局 NavigatorKey
      theme: ThemeData(
        primaryColor: Color(0xFF00D0A9), // 设置主题色为 #ea4c89
        appBarTheme: AppBarTheme(
          color: Color(0xFF00D0A9), // 设置 AppBar 的背景色为主题色
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFF00D0A9), // 按钮背景色为主题色
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              // primary: Color(0xFFEA4C89), // 设置 ElevatedButton 背景色为主题色
              // onPrimary: Colors.white, // 设置文字颜色为白色
              ),
        ),
        textTheme: TextTheme(
            // bodyText1: TextStyle(color: Colors.black), // 设置文本颜色
            // bodyText2: TextStyle(color: Colors.black), // 设置文本颜色
            ),
      ),
      home: isLoggedIn ? HomePage() : SignInScreen(),
      // : LoginPage(), // 根据状态切换页面
      getPages: AppPage.routes,
    );
  }
}

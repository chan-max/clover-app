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
import 'package:clover/common/js.dart';
// import 'package:clover/common/websocket.dart'; // 导入 WebSocketService


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

  // 初始化 WebSocketService
  // final webSocketService = WebSocketService();
  // await webSocketService.init();

  print('app run');

  runApp(
    NotificationWrapper(
      child: ChangeNotifierProvider(
        create: (context) => AppDataProvider(),
        child: MyApp(
          isLoggedIn: token != null,
          // webSocketService: webSocketService
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn; // 是否已登录
  // final WebSocketService webSocketService; // 添加 WebSocketService

  const MyApp({
    super.key,
    required this.isLoggedIn,
    // required this.webSocketService
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // 添加生命周期监听
    WidgetsBinding.instance.addObserver(this);

    // 设置 WebSocket 连接状态回调
    // widget.webSocketService.onConnectionStatusChanged = (isConnected) {
    //   print('WebSocket 连接状态: ${isConnected ? '在线' : '离线'}');
    //   // 可在此处添加其他逻辑，例如通知 Provider 更新状态
    // };
  }

  @override
  void dispose() {
    // 清理资源
    WidgetsBinding.instance.removeObserver(this);
    // widget.webSocketService.disconnect();
    super.dispose();
  }
  

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        // 应用回到前台，确保 WebSocket 连接
        // if (!widget.webSocketService.isConnected) {
        //   widget.webSocketService.init();
        // }
        break;
      case AppLifecycleState.paused:
        // 应用进入后台，保持 WebSocket 连接（可根据需求断开）
        print('应用进入后台');
        break;
      case AppLifecycleState.detached:
        // 应用关闭，断开 WebSocket
        // widget.webSocketService.disconnect();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: '四叶草',
      navigatorKey: navigatorKey, // 绑定全局 NavigatorKey
      theme: ThemeData(
        primaryColor: Color(0xFF00D0A9), // 设置主题色为 #00D0A9
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
      home: widget.isLoggedIn ? HomePage() : SignInScreen(),
      getPages: AppPage.routes,
    );
  }
}

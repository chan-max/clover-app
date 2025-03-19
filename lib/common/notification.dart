import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

/// Flutter 本地通知封装（支持 Android & iOS）
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// 初始化通知
  Future<void> init({
    Function(NotificationResponse)? onNotificationClicked,
  }) async {
    tz.initializeTimeZones();
    requestAndroidPermissions();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onNotificationClicked,
    );

    await requestPermissions();
  }

  /// 请求通知权限（⚠️ iOS 必须调用）
  Future<void> requestPermissions() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// 发送立即通知
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel',
      'General Notifications',
      channelDescription: '记录 通知',
      importance: Importance.min,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// 发送定时通知
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final tz.TZDateTime tzScheduledTime =
        tz.TZDateTime.from(scheduledTime, tz.local);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'App 定时通知',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 取消所有通知
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}

/// 处理通知点击并显示弹窗的包装器
class NotificationWrapper extends StatefulWidget {
  final Widget child;

  const NotificationWrapper({super.key, required this.child});

  @override
  State<NotificationWrapper> createState() => _NotificationWrapperState();
}

class _NotificationWrapperState extends State<NotificationWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 只在冷启动时检查通知
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialNotification();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('AppLifecycleState changed to: $state');
    if (state == AppLifecycleState.resumed) {
      print('App resumed from background at ${DateTime.now()}');
      // 不再检查通知，只打印日志
    }
  }

  Future<void> _checkInitialNotification() async {
    final NotificationAppLaunchDetails? details =
        await FlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();
    if (details != null && details.didNotificationLaunchApp) {
      print('有消息详情');
      final response = details.notificationResponse;
      if (response != null) {
        print('有消息回应');
        _handleNotificationClick(response);
      }
    } else {
      print('没有消息详情');
    }
  }

  void _handleNotificationClick(NotificationResponse response) {
    String? payload = response.payload;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('通知'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('通知被点击'),
            if (payload != null) ...[
              SizedBox(height: 10),
              Text('Payload: $payload'),
            ] else ...[
              SizedBox(height: 10),
              Text('No payload provided'),
            ],
          ],
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// 请求 Android 通知权限
Future<void> requestAndroidPermissions() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}
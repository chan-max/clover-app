import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';


class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  bool _isConnected = false;
  Function(bool)? onConnectionStatusChanged;

  static const String _serverUrl = 'ws://your-server-url:port'; // 替换为你的服务器地址
  static const int heartbeatInterval = 30;
  static const int reconnectDelay = 5;

  // 初始化并连接
  Future<void> init() async {
    await _connect();
  }

  Future<void> _connect() async {
    try {
      _channel = IOWebSocketChannel.connect(
        Uri.parse(_serverUrl),
        pingInterval: const Duration(seconds: heartbeatInterval),
      );

      _isConnected = true;
      _startHeartbeat();
      onConnectionStatusChanged?.call(true);
      print('WebSocket 已连接');

      _channel!.stream.listen(
        (message) {
          print('收到消息: $message');
          if (message == 'heartbeat') {
            _channel!.sink.add('heartbeat');
          }
        },
        onError: (error) {
          print('WebSocket 错误: $error');
          _handleDisconnect();
        },
        onDone: () {
          print('WebSocket 连接关闭');
          _handleDisconnect();
        },
      );
    } catch (e) {
      print('WebSocket 连接失败: $e');
      _handleDisconnect();
      _reconnect();
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    _stopHeartbeat();
    onConnectionStatusChanged?.call(false);
    _reconnect();
  }

  void disconnect() {
    _stopHeartbeat();
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: heartbeatInterval),
      (_) {
        if (_isConnected) {
          _channel?.sink.add('heartbeat');
        }
      },
    );
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _reconnect() {
    if (_isConnected) return;
    Future.delayed(const Duration(seconds: reconnectDelay), () {
      print('尝试重连...');
      _connect();
    });
  }

  void sendMessage(String message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(message);
    } else {
      print('无法发送消息，未连接到服务器');
    }
  }

  bool get isConnected => _isConnected;
}
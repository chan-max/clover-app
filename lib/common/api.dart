import 'dart:convert';
import 'dart:developer';
import 'package:clover/pages/user/signin.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clover/common/storage.dart';
import 'dart:io'; // 导入 dart:io 以便处理证书相关内容
import 'package:uuid/uuid.dart';

// 定义一个全局的 NavigatorKey
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const bool kReleaseMode = bool.fromEnvironment('dart.vm.product');
final String _baseUrl = kReleaseMode
    ? 'https://1s.design:4321/api' // 生产环境地址
    // : 'https://localhost:4321/api'; // 开发环境地址
    : 'https://192.168.1.103:4321/api'; // 开发环境地址

BaseOptions options = BaseOptions(
  baseUrl: _baseUrl,
  connectTimeout: Duration(milliseconds: 5000), // 连接超时时间
  receiveTimeout: Duration(milliseconds: 3000), // 接收超时时间
  contentType: 'application/json', // 请求体的内容类型
  responseType: ResponseType.json, // 期望的响应数据类型
  headers: {}, // 请求头
);

class DioHttp {
  final Dio _dio = Dio(options);

  DioHttp() {
    _dio.options.baseUrl = _baseUrl;

    if (kReleaseMode) {
      print("现在是生产环境: $_baseUrl");
    } else {
      print("现在是开发环境: $_baseUrl");
    }

    // 添加请求前拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        print("请求前拦截触发");
        print('Request Url: ${options.uri}');

        // 从 SharedPreferences 获取 token
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        // 如果 token 存在，将其添加到请求头中
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options); // 继续请求
      },
    ));

    // 添加请求后拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) async {
        print("结束请求拦截触发");
        print('Response Status Code: ${response.statusCode}');

        if (response.statusCode == 401 ?? response.data['code'] == 401) {
          print("用户身份过期，跳转到登录页面");
          // 清除本地 token
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('token');

          // 提示用户身份过期
          final context = navigatorKey.currentState?.context;
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('用户身份过期，请重新登录'),
                duration: Duration(seconds: 3),
              ),
            );
          }

          // 跳转到登录页面
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => SignInScreen()),
            (route) => false,
          );
        }

        return handler.next(response); // 继续后续操作
      },
      onError: (DioException error, handler) async {
        print("请求错误latest: ${error.message}");
        // 在这里判断状态码是否为 401
        if (error.response?.statusCode == 401) {
          print("请求错误，身份过期");

          // 清除本地 token
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('token');

          // 提示用户身份过期
          final context = navigatorKey.currentState?.context;
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('用户身份过期，请重新登录'),
                duration: Duration(seconds: 3),
              ),
            );
          }

          // 跳转到登录页面
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => SignInScreen()),
            (route) => false,
          );
        }

        return handler.next(error); // 继续抛出错误
      },
    ));

    // 配置 HttpClientAdapter 以忽略 SSL 证书验证
    // (_dio.httpClientAdapter as dynamic).onHttpClientCreate = (client) {
    //   client.badCertificateCallback =
    //       (X509Certificate cert, String host, int port) {
    //     // 忽略证书验证
    //     return true;
    //   };
    // };
  }

  // GET 请求
  Future<Map<String, dynamic>> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        return jsonDecode(response.data.toString());
      }
    } catch (e) {
      print("GET 请求出错: $e");
      rethrow;
    }
  }

  // POST 请求
  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else {
        return jsonDecode(response.data.toString());
      }
    } catch (e) {
      print("POST 请求出错: $e");
      rethrow;
    }
  }
}

final dioHttp = DioHttp();

// 登录方法
dynamic signin(String username, String password) async {
  final response = await dioHttp.post('/auth/login', data: {
    'username': username,
    'password': password,
  });

  if (response['data'].isNotEmpty) {
    final token = response['data']['token'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  } else {
    throw Exception('login error');
  }

  return response;
}

// 注册方法
dynamic signup(String username, String password) async {
  final response = await dioHttp.post('/user/signup', data: {
    'username': username,
    'password': password,
  });

  if (response['code'] != 0) {
    throw response['message'] ?? '注册失败';
  }
  return response;
}

// 获取用户信息方法
dynamic getUserInfo() async {
  var res = await dioHttp.post('/user/getUserInfo');
  StorageService.setItem('userInfo', res['data']);
  return res['data'];
}

// 获取 dayrecord 方法
dynamic getDayrecord({String? datekey}) async {
  String url = '/dayrecord';
  if (datekey != null) {
    url += '/$datekey';
  }
  var res = await dioHttp.get(url);
  return res;
}

// 获取我的个人分析数据
dynamic getMyAnalyze() async {
  String url = '/analyze/me';
  var res = await dioHttp.get(url);
  return res['data'];
}

Future<void> addDayRecordDetail(String? date, Map<String, dynamic> post) async {
  try {
    // 初始化 UUID 生成器
    final uuid = Uuid();

    // 构造请求数据
    post = {
      "createTime": DateTime.now().toIso8601String(),
      "updateTime": DateTime.now().toIso8601String(),
      "id": uuid.v4(),
      ...post
    };

    // 拼接 URL
    final String url =
        '/dayrecord/add${date != null && date.isNotEmpty ? "/$date" : ""}';

    // 发起 POST 请求
    final response = await dioHttp.post(url, data: post);

    return response['data'];
  } catch (e) {
    throw Exception(e);
  }
}

Future<dynamic> deleteDayrecordDetail(Map<String, dynamic> post) async {
  String url = '/dayrecord/delete-detail';
  try {
    var response = await dioHttp.post(url, data: post);
    return response['data'];
  } catch (e) {
    print('Error: $e');
    throw Exception('删除失败');
  }
}

Future<dynamic> getMyLatestHeightRecord() async {
  String url = '/height/latest-height-record';
  try {
    var response = await dioHttp.get(
      url,
    );
    return response['data'];
  } catch (e) {}
}

Future<dynamic> getMyHeightRecords() async {
  String url = '/height/height-records';
  try {
    var response = await dioHttp.get(
      url,
    );
    return response['data'];
  } catch (e) {}
}

Future<dynamic> getDayrecordLatest(count) async {
  dynamic url = '/dayrecord/latest/$count';
  try {
    var response = await dioHttp.get(
      url,
    );
    return response['data'];
  } catch (e) {}
}

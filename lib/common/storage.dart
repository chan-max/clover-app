import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // 存储数据
  static Future<void> setItem(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (value is String) {
      await prefs.setString(key, value); // 如果是字符串，直接存储
    } else {
      // 其他类型，先序列化为 JSON 字符串再存储
      String jsonString = jsonEncode(value);
      await prefs.setString(key, jsonString);
    }
  }

  // 获取数据
  static Future<dynamic> getItem(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(key); // 只存储字符串类型

    if (value == null) {
      return null; // 如果 key 不存在，返回 null
    }

    try {
      // 尝试将字符串解析为对象
      return jsonDecode(value);
    } catch (e) {
      // 如果解析失败，说明是普通字符串，直接返回
      return value;
    }
  }

  // 删除存储
  static Future<void> removeItem(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}

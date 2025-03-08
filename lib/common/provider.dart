import 'package:clover/common/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDataProvider extends ChangeNotifier {
  // 用 Map 保存所有数据
  Map<String, dynamic> _data = {

    'dayrecord': {}, // 今日记录
    'dayrecordLatest7': [],
    // 更多的数据字段
    'userInfo': {}, // 用户信息
  };

  // 获取指定数据
  dynamic getData(String key) {
    return _data[key];
  }

  // 更新指定数据
  void updateData(String key, dynamic newData) {
    _data[key] = newData;
    notifyListeners(); // 通知所有依赖该数据的组件
  }

  // 模拟从 API 获取数据（例如获取 dayrecord）
  Future<void> fetchDayRecord({bool notify = true}) async {
    var response = await getDayrecord();
    _data['dayrecord'] = response;
    if(notify){
    notifyListeners(); // 数据更新后通知所有组件
    }
  }

  Future<void> fetchDayRecordLatest7() async {
    var response = await getDayrecordLatest(7);
    _data['dayrecordLatest7'] = response;
    notifyListeners(); // 数据更新后通知所有组件
  }

  Future<void> fetchUserInfo({bool notify = true}) async {
    var response = await getUserInfo();
    _data['userInfo'] = response;

      if(notify){
        notifyListeners(); // 数据更新后通知所有组件
    }
    
  if(_data['userInfo']['shouldComplete'] == 1){
    print('应该完善信息');
    Get.offAndToNamed('/complete');
  }


  }

  // 初始化方法，调用各个数据的加载方法
  Future<void> init() async {
    await Future.wait([
      fetchDayRecord(notify: false),
      fetchUserInfo(notify: false),
    ]);
    notifyListeners(); // 数据更新后通知所有组件
  }
}

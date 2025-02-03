import 'package:flutter/material.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:intl/intl.dart'; // 用于格式化日期
import '/common/api.dart';
import 'package:provider/provider.dart'; // 引入 provider
import '/common/provider.dart';

class SleepRecordPage extends StatefulWidget {
  @override
  _SleepRecordPageState createState() => _SleepRecordPageState();
}

class _SleepRecordPageState extends State<SleepRecordPage> {
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  DateTime selectedDate = DateTime.now(); // 默认日期为今天

  void sendSleepRecord() async {
    if (startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先选择时间范围！')),
      );
      return;
    }

    // 判断是否跨天
    DateTime startDateTime;
    DateTime endDateTime;

    // 如果 startTime > endTime，说明跨天，startTime 与昨天结合，endTime 与今天结合
    if (startTime!.hour > endTime!.hour ||
        (startTime!.hour == endTime!.hour &&
            startTime!.minute > endTime!.minute)) {
      // 将 startTime 与昨天日期结合
      startDateTime = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day - 1, startTime!.hour, startTime!.minute);
      // 将 endTime 与今天日期结合
      endDateTime = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, endTime!.hour, endTime!.minute);
    } else {
      // 如果没有跨天，startTime 和 endTime 都与今天结合
      startDateTime = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, startTime!.hour, startTime!.minute);
      endDateTime = DateTime(selectedDate.year, selectedDate.month,
          selectedDate.day, endTime!.hour, endTime!.minute);
    }

    // 构建假接口请求的数据结构
    Map<String, String> sleepRecord = {
      'type': 'sleep',
      'startTime': DateFormat('yyyy-MM-dd HH:mm:ss').format(startDateTime),
      'endTime': DateFormat('yyyy-MM-dd HH:mm:ss').format(endDateTime),
    };

    // 模拟发送到接口
    await addDayRecordDetail(null, sleepRecord);

    // Add the new sleep record to the provider
    Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('记录成功')),
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // 删除记录的逻辑
  void deleteSleepRecord(String recordId) async {
    // 执行删除操作，假设接口需要传递的是 recordId (比如 startTime)
    // var response = await deleteDayRecordDetail(recordId);

    // if (response != null) {
    //   // 删除成功，刷新记录
    //   Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('删除成功')),
    //   );
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('删除失败')),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    // 获取 dayrecord 数据
    var dayRecord = Provider.of<AppDataProvider>(context).getData('dayrecord');
    
    // 提取所有睡眠记录
    List<Map<String, dynamic>> sleepRecords = [];
    if (dayRecord != null && dayRecord['record'] != null) {
      sleepRecords = List<Map<String, dynamic>>.from(
        dayRecord['record']?.where((record) => record['type'] == 'sleep') ?? [],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleTextStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        title: const Text('记录睡眠'),
        iconTheme: const IconThemeData(color: Colors.grey),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.grey,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '选择您的睡眠日期和时间范围',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await showTimeRangePicker(
                  context: context,
                  strokeWidth: 4,
                  ticks: 24,
                  ticksOffset: 2,
                  ticksLength: 8,
                  handlerRadius: 8,
                  ticksColor: Colors.grey,
                  rotateLabels: false,
                  labels: [
                    "24 h",
                    "3 h",
                    "6 h",
                    "9 h",
                    "12 h",
                    "15 h",
                    "18 h",
                    "21 h"
                  ].asMap().entries.map((e) {
                    return ClockLabel.fromIndex(
                        idx: e.key, length: 8, text: e.value);
                  }).toList(),
                  labelOffset: 30,
                  padding: 55,
                  labelStyle:
                      const TextStyle(fontSize: 18, color: Colors.black),
                  start: const TimeOfDay(hour: 12, minute: 0),
                  end: const TimeOfDay(hour: 15, minute: 0),
                  clockRotation: 180.0,
                  fromText: '睡眠开始',
                  toText: '睡眠结束',
                  snap: true,
                );

                if (result != null) {
                  setState(() {
                    startTime = result.startTime;
                    endTime = result.endTime;
                  });
                }
              },
              child: Text('选择时间范围'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => selectDate(context),
              child: Text('选择日期（默认为今天）按醒来时间为基准'),
            ),
            SizedBox(height: 20),
            if (startTime != null && endTime != null)
              Text(
                '已选择时间: ${startTime!.format(context)} - ${endTime!.format(context)}\n'
                '选择日期: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                style: TextStyle(fontSize: 16),
              ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: sendSleepRecord,
              child: Text('发送记录'),
            ),
            SizedBox(height: 40),
            // 显示 dayrecord 内容
            Text(
              'Day Record 内容:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            if (sleepRecords.isEmpty)
              Text('没有记录', style: TextStyle(fontSize: 16))
            else
              // 显示 sleepRecords 的内容
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: sleepRecords.map((record) {
                  return Container(
                    padding: EdgeInsets.all(8),
                    margin: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '开始时间: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(record['startTime']))}',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '结束时间: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(record['endTime']))}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 10),
                        // 删除按钮
                        ElevatedButton(
                          onPressed: () {
                            // 调用删除逻辑，这里使用 startTime 作为唯一标识
                            deleteSleepRecord(record['startTime']);
                          },
                          style: ElevatedButton.styleFrom(
                            // primary: Colors.red, // 删除按钮使用红色
                          ),
                          child: Text('删除记录'),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

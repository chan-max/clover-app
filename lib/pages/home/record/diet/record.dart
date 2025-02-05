import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 用于格式化日期
import 'package:provider/provider.dart'; // 引入 provider
import '/common/provider.dart';
import '/common/api.dart';

class DietRecordPage extends StatefulWidget {
  @override
  _DietRecordPageState createState() => _DietRecordPageState();
}

class _DietRecordPageState extends State<DietRecordPage> {
  late DateTime _selectedDay;
  TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  // 保存饮食记录
  void _saveDiet() async {
    String content = _contentController.text.isEmpty
        ? '无内容' // 如果没有输入则显示默认文本
        : _contentController.text;

    Map<String, dynamic> dietRecord = {
      'type': 'diet',
      'content': content,
    };

    await addDayRecordDetail(null, dietRecord);

    // 添加新的饮食记录到 provider
    Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('饮食记录保存成功')),
    );
  }

  // 删除饮食记录
  void _deleteRecord(String recordId) async {
    var dayRecord = Provider.of<AppDataProvider>(context, listen: false)
        .getData('dayrecord');
    var pid = dayRecord['id'];

    Map<String, dynamic> postData = {
      'pid': pid,
      'id': recordId,
    };

    try {
      await deleteDayrecordDetail(postData);
      Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('饮食记录已删除')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var dayRecord = Provider.of<AppDataProvider>(context).getData('dayrecord');

    List<Map<String, dynamic>> dietRecords = [];
    if (dayRecord['record'] != null) {
      dietRecords = List<Map<String, dynamic>>.from(
        dayRecord['record']?.where((record) => record['type'] == 'diet') ?? [],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleTextStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        title: const Text('记录饮食'),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 饮食记录表单部分
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '记录 ${DateFormat('yyyy-MM-dd').format(_selectedDay)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.greenAccent,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('饮食内容：', style: TextStyle(color: Colors.greenAccent)),
                    TextField(
                      controller: _contentController,
                      maxLines: 10,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white, // 设置背景色为白色
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.greenAccent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: '请输入饮食内容',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 20),
                    // 保存饮食按钮
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveDiet,
                      child: Text(
                        '保存饮食',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // 饮食记录列表
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: dietRecords.isEmpty
                    ? Text('今日未记录饮食', style: TextStyle(color: Colors.grey))
                    : Column(
                        children: dietRecords.map((record) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '内容：${record['content'] ?? '无内容'}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('确认删除'),
                                        content: Text('你确定要删除这条饮食记录吗？'),
                                        actions: [
                                          TextButton(
                                            child: Text('取消'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          TextButton(
                                            child: Text('删除'),
                                            onPressed: () {
                                              _deleteRecord(record['id']);
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

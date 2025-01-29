import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 用于格式化日期
import 'package:provider/provider.dart'; // 引入 provider
import '/common/provider.dart';
import '/common/api.dart';
class PeriodRecordPage extends StatefulWidget {
  @override
  _PeriodRecordPageState createState() => _PeriodRecordPageState();
}

class _PeriodRecordPageState extends State<PeriodRecordPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  double _flowRate = 1; // 流量滑块的初始值
  double _painRate = 1; // 疼痛滑块的初始值
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // 保存记录
  void _saveRecord() async {
    String description = _descriptionController.text.isEmpty
        ? '无详情' // 如果没有输入则显示默认文本
        : _descriptionController.text;

    Map<String, dynamic> periodRecord = {
      'type': 'period',
      'flowRate': _flowRate,
      'painRate': _painRate, // 添加 painRate 字段
      'description': description, 
    };

    await addDayRecordDetail(null, periodRecord);

    // Add the new period record to the provider
    Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('记录成功')),
    );
  }

  // 删除记录
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
        SnackBar(content: Text('记录已删除')),
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

    List<Map<String, dynamic>> periodRecords = [];
    if (dayRecord['record'] != null) {
      periodRecords = List<Map<String, dynamic>>.from(
        dayRecord['record']?.where((record) => record['type'] == 'period') ?? [],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        title: const Text('记录生理期'),
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
              // 记录表单部分
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
                        color: Colors.pinkAccent,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildSlider(
                      label: '流量：${_flowRate.toInt()}（1: 极少, 5: 极多）',
                      value: _flowRate,
                      onChanged: (value) {
                        setState(() {
                          _flowRate = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    _buildSlider(
                      label: '疼痛强度：${_painRate.toInt()}（1: 无痛, 5: 极痛）',
                      value: _painRate,
                      onChanged: (value) {
                        setState(() {
                          _painRate = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Text('症状：', style: TextStyle(color: Colors.pinkAccent)),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white, // 设置背景色为白色
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.pinkAccent),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: '请输入相关症状（如腹痛）',
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 20),
                    // 保存记录按钮
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveRecord,
                      child: Text(
                        '保存记录',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // 记录列表
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: periodRecords.isEmpty
                    ? Text('今日未记录', style: TextStyle(color: Colors.grey))
                    : Column(
                        children: periodRecords.map((record) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.pink[50],
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '流量：${record['flowRate']}（${record['flowRate'] == 1 ? "极少" : record['flowRate'] == 5 ? "极多" : "中等"}）',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      '疼痛：${record['painRate']}（${record['painRate'] == 1 ? "无痛" : record['painRate'] == 5 ? "极痛" : "中等"}）',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      '症状：${record['description'] ?? '无详情'}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('确认删除'),
                                        content: Text('你确定要删除这条记录吗？'),
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

  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.pinkAccent),
        ),
        Slider(
          value: value,
          min: 1,
          max: 5,
          divisions: 4,
          label: value.toStringAsFixed(0),
          activeColor: Colors.pinkAccent,
          inactiveColor: Colors.grey.shade300,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 用于格式化日期
import 'package:provider/provider.dart'; // 引入 provider
import '/common/provider.dart';
import '/common/api.dart';

class FeelingRecordPage extends StatefulWidget {
  @override
  _FeelingRecordPageState createState() => _FeelingRecordPageState();
}

class _FeelingRecordPageState extends State<FeelingRecordPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  double _feelingRate = 3; // 身体状态滑块的初始值
  double _energyRate = 3; // 能量滑块的初始值
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

    Map<String, dynamic> feelingRecord = {
      'type': 'feeling',
      'feelingRate': _feelingRate,
      'energyRate': _energyRate, // 添加 energyRate 字段
      'description': description,
    };

    await addDayRecordDetail(null, feelingRecord);

    // Add the new feeling record to the provider
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

    List<Map<String, dynamic>> feelingRecords = [];
    if (dayRecord['record'] != null) {
      feelingRecords = List<Map<String, dynamic>>.from(
        dayRecord['record']?.where((record) => record['type'] == 'feeling') ?? [],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleTextStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        title: const Text('记录身体状态'),
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
      body: Column(
        children: [
          // 记录表单部分
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
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
                            color: Colors.blueAccent,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildSlider(
                          label: '身体状态：${_feelingRate.toInt()}（1: 非常差, 5: 非常好）',
                          value: _feelingRate,
                          onChanged: (value) {
                            setState(() {
                              _feelingRate = value;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        _buildSlider(
                          label: '能量：${_energyRate.toInt()}（1: 极低, 5: 极高）',
                          value: _energyRate,
                          onChanged: (value) {
                            setState(() {
                              _energyRate = value;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        Text('描述：', style: TextStyle(color: Colors.blueAccent)),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white, // 设置背景色为白色
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blueAccent),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            hintText: '请输入身体状态描述（如开心、疲倦等）',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // 固定按钮在底部
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24), // 最大圆角（按钮圆角）
                ),
              ),
              onPressed: _saveRecord,
              child: Text(
                '保存记录',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
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
          style: TextStyle(fontSize: 16, color: Colors.blueAccent),
        ),
        Slider(
          value: value,
          min: 1,
          max: 5,
          divisions: 4, // 将滑块分成5个等级
          label: value.toStringAsFixed(0),
          activeColor: Colors.blueAccent,
          inactiveColor: Colors.grey.shade300,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

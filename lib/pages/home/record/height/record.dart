import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_ruler_picker/flutter_ruler_picker.dart';
import '/common/provider.dart';
import '/common/api.dart';

class HeightRecordPage extends StatefulWidget {
  @override
  _HeightRecordPageState createState() => _HeightRecordPageState();
}

class _HeightRecordPageState extends State<HeightRecordPage> {
  late RulerPickerController _rulerPickerController;
  double _currentHeight = 160.0; // 身高初始值

  @override
  void initState() {
    super.initState();
    _rulerPickerController = RulerPickerController(value: _currentHeight);
  }

  @override
  void dispose() {
    _rulerPickerController.dispose();
    super.dispose();
  }

  // 保存记录
  void _saveHeightRecord() async {
    Map<String, dynamic> heightRecord = {
      'type': 'height',
      'height': _currentHeight,
    };

    await addDayRecordDetail(null, heightRecord);

    Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('身高记录保存成功')),
    );
  }

  // 删除记录
  void _deleteHeightRecord(String recordId) async {
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
        const SnackBar(content: Text('记录已删除')),
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

    List<Map<String, dynamic>> heightRecords = [];
    if (dayRecord['record'] != null) {
      heightRecords = List<Map<String, dynamic>>.from(
        dayRecord['record']?.where((record) => record['type'] == 'height') ??
            [],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleTextStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        title: const Text('记录身高'),
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
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '选择您的身高',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "${_currentHeight.toStringAsFixed(1)} cm",
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          RulerPicker(
                            onBuildRulerScaleText: (index, value) {
                              return value.toInt().toString();
                            },
                            controller: _rulerPickerController,
                            ranges: const [
                              RulerRange(begin: 100, end: 250, scale: 0.1),
                            ],
                            onValueChanged: (value) {
                              setState(() {
                                _currentHeight = value as dynamic;
                              });
                            },
                            width: MediaQuery.of(context).size.width,
                            height: 80,
                            rulerMarginTop: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveHeightRecord,
                      child: const Text(
                        '保存记录',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 新增按钮，跳转到 heightAnalyze 页面
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, 'heightAnalyze');
                      },
                      child: const Text(
                        '查看身高分析',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 今日记录标题
              if (heightRecords.isNotEmpty)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '今日记录',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              // 记录列表
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: heightRecords.isEmpty
                    ? const Text('今日未记录', style: TextStyle(color: Colors.grey))
                    : Column(
                        children: heightRecords.map((record) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '身高：${record['height']} cm',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('确认删除'),
                                        content: const Text('你确定要删除这条记录吗？'),
                                        actions: [
                                          TextButton(
                                            child: const Text('取消'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('删除'),
                                            onPressed: () {
                                              _deleteHeightRecord(record['id']);
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

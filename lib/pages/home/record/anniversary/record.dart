import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/common/provider.dart';
import '/common/api.dart';
import '/common/record/anniversary.dart';

class AnniversaryRecordPage extends StatefulWidget {
  @override
  _AnniversaryRecordPageState createState() => _AnniversaryRecordPageState();
}

class _AnniversaryRecordPageState extends State<AnniversaryRecordPage> {
  late DateTime _selectedDay;
  TextEditingController _contentController = TextEditingController();
  TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // 保存纪念日记录
  void _saveAnniversary() async {
    String content = _contentController.text.isEmpty
        ? '没有特别的内容'
        : _contentController.text;
    String title = _titleController.text.isEmpty
        ? '未知纪念日'
        : _titleController.text;

    Map<String, dynamic> anniversaryRecord = {
      'type': 'anniversary',
      'title': title,
      'content': content,
    };

    await addDayRecordDetail(null, anniversaryRecord);

    // 添加新的纪念日记录到 provider
    Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('纪念日记录保存成功')),
    );
  }

  // 删除纪念日记录
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
        SnackBar(content: Text('纪念日记录已删除')),
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

    List<Map<String, dynamic>> anniversaryRecords = [];
    if (dayRecord['record'] != null) {
      anniversaryRecords = List<Map<String, dynamic>>.from(
        dayRecord['record']
                ?.where((record) => record['type'] == 'anniversary') ??
            [],
      );
    }

    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleTextStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        title: const Text('纪念日'),
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
        actions: [
          // 小的保存按钮，放在右上方
          IconButton(
            icon: Icon(Icons.save, size: 20),
            onPressed: _saveAnniversary,
            color: Colors.purpleAccent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 纪念日标签部分
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 纪念日标题输入框
                    TextField(
                      controller: _titleController,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '请输入纪念日标题',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    Divider(color: Colors.grey[300], thickness: 1), // 浅色分隔线

                    SizedBox(height: 16),
                    // 纪念日描述输入框
                    TextField(
                      controller: _contentController,
                      maxLines: 10,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '请输入特别的纪念日内容',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                    Divider(color: Colors.grey[300], thickness: 1), // 浅色分隔线

                    SizedBox(height: 16),
                    Text(
                      '今天是 ${DateFormat('yyyy-MM-dd').format(_selectedDay)} 的纪念日',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.purpleAccent,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text('纪念日标签：',
                        style: TextStyle(color: Colors.purpleAccent)),

                    // 标签部分
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      alignment: WrapAlignment.center,
                      children: anniversaryList.map((tag) {
                        return ActionChip(
                          label: Text(
                            tag['title']!,
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            _titleController.text = tag['title']!;
                            _contentController.text = tag['description']!;
                          },
                          backgroundColor: Colors.purple[100],
                          labelStyle: TextStyle(color: Colors.purple),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveAnniversary,
                      child: Text(
                        '保存纪念日',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // 纪念日记录列表
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: anniversaryRecords.isEmpty
                    ? Text('今天没有特别的纪念日', style: TextStyle(color: Colors.grey))
                    : Column(
                        children: anniversaryRecords.map((record) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.purple[50],
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '标题：${record['title'] ?? '无标题'}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '内容：${record['content'] ?? '无内容'}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteRecord(record['id']),
                                  color: Colors.red,
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

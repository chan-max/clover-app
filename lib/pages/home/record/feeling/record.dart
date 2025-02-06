import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '/common/provider.dart';
import '/common/api.dart';

class FeelingRecordPage extends StatefulWidget {
  @override
  _FeelingRecordPageState createState() => _FeelingRecordPageState();
}

class _FeelingRecordPageState extends State<FeelingRecordPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  String _selectedFeeling = 'normal'; // 选中的身体状态
  String _selectedEnergy = 'normal'; // 选中的能量等级
  TextEditingController _descriptionController = TextEditingController();

  final List<Map<String, String>> _feelings = [
    {'type': 'good', 'name': '很好'},
    {'type': 'okay', 'name': '一般'},
    {'type': 'tired', 'name': '疲惫'},
    {'type': 'sick', 'name': '生病'},
  ];

  final List<Map<String, String>> _energyLevels = [
    {'type': 'high', 'name': '能量充沛'},
    {'type': 'medium', 'name': '正常'},
    {'type': 'low', 'name': '疲劳'},
  ];

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
        ? '无详情'
        : _descriptionController.text;

    Map<String, dynamic> feelingRecord = {
      'type': 'feeling',
      'feelingState': _selectedFeeling,
      'energyState': _selectedEnergy,
      'description': description,
    };

    await addDayRecordDetail(null, feelingRecord);
    Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('记录成功')));
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

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('记录已删除')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('删除失败: $e')));
    }
  }

  // 构建选择按钮网格
  Widget _buildSelectionGrid(List<Map<String, String>> options, String selected,
      ValueChanged<String> onSelect) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        bool isSelected = option['type'] == selected;
        return GestureDetector(
          onTap: () => setState(() => onSelect(option['type']!)),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isSelected ? Colors.blueAccent : Colors.grey.shade300),
            ),
            child: Text(
              option['name']!,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 获取 dayRecord 数据
    var dayRecord = Provider.of<AppDataProvider>(context).getData('dayrecord');
    List<Map<String, dynamic>> feelingRecords = [];
    if (dayRecord['record'] != null) {
      feelingRecords = List<Map<String, dynamic>>.from(
        dayRecord['record']?.where((record) => record['type'] == 'feeling') ??
            [],
      );
    }
  
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleTextStyle:
            TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        title: Text('记录身体状态'),
        iconTheme: IconThemeData(color: Colors.grey),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 记录表单部分
            Text(
              '记录 ${DateFormat('yyyy-MM-dd').format(_selectedDay)}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blueAccent),
            ),
            SizedBox(height: 16),
            Text('身体状态',
                style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
            SizedBox(height: 8),
            _buildSelectionGrid(
                _feelings, _selectedFeeling, (val) => _selectedFeeling = val),
            SizedBox(height: 16),
            Text('能量状态',
                style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
            SizedBox(height: 8),
            _buildSelectionGrid(
                _energyLevels, _selectedEnergy, (val) => _selectedEnergy = val),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: '请输入描述（如：感到疲劳、精神焕发等）',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
              ),
              onPressed: _saveRecord,
              child: Text('保存记录',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            SizedBox(height: 20),
            // 已记录的身体状态列表
            Expanded(
              child: ListView.builder(
                itemCount: feelingRecords.length,
                itemBuilder: (context, index) {
                  var record = feelingRecords[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        '身体状态: ${record['feelingState']} | 能量状态: ${record['energyState']}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('描述: ${record['description']}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // 删除当前记录
                          _deleteRecord(record['id']);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

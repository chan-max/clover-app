import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 用于格式化日期
import 'package:provider/provider.dart'; // 引入 provider
import '/common/provider.dart';
import '/common/api.dart';
import '/common/record/mood.dart';
class MoodRecordPage extends StatefulWidget {
  @override
  _MoodRecordPageState createState() => _MoodRecordPageState();
}

class _MoodRecordPageState extends State<MoodRecordPage> {
  late DateTime _selectedDay;
  String? _selectedCategory;  // 存储选择的大类心情
  String? _selectedMoodType;  // 存储选择的具体心情类型
  double _moodRate = 3;
  double _energyRate = 3;
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // 保存记录
  void _saveRecord() async {
    String description =
        _descriptionController.text.isEmpty ? '无详情' : _descriptionController.text;

    if (_selectedMoodType == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('请选择心情类型')));
      return;
    }

    Map<String, dynamic> moodRecord = {
      'type': 'mood',
      'moodType': _selectedMoodType,
      'moodRate': _moodRate,
      'energyRate': _energyRate,
      'description': description,
    };

    await addDayRecordDetail(null, moodRecord);
    Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('记录成功')));
  }

  // 根据大类更新心情选项
  List<Map<String, dynamic>> _getMoodList() {
    if (_selectedCategory == null) return [];

    final category = MoodConfig.moodCategories
        .firstWhere((element) => element['category'] == _selectedCategory);
    return List<Map<String, dynamic>>.from(category['children']);
  }

  @override
  Widget build(BuildContext context) {
    var dayRecord = Provider.of<AppDataProvider>(context).getData('dayrecord');
    List<Map<String, dynamic>> moodRecords = [];
    if (dayRecord['record'] != null) {
      moodRecords = List<Map<String, dynamic>>.from(
        dayRecord['record']?.where((record) => record['type'] == 'mood') ?? [],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        title: Text('记录心情'),
        iconTheme: IconThemeData(color: Colors.grey),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '记录 ${DateFormat('yyyy-MM-dd').format(_selectedDay)}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueAccent),
                          ),
                          SizedBox(height: 16),
                          _buildCategorySelector(),  // 大类选择器
                          SizedBox(height: 16),
                          _buildMoodSelector(),  // 具体心情选择器
                          SizedBox(height: 16),
                          _buildSlider(
                            label: '心情：${_moodRate.toInt()}（1: 非常差, 5: 非常好）',
                            value: _moodRate,
                            onChanged: (value) => setState(() => _moodRate = value),
                          ),
                          SizedBox(height: 16),
                          _buildSlider(
                            label: '能量：${_energyRate.toInt()}（1: 极低, 5: 极高）',
                            value: _energyRate,
                            onChanged: (value) => setState(() => _energyRate = value),
                          ),
                          SizedBox(height: 16),
                          Text('描述：', style: TextStyle(color: Colors.blueAccent)),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blueAccent),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hintText: '请输入心情描述（如开心、疲倦等）',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (moodRecords.isNotEmpty) ...[
                    Text('今日记录', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Column(
                      children: moodRecords.map((record) {
                        return Card(
                          color: Colors.blue[50],
                          margin: EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('心情：${record['moodRate']}（${_getMoodText(record['moodRate'])}）', style: TextStyle(fontSize: 14)),
                                    Text('能量：${record['energyRate']}（${_getEnergyText(record['energyRate'])}）', style: TextStyle(fontSize: 14)),
                                    Text('描述：${record['description'] ?? '无详情'}', style: TextStyle(fontSize: 14)),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDelete(record['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: _saveRecord,
                child: Text('保存记录', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 大类选择器
  Widget _buildCategorySelector() {
    return DropdownButton<String>(
      hint: Text('请选择心情大类'),
      value: _selectedCategory,
      onChanged: (newCategory) {
        setState(() {
          _selectedCategory = newCategory;
          _selectedMoodType = null;  // 清空具体心情
        });
      },
      items: MoodConfig.moodCategories.map((category) {
        return DropdownMenuItem<String>(
          value: category['category'],
          child: Text(category['category']),
        );
      }).toList(),
    );
  }

  // 具体心情选择器
  Widget _buildMoodSelector() {
    if (_selectedCategory == null) return Container();

    List<Map<String, dynamic>> moods = _getMoodList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('选择心情', style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
        Wrap(
          spacing: 8.0,
          children: moods.map((mood) {
            return ChoiceChip(
              label: Text(mood['name']),
              selected: _selectedMoodType == mood['type'],
              onSelected: (selected) {
                setState(() {
                  _selectedMoodType = selected ? mood['type'] : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Slider构建
  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
        Slider(
          value: value,
          min: 1,
          max: 5,
          divisions: 4,
          label: value.toStringAsFixed(0),
          activeColor: Colors.blueAccent,
          inactiveColor: Colors.grey.shade300,
          onChanged: onChanged,
        ),
      ],
    );
  }

  String _getMoodText(int mood) {
    return mood == 1 ? "非常差" : mood == 5 ? "非常好" : "一般";
  }

  String _getEnergyText(int energy) {
    return energy == 1 ? "极低" : energy == 5 ? "极高" : "一般";
  }

  void _confirmDelete(String recordId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认删除'),
        content: Text('你确定要删除这条记录吗？'),
        actions: [
          TextButton(child: Text('取消'), onPressed: () => Navigator.pop(context)),
          TextButton(child: Text('删除'), onPressed: () {
            _deleteRecord(recordId);
            Navigator.pop(context);
          }),
        ],
      ),
    );
  }

  void _deleteRecord(String recordId) async {
    await deleteDayrecordDetail({'id': recordId});
    Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('记录已删除')));
  }
}

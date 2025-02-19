import 'package:flutter/material.dart';
// 用于格式化日期
import 'package:provider/provider.dart'; // 引入 provider
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '/common/provider.dart';
import '/common/api.dart';

class FragmentRecordPage extends StatefulWidget {
  @override
  _FragmentRecordPageState createState() => _FragmentRecordPageState();
}

class _FragmentRecordPageState extends State<FragmentRecordPage> {
  late DateTime _selectedDay;
  TextEditingController _contentController = TextEditingController();
  bool _isBottomSheetVisible = false;

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

  // 保存碎片记录
  void _saveFragment() async {
    String content = _contentController.text.isEmpty
        ? '无内容' // 如果没有输入则显示默认文本
        : _contentController.text;

    Map<String, dynamic> fragmentRecord = {
      'type': 'fragment',
      'content': content,
    };

    await addDayRecordDetail(null, fragmentRecord);

    // 添加新的碎片记录到 provider
    Provider.of<AppDataProvider>(context, listen: false).fetchDayRecord();

    TDToast.showText('碎片保存成功', context: context);

    // 关闭弹出层
    Navigator.pop(context);
  }

  // 删除碎片记录
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
        SnackBar(content: Text('碎片记录已删除')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
    }
  }

  // 显示输入框的弹出层
  void _showTextInputDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '请输入碎片内容',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '请输入内容...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveFragment,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('确定', style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // 处理照片记录点击
  void _onPhotoRecordClicked() {
    // 处理照片记录
    print("照片记录按钮点击");
  }

  // 处理视频记录点击
  void _onVideoRecordClicked() {
    // 处理视频记录
    print("视频记录按钮点击");
  }

  // 处理语音记录点击
  void _onVoiceRecordClicked() {
    // 处理语音记录
    print("语音记录按钮点击");
  }

  @override
  Widget build(BuildContext context) {
    var dayRecord = Provider.of<AppDataProvider>(context).getData('dayrecord');

    List<Map<String, dynamic>> fragmentRecords = [];
    if (dayRecord['record'] != null) {
      fragmentRecords = List<Map<String, dynamic>>.from(
        dayRecord['record']?.where((record) => record['type'] == 'fragment') ??
            [],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleTextStyle:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        title: const Text('记录生活碎片'),
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
              // 上方插图，增大尺寸
              Center(
                child: Image.asset(
                  'assets/img/ill/fragment_banner.png', // 插图图片路径
                  height: 200, // 增大插图高度
                  width: 200, // 增大插图宽度
                ),
              ),
              SizedBox(height: 4),
              // 文字描述使用非常小的文字
              Text(
                '记录生活中的每一小片刻，留下那些重要又微小的瞬间。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12, // 使用非常小的文字
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w300, // 更轻的字体
                ),
              ),
              SizedBox(height: 20),
              // 文字记录按钮
              ElevatedButton.icon(
                onPressed: _showTextInputDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.font_download, color: Colors.white),
                label: Text(
                  '文字记录',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              // 新增按钮：照片记录
              ElevatedButton.icon(
                onPressed: _onPhotoRecordClicked,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.photo, color: Colors.white),
                label: Text(
                  '照片记录',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              // 新增按钮：视频记录
              ElevatedButton.icon(
                onPressed: _onVideoRecordClicked,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.video_camera_back, color: Colors.white),
                label: Text(
                  '视频记录',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              // 新增按钮：语音记录
              ElevatedButton.icon(
                onPressed: _onVoiceRecordClicked,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.mic, color: Colors.white),
                label: Text(
                  '语音记录',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              SizedBox(height: 20),
              // 碎片记录列表
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: fragmentRecords.isEmpty
                    ? Text('今日未记录碎片', style: TextStyle(color: Colors.grey))
                    : Column(
                        children: fragmentRecords.map((record) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(16),
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        content: Text('你确定要删除这条碎片记录吗？'),
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

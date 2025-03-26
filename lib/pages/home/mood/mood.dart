import 'package:flutter/material.dart';
import 'package:clover/components/chart/latest30mood.dart';
import 'package:clover/components/chart/moodPie.dart';

class MoodPage extends StatefulWidget {
  @override
  _MoodPageState createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  List<String> moodRecords = [];
  Map<String, int> moodData = {};

  @override
  void initState() {
    super.initState();
    _initializeMoodData();
  }

  // 预填充 30 天默认数据，防止图表数据为空
  void _initializeMoodData() {
    DateTime today = DateTime.now();
    for (int i = 29; i >= 0; i--) {
      String date =
          today.subtract(Duration(days: i)).toIso8601String().substring(0, 10);
      moodData[date] = 5; // 默认心情值 5
    }
    setState(() {});
  }

  void _openMoodInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (BuildContext context) {
        String moodText = '';
        int moodValue = 5;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('记录心情',
                          style: TextStyle(color: Colors.white, fontSize: 14)),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: '请输入您的心情...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) => moodText = value,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('选择心情值', style: TextStyle(color: Colors.white)),
                  Slider(
                    value: moodValue.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: moodValue.toString(),
                    onChanged: (double value) {
                      setModalState(() {
                        moodValue = value.toInt();
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (moodText.isNotEmpty) {
                        setState(() {
                          moodRecords.insert(0, moodText);
                          String date =
                              DateTime.now().toIso8601String().substring(0, 10);
                          moodData[date] = moodValue;
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: Text('保存心情'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('心情日记',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 心情统计图表
            Container(
              decoration: BoxDecoration(
                color: Color(0xff19181F),
                borderRadius: BorderRadius.circular(6),
              ),
              child: MoodChart(),
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            ),

            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xff19181F),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  Text('关于我的心情统计',style: TextStyle(color: Colors.white,fontSize: 12)),
                  MoodPie(),
                ],
              ),
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            ),

            // 历史记录列表
            ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: moodRecords.length,
              shrinkWrap: true, // 让 `ListView` 适配 `Column`
              physics: NeverScrollableScrollPhysics(), // 避免嵌套滚动冲突
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.grey[900],
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      moodRecords[index],
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _openMoodInput,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:clover/common/api.dart';

class YestodayAnalyzePage extends StatefulWidget {
  @override
  _YestodayAnalyzePageState createState() => _YestodayAnalyzePageState();
}

class _YestodayAnalyzePageState extends State<YestodayAnalyzePage> {
  Map<String, dynamic>? dayRecord;
  bool isLoading = true;
  Map<String, int> cnameCountMap = {};
  List<Map<String, dynamic>> allRecords = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  /// 获取昨日日期
  String getYesterdayDate() {
    final DateTime now = DateTime.now();
    final DateTime yesterday = now.subtract(Duration(days: 1));
    return "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
  }

  /// 获取昨日记录并统计 cname 频次
  Future<void> fetchData() async {
    try {
      String dateKey = getYesterdayDate();
      dynamic data = await getDayrecord(datekey: dateKey);

      if (data != null && data['record'] != null) {
        List<Map<String, dynamic>> records = List<Map<String, dynamic>>.from(data['record']);

        // 统计 cname 出现次数
        Map<String, int> tempCnameCountMap = {};
        for (var record in records) {
          String cname = record['struct']?['cname'] ?? '未分类';
          tempCnameCountMap[cname] = (tempCnameCountMap[cname] ?? 0) + 1;
        }

        setState(() {
          dayRecord = data;
          cnameCountMap = tempCnameCountMap;
          allRecords = records; // 直接展示所有记录
          isLoading = false;
        });
      } else {
        setState(() {
          dayRecord = null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '昨日分析',
          style: TextStyle(fontSize: 13),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : dayRecord == null || allRecords.isEmpty
              ? Center(
                  child: Text(
                    "暂无数据",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "昨日记录分类：",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),

                      // 统计显示（网格布局）
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 3, // 每行 3 列
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.2,
                        children: cnameCountMap.entries.map((entry) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[850],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "${entry.value}",
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 20),

                      // 记录列表（不分组）
                      Expanded(
                        child: ListView.builder(
                          itemCount: allRecords.length,
                          itemBuilder: (context, index) {
                            var record = allRecords[index];
                            return Card(
                              color: Colors.grey[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                title: Text(
                                  record['struct']?['cname'] ?? '未分类',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record['type'] ?? '未知类型',
                                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                    ),
                                    Text(
                                      "${record['startTime']} - ${record['endTime']}",
                                      style: TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 用于格式化日期
import 'package:provider/provider.dart'; // 引入 provider
import '/components/record_type_bottom_sheet.dart';
import '/common/provider.dart'; // 假设你已经创建了这个Provider类
import '/common/api.dart'; // 假设你已经创建了这个API类

class TodayContent extends StatelessWidget {
  Future<Map<String, dynamic>> _getUserInfo(BuildContext context) async {
    final appDataProvider =
        Provider.of<AppDataProvider>(context, listen: false);
    final userInfo = await appDataProvider.getData('userInfo');
    return userInfo ?? {};
  }

  // 删除记录
  void _deleteRecord(BuildContext context, String recordId) async {
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Consumer<AppDataProvider>(
          builder: (context, appDataProvider, child) {
            final userInfo = appDataProvider.getData('userInfo');

            if (userInfo == null) {
              return Center(child: CircularProgressIndicator());
            }

            String formattedDate =
                DateFormat('yyyy-MM-dd').format(DateTime.now());
            String formattedDayOfWeek =
                DateFormat('EEEE').format(DateTime.now());

            final createTime = userInfo['createTime'] != null
                ? DateTime.parse(userInfo['createTime'])
                : DateTime.now();
            final birthday = userInfo['birthday'] != null
                ? DateTime.parse(userInfo['birthday'])
                : DateTime(1999, 1, 1);

            final today = DateTime.now();
            final daysSinceBirth = today.difference(birthday).inDays;
            final daysUsingApp = today.difference(createTime).inDays;

            var dayRecord = appDataProvider.getData('dayrecord');
            List<Map<String, dynamic>> records = [];
            if (dayRecord['record'] != null) {
              records = List<Map<String, dynamic>>.from(dayRecord['record']);
            }

            return SafeArea(
              child: Column(
                children: [
                  // 顶部区域
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.35,
                    decoration: BoxDecoration(
                      color: Color(0xFF00D0A9),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '今天是：$formattedDate',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '星期$formattedDayOfWeek',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white70),
                          ),
                          SizedBox(height: 20),
                          Text(
                            '你加入的日期：${DateFormat('yyyy-MM-dd').format(createTime)}',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '你一共活了：$daysSinceBirth 天',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '你已经使用该App：$daysUsingApp 天',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 下半部分，白色背景
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '记录列表',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        records.isEmpty
                            ? Center(child: Text('暂无记录'))
                            : Column(
                                children: records.map((record) {
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '类型: ${record['type'] ?? '未知'}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              Text(
                                                '时间: ${record['createTime'] ?? '未知'}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              Text(
                                                '内容: ${record['content'] ?? '无内容'}',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            _deleteRecord(
                                                context, record['id']);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showBottomSheet(context);
        },
        label: const Text(
          '记录',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        icon: const Icon(
          Icons.edit_calendar,
          size: 20,
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF00D0A9),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return RecordTypeBottomSheet(
          onOptionSelected: (selectType) {
            String routeName = selectType + 'Record';
            if (routeName.isNotEmpty) {
              Navigator.pushNamed(context, routeName);
            }
          },
        );
      },
    );
  }
}

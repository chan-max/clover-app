import 'package:clover/common/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DayRecordDetailPage extends StatelessWidget {
  final String dateKey = Get.parameters['dateKey'] ?? '';

  Future<Map<String, dynamic>> fetchDayRecord(String dateKey) async {
    return await getDayrecord(datekey: dateKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('日记录', style: TextStyle(fontSize: 13)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchDayRecord(dateKey),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Colors.white));
          } else if (snapshot.hasError) {
            return Center(
                child: Text('加载失败: ${snapshot.error}',
                    style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(
                child: Text('无数据', style: TextStyle(color: Colors.white)));
          }

          var records = snapshot.data!['record'] as List<dynamic>? ?? [];

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              var record = records[index];
              return Card(
                color: Colors.grey[900],
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(record['content'] ?? '无内容',
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text('时间: ${record['createTime']}',
                      style: TextStyle(color: Colors.grey)),
                  leading: Icon(Icons.event_note, color: Colors.white),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

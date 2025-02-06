import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '/common/provider.dart'; // 假设这个是你获取数据的 provider
import '/common/api.dart'; // 假设这个是你用来获取数据的 API
import 'package:clover/common/api.dart';

class DayRecordPage extends StatefulWidget {
  @override
  _DayRecordPageState createState() => _DayRecordPageState();
}

class _DayRecordPageState extends State<DayRecordPage> {
  late Map<DateTime, List<Map<String, dynamic>>> _selectedRecords;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now(); // 默认选中今天
    _calendarFormat = CalendarFormat.month; // 默认以月视图显示
    _selectedRecords = {}; // 存储每一天的数据

    // 默认获取今天的记录数据
    _fetchDayRecord(_selectedDay);
  }

  // 获取并展示当天的数据
  Future<void> _fetchDayRecord(DateTime date) async {
    final String formattedDate = "${date.year}-${date.month}-${date.day}";
    final records = await getDayrecord(datekey: formattedDate); // 获取数据

    // 确保将返回的数据转换成 List<Map<String, dynamic>> 格式
    List<Map<String, dynamic>> recordList = [];

    if (records is List) {
      recordList = List<Map<String, dynamic>>.from(records);
    } else if (records is Map) {
      // 如果返回的是 Map，转换成 List 格式
      recordList = [records as Map<String, dynamic>];
    }

    setState(() {
      _selectedRecords[date] = recordList; // 更新记录
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 设置背景颜色
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // 去除阴影
        title: const Text(
          '历史日历',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.grey),
      ),
      body: Column(
        children: [
          // 日历部分
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TableCalendar(
              locale: 'zh_CN',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _selectedDay, // 更新焦点日期
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day); // 确保选中的日期高亮
              },
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay; // 更新选中的日期
                });
                _fetchDayRecord(selectedDay); // 获取该日期的数据
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.blueAccent, // 选中的日期背景色
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3), // 今日背景色
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false, // 隐藏非当前月的日期
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false, // 隐藏视图切换按钮
                titleCentered: true, // 标题居中
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Colors.black, // 字体颜色
                  fontWeight: FontWeight.bold, // 字体加粗
                  fontSize: 12, // 字体大小
                ),
                weekendStyle: TextStyle(
                  color: Colors.black, // 字体颜色
                  fontWeight: FontWeight.bold, // 字体加粗
                  fontSize: 12, // 字体大小
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 展示当天的数据部分
          Expanded(
            child: Builder(
              builder: (context) {
                final dayRecords = _selectedRecords[_selectedDay] ?? [];
                return ListView.builder(
                  itemCount: dayRecords.length,
                  itemBuilder: (context, index) {
                    final record = dayRecords[index];
                    final recordString = record.toString();

                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          '记录内容: $recordString',
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // 删除记录的逻辑
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

class CustomMonthCalendar extends StatefulWidget {
  const CustomMonthCalendar({super.key});

  @override
  _CustomMonthCalendarState createState() => _CustomMonthCalendarState();
}

class _CustomMonthCalendarState extends State<CustomMonthCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('zh_CN'); // 初始化中文日期格式
  }

  // 触发的操作，可以在这里执行任何逻辑
  void _onCalendarEventTriggered(String event) {
    print(event); // 当前为打印文字，你可以根据需求修改成其他功能
  }

  // 返回今天的功能
  void _returnToToday() {
    setState(() {
      _focusedDay = DateTime.now();
      _selectedDay = DateTime.now();
    });
    _onCalendarEventTriggered('返回今天: ${DateTime.now().toLocal()}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // “回到今天”文字链接，右对齐
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: _returnToToday,
                  child: const Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.greenAccent, size: 16), // 小图标
                      SizedBox(width: 4),
                      Text(
                        '回到今天',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline, // 下划线模拟链接
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 日历部分
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: TableCalendar(
              locale: 'zh_CN',
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _onCalendarEventTriggered('日期选择: ${selectedDay.toLocal()}');
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
                _onCalendarEventTriggered('月份切换: ${focusedDay.toLocal()}');
              },
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                weekendStyle: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              calendarStyle: const CalendarStyle(
                defaultTextStyle: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                weekendTextStyle: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                selectedDecoration: BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.lightGreen,
                  shape: BoxShape.circle,
                ),
                outsideDaysVisible: false,
              ),
              rowHeight: 42,
              daysOfWeekHeight: 30,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.grey[900],
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        if (day.day % 3 == 0)
                          const Icon(Icons.star, color: Colors.greenAccent, size: 12),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
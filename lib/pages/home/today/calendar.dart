import 'dart:convert';
import 'dart:developer';

import 'package:tdesign_flutter/tdesign_flutter.dart' show TDToast;

import 'package:clover/common/api.dart';
import 'package:clover/pages/home/today/dayrecorddetail/dayrecorddetail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:async';
import 'dart:math';

class CustomMonthCalendar extends StatefulWidget {
  const CustomMonthCalendar({super.key});

  @override
  _CustomMonthCalendarState createState() => _CustomMonthCalendarState();
}

class _CustomMonthCalendarState extends State<CustomMonthCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  bool _isCalendarVisible = true;

  dynamic recordData = {};

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('zh_CN');
    _fetchData(_focusedDay);
  }

  /// 模拟从后台接口获取天气数据
  Future<void> _fetchData(DateTime month) async {
    var res = await getMonthlyRecordCount(year: month.year, month: month.month);
    print(res);
    setState(() {
      recordData = (res);
    });
  }

  /// 统一格式化日期，保证 key 统一
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _toggleCalendarFormat() {
    setState(() {
      _calendarFormat = _calendarFormat == CalendarFormat.month
          ? CalendarFormat.week
          : CalendarFormat.month;
    });
    _fetchData(_focusedDay);
  }

  void _toggleCalendarVisibility() {
    setState(() {
      _isCalendarVisible = !_isCalendarVisible;
    });
  }

  void _returnToToday() {
    setState(() {
      _focusedDay = DateTime.now();
      _selectedDay = DateTime.now();
    });
    _fetchData(_focusedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    _calendarFormat == CalendarFormat.month
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: Colors.greenAccent,
                  ),
                  onPressed: _toggleCalendarFormat,
                ),
                GestureDetector(
                  onTap: _returnToToday,
                  child: const Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.greenAccent, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '回到今天',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isCalendarVisible)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: TableCalendar(
                locale: 'zh_CN',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  DateTime now = DateTime.now(); // 当前时间

                  // 只比较年月日
                  DateTime today = DateTime(now.year, now.month, now.day);
                  DateTime targetDay = DateTime(
                      selectedDay.year, selectedDay.month, selectedDay.day);

                  if (today.isAfter(targetDay)) {
                    print("当前日期大于目标日期");
                    Get.toNamed('/dayRecordDetailPage', parameters: {
                      'dateKey': selectedDay.year.toString() +
                          '-' +
                          selectedDay.month.toString() +
                          '-' +
                          selectedDay.day.toString()
                    });
                  } else if (today.isBefore(targetDay)) {
                    // 说明再未来
                    TDToast.showText('这天还没到,专注眼前吧', context: context);
                  } else {
                    print("两个日期相等");
                  }

                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                  _fetchData(focusedDay);
                },
                calendarFormat: _calendarFormat,
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: Colors.white),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                  weekendStyle: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
                calendarStyle: const CalendarStyle(
                  defaultTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                  weekendTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
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
                rowHeight: 48,
                daysOfWeekHeight: 30,
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    String dayKey = _formatDateKey(day);

                    bool hasRecord = recordData.containsKey(dayKey);

                    String count = recordData[dayKey]?.toString() ?? ''; // 获取对应的值
              
                    return Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.grey[900],
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          // if(count.isNotEmpty)
                          // Text(
                          //   count,
                          //   style: const TextStyle(
                          //       color: Colors.white, fontSize: 12),
                          // ),
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

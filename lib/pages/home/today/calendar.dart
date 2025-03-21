import 'package:clover/common/api.dart';
import 'package:flutter/material.dart';
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

  Map<String, Map<String, dynamic>> weatherData = {};

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('zh_CN');
    _fetchWeatherData(_focusedDay);
  }

  /// 模拟从后台接口获取天气数据
  Future<void> _fetchWeatherData(DateTime month) async {
    Map<String, Map<String, dynamic>> fakeWeather = {};
    Random random = Random();

    await getMonthlyRecordCount(year: month.year, month: month.month);

    for (int i = 1; i <= 31; i++) {
      DateTime day = DateTime(month.year, month.month, i);
      if (day.month != month.month) break;

      String dayKey = _formatDateKey(day); // 确保 key 格式一致
      fakeWeather[dayKey] = {
        'temperature': '${random.nextInt(15) + 10}°C',
        'icon': random.nextBool() ? Icons.wb_sunny : Icons.cloud
      };
    }

    setState(() {
      weatherData = fakeWeather;
    });
  }

  /// 统一格式化日期，保证 key 统一
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  void _toggleCalendarFormat() {
    setState(() {
      _calendarFormat = _calendarFormat == CalendarFormat.month
          ? CalendarFormat.week
          : CalendarFormat.month;
    });
    _fetchWeatherData(_focusedDay);
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
    _fetchWeatherData(_focusedDay);
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
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onPageChanged: (focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                  });
                  _fetchWeatherData(focusedDay);
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
                rowHeight: 60,
                daysOfWeekHeight: 30,
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    String dayKey = _formatDateKey(day);
                    bool hasWeather = weatherData.containsKey(dayKey);

                    return Container(
                      margin: const EdgeInsets.all(2),
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
                          if (hasWeather) ...[
                            Icon(weatherData[dayKey]!['icon'],
                                color: Colors.greenAccent, size: 16),
                            Text(
                              weatherData[dayKey]!['temperature'],
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ],
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

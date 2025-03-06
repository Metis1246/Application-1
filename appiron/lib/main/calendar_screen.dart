import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  Map<String, String> _getDayToText(BuildContext context) {
    return {
      'Sunday': S.of(context)!.c,
      'Monday': S.of(context)!.l,
      'Tuesday': S.of(context)!.a,
      'Wednesday': S.of(context)!.b,
      'Thursday': S.of(context)!.l,
      'Friday': S.of(context)!.a,
      'Saturday': S.of(context)!.b,
    };
  }

  IconData? _getIconForSelectedDay(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
      case DateTime.tuesday:
      case DateTime.wednesday:
      case DateTime.thursday:
      case DateTime.friday:
      case DateTime.saturday:
        return Icons.local_fire_department;
      case DateTime.sunday:
        return Icons.fastfood;
      default:
        return null;
    }
  }

  String _getTextForSelectedDay(DateTime date, BuildContext context) {
    final dayToText = _getDayToText(context);
    return dayToText[_dayToString(date)] ?? '';
  }

  String _dayToString(DateTime date) {
    switch (date.weekday) {
      case DateTime.sunday:
        return 'Sunday';
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 0, 0, 0),
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.fromLTRB(16.0, 80.0, 16.0, 8.0),
              padding: const EdgeInsets.all(16.0),
              height: 380,
              child: TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarFormat: CalendarFormat.month,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: Colors.white),
                  titleTextFormatter: (date, locale) =>
                      '${date.year}/${date.month.toString().padLeft(2, '0')}',
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  dowTextFormatter: (date, locale) {
                    final day = DateFormat.E(locale).format(date);
                    switch (day) {
                      case 'Sun':
                        return S.of(context)!.sun;
                      case 'Mon':
                        return S.of(context)!.mon;
                      case 'Tue':
                        return S.of(context)!.tue;
                      case 'Wed':
                        return S.of(context)!.wed;
                      case 'Thu':
                        return S.of(context)!.thu;
                      case 'Fri':
                        return S.of(context)!.fri;
                      case 'Sat':
                        return S.of(context)!.sat;
                      default:
                        return day;
                    }
                  },
                  weekdayStyle: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                  weekendStyle: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  weekendTextStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  outsideTextStyle: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                  ),
                  todayDecoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 0, 0),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
              padding: const EdgeInsets.all(16.0),
              height: 100.0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getTextForSelectedDay(_selectedDay, context),
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    _getIconForSelectedDay(_selectedDay),
                    color: const Color.fromARGB(255, 255, 0, 0),
                    size: 24,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

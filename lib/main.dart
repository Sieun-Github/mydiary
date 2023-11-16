import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
<<<<<<<<< Temporary merge branch 1

class TableCalendarScreen extends StatelessWidget {
  const TableCalendarScreen({Key? key}) : super(key: key);
=========
import 'package:intl/intl.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diary App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Diary App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime selectedDay = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now();
>>>>>>>>> Temporary merge branch 2

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<<<< Temporary merge branch 1
      appBar: AppBar(),
      body: TableCalendar(
        firstDay: DateTime.utc(2021, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: DateTime.now(),
      ),
    );
=========
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
              TableCalendar(
                rowHeight: 70,
                focusedDay: focusedDay,
                firstDay: DateTime(2022, 1, 1),
                lastDay: DateTime(2033, 12, 31),
                onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                  setState(() {
                    this.selectedDay = selectedDay;
                    this.focusedDay = focusedDay;
                  });
                },
                selectedDayPredicate: (DateTime day) {
                  return isSameDay(selectedDay, day);
                },
                headerStyle: HeaderStyle(
                  headerPadding: const EdgeInsets.symmetric(vertical: 20),
                  titleCentered: true,
                  titleTextFormatter: (date, locale) =>
                      DateFormat.yMMMM(locale).format(date),
                  titleTextStyle: const TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff291872)),
                  formatButtonVisible: false,
                ),
                calendarStyle: const CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: Color(0xffdbd5f6),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 15),
                  selectedDecoration: BoxDecoration(
                    color: Color(0xFFd4d2e0),
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15),
                  weekendTextStyle: TextStyle(
                    color: Color(0xff291872),
                  ),
                ),
              )
            ]))));
>>>>>>>>> Temporary merge branch 2
  }
}

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mydiary/src/app.dart';

void main() async {
  await initializeDateFormatting();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});
  @override
  Widget build(BuildContext context) {
    return const App();
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mydiary/src/diary.dart';
import 'package:mydiary/src/first_page.dart';
import 'package:mydiary/src/home.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late GoRouter router;
  @override
  void initState() {
    super.initState();
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const FirstPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Home(),
        ),
        GoRoute(
          path: '/diary',
          builder: (context, state) => const Diary(),
        ),
      ],
      initialLocation: '/',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(fontFamily: 'NPS'),
        home: Scaffold(
            body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  height: 200, child: Image.asset('assets/images/logo.png')),
              const SizedBox(
                height: 50,
              ),
              const Text(
                '하루 음색',
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff291872)),
              ),
              const SizedBox(
                height: 100,
              ),
              ElevatedButton(
                onPressed: () {
                  GoRouter.of(context).go('/home');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  backgroundColor: Color(0xffdbd5f6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(10, 50),
                ),
                child: const Text(
                  '시작하기',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, ),
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        )));
  }
}
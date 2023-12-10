import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'NPS',
      ),
      home:  Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width:500, child: Image.asset('assets/images/Music.png')),
          const SizedBox(
            height: 40,
          ),
          const Text(
            '하루 음색',
            style: TextStyle(
                fontSize: 28,
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
              padding: EdgeInsets.symmetric(horizontal: 100, vertical: 24),
              backgroundColor: Color(0xffdbd5f6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              minimumSize: const Size(10, 50),
            ),
            child: const Text(
              'START',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    ))
    );
  }
}
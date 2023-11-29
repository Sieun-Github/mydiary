import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: SizedBox(
              child: Image.asset(
                'assets/images/Music.png',
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '음악추천 다이어리를\n 시작해보세요!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 100),
                ElevatedButton(
                  onPressed: () {
                    GoRouter.of(context).go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(150, 50),
                  ),
                  child: const Text(
                    '시작하기',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

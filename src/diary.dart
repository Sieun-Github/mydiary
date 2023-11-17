import 'package:flutter/material.dart';

class Diary extends StatelessWidget {
  const Diary({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diary 작성'),
        backgroundColor: Color(0xFFCCFFFF),
      ),
      body: Center(child: Text('디테일')),
    );
  }
}

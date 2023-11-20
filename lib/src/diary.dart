import 'package:flutter/material.dart';

class Diary extends StatefulWidget {
  const Diary({super.key});

  @override
  State<Diary> createState() => _DiaryState();
}

class _DiaryState extends State<Diary> {
  final TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('${DateTime.now()}'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _textEditingController,
                maxLength: 140, 
                maxLines: 5, // 다섯 줄
                decoration: const InputDecoration(
                  border: InputBorder.none, // 텍스트 입력 공간 밑줄 없음
                  labelText: '', // 라벨 없음
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

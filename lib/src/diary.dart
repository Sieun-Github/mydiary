import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Diary extends StatefulWidget {
  const Diary({Key? key}) : super(key: key);

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
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  GoRouter.of(context).go('/');
                },
              ),
            ),
            Text('${DateTime.now()}'),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _textEditingController,
                maxLength: 140, // 여러 줄
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '일기 작성',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                String diaryText = _textEditingController.text;
                print('Diary Text Submitted: $diaryText');
              },
              child: const Text('작성'),
            ),
          ],
        ),
      ),
    );
  }
}

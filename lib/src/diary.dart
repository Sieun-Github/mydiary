import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'home.dart';

class Diary extends StatefulWidget {
  const Diary({Key? key}) : super(key: key);

  @override
  State<Diary> createState() => _DiaryState();
}

class _DiaryState extends State<Diary> {
  final TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy. MM. dd.').format(day);
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _showAlertDialog();
                },
              ),
            ),
            Text(formattedDate),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _textEditingController,
                maxLength: 150, // 여러 줄
                maxLines: 8,
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

  Future<void> _showAlertDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('경고'),
          content: const Text('정말 뒤로 가시겠습니까? 작성 중인 내용이 저장되지 않을 수 있습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
              },
              child: const Text('계속적기'),
            ),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go('/'); // Navigate back to the home page
              },
              child: const Text('나가기'),
            ),
          ],
        );
      },
    );
  }
}

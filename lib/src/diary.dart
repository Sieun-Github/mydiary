import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'home.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:mysql_client/mysql_client.dart';

class Diary extends StatefulWidget {
  const Diary({super.key});

  @override
  State<Diary> createState() => _DiaryState();
}

// 이미지 선택기능
final picker = ImagePicker();
XFile? image;
List<XFile?> images = [];

class _DiaryState extends State<Diary> {
  late TextEditingController _textEditingController = TextEditingController();
  bool _visibility = true;
  String _savedText = '';

  //visibility 설정
  void _show() {
    setState(() {
      _visibility = true;
    });
  }

  void _hide() {
    setState(() {
      _visibility = false;
    });
  }

  // 데이터 저장 관련 함수
  @override
  void initState() {
    super.initState();
    dbConnect();
    selectALL(day);
  }

  _loadSavedText() {
    late String text;
    File file = File('texts/${DateFormat('yyyy-MM-dd').format(day)}.txt');
    if (file.existsSync()) {
      text = file.readAsStringSync();
    } else {
      text = '';
    }
    setState(() {
      _savedText = text;
    });
  }

  _saveText() {
    File file = File('texts/${DateFormat('yyyy-MM-dd').format(day)}.txt');
    file.writeAsStringSync(_textEditingController.text);
    _loadSavedText();
  }

  // 위젯
  @override
  Widget build(BuildContext context) {
    _textEditingController = TextEditingController(text: _savedText);
    String formattedDate = DateFormat('yyyy. MM. dd.').format(day);
    return Scaffold(
      // 앱바
      appBar: AppBar(
        backgroundColor: Colors.white10,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Color(0xff291872),
          onPressed: () {
            _showAlertDialog();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: const Column(children: [
                SizedBox(
                  height: 50,
                )
              ]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 카메라 아이콘
                Visibility(
                  visible: _visibility,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 0.5,
                            blurRadius: 5)
                      ],
                    ),
                    child: IconButton(
                      onPressed: () async {
                        XFile? pickedImage =
                            await picker.pickImage(source: ImageSource.camera);
                        if (pickedImage != null) {
                          setState(
                            () {
                              images.clear();
                              images.add(pickedImage);
                            },
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.add_a_photo,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // 갤러리에서 추가 아이콘
                Visibility(
                  visible: _visibility,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 0.5,
                            blurRadius: 5)
                      ],
                    ),
                    child: IconButton(
                      onPressed: () async {
                        XFile? pickedImage =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (pickedImage != null) {
                          setState(
                            () {
                              images.clear();
                              images.add(pickedImage);
                            },
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
            // 선택된 이미지
            Container(
              margin: const EdgeInsets.all(10),
              child: GridView.builder(
                padding: const EdgeInsets.all(0),
                shrinkWrap: true,
                itemCount: images.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1 / 1,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: FileImage(
                              File(images[index]!.path),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close,
                              color: Colors.white, size: 15),
                          onPressed: () {
                            setState(
                              () {
                                images.remove(images[index]);
                              },
                            );
                          },
                        ),
                      )
                    ],
                  );
                },
              ),
            ),
            // 선택한 날짜
            Text(formattedDate),
            // 텍스트 영역
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(children: [
                Visibility(
                  // 일기 작성
                  visible: _visibility,
                  child: TextFormField(
                    controller: _textEditingController,
                    maxLength: 150,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '일기 작성',
                    ),
                  ),
                ),
                Visibility(
                    // 일기 열람
                    visible: !_visibility,
                    child: Text(_savedText))
              ]),
            ),
            // 저장 or 수정 버튼
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: _visibility,
                      child: ElevatedButton(
                        onPressed: () {
                          _visibility ? _hide() : _show();
                          _saveText();
                          _loadSavedText();
                        },
                        child: const Text('저장'),
                      ),
                    ),
                    Visibility(
                        visible: !_visibility,
                        child: ElevatedButton(
                          onPressed: () {
                            _visibility ? _hide() : _show();
                            _saveText();
                            _loadSavedText();
                          },
                          child: const Text('수정'),
                        ))
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // 뒤로가기 시 경고창
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
                Navigator.of(context).pop();
              },
              child: const Text('계속적기'),
            ),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go('/home');
              },
              child: const Text('나가기'),
            ),
          ],
        );
      },
    );
  }

  // DB 연결
  Future<MySQLConnection> dbConnect() async {
    print("Connecting to mysql server...");

    // MySQL 접속 설정
    final conn = await MySQLConnection.createConnection(
      host: '127.0.0.1',
      port: 3306,
      userName: 'root',
      password: 'qwer1234',
      databaseName: 'diary', // optional
    );
    return conn;
  }

  // DB에서 전체 데이터 불러오기
  Future<IResultSet?> selectALL(day) async {
    final conn = await dbConnect();

    // 연결 대기
    await conn.connect();
    print("Connected");

    IResultSet result;
    try {
      result = await conn
          .execute("SELECT * FROM content WHERE date = :day", {"day": day});
      return result;

      print("the result is: $result");
      print(result);
    } catch (e) {
      print('Error : $e');
    } finally {
      await conn.close();
      print("Disconneted");
    }
    // 데이터가 없으면 null 값 반환
    return null;
  }

  //text 내용 가져오기
  Future<IResultSet?> text(day) async {
    final conn = await dbConnect();

    IResultSet result;
    try {
      result = await conn
          .execute("SELECT text FROM content WHERE date = :day", {"day": day});
      if (result.numOfRows > 0) {
        return result;
      }
    } catch (e) {
      print('Error : $e');
    } finally {
      await conn.close();
    }
    // 데이터가 없으면 null 값 반환
    return null;
  }
}
  // Future<void> getdata() async {
  //   List datalist=[];

  //   var result = await sel
  // }
// Future<void> _loadSavedText(DateTime date) async {
//     // MySQL 접속 설정
//     final conn = await MySQLConnection.createConnection(
//       host: '127.0.0.1',
//       port: 3306,
//       userName: 'root',
//       password: 'qwer1234',
//       databaseName: 'diary', // optional
//     );
//   IResultSet? result;

//   result = await conn.execute("select * from content where date = :day",{"day":date});
// }
// Future<void> _saveText() async {
//   // MySQL 접속 설정
//     final conn = await MySQLConnection.createConnection(
//       host: '127.0.0.1',
//       port: 3306,
//       userName: 'root',
//       password: 'qwer1234',
//       databaseName: 'diary', // optional
//     );
//   IResultSet? result;
  
//   result = await conn.execute("INSERT INTO content (date, text, savetime, emotion, music) VALUES (:day, :)");
// }
// Future<void> _editText() async {
//    // MySQL 접속 설정
//     final conn = await MySQLConnection.createConnection(
//       host: '127.0.0.1',
//       port: 3306,
//       userName: 'root',
//       password: 'qwer1234',
//       databaseName: 'diary', // optional
//     );
//   IResultSet? result;
  
// result = await conn.execute("UPDATE INTO content (date, text, savetime, emotion, music)");
// }
 
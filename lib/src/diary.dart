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

Future<MySQLConnection> dbcon() async {
  // MySQL 접속 설정
  final conn = await MySQLConnection.createConnection(
    host: '127.0.0.1',
    port: 3306,
    userName: 'root',
    password: 'qwer1234',
    databaseName: 'diary', // optional
  );
  await conn.connect();
  print("Connected");

  return conn;
}

// 이미지 선택기능
final picker = ImagePicker();
XFile? image;
List<XFile?> images = [];

class _DiaryState extends State<Diary> {
  late TextEditingController _textEditingController = TextEditingController();
  bool _visibility = true;
  bool _editbtn = false;
  bool _savebtn = true;
  String? _date = '';
  String? _savetime = '';
  String? _emotion = '';
  String? _music = '';
  String? _savedText = '';
  // late Future<List?> fromdb;

  //visibility 설정
  void _show() {
    setState(() {
      _visibility = !_visibility;
    });
  }

  void _hide() {
    setState(() {
      _visibility = !_visibility;
    });
  }

  // 데이터 저장 관련 함수
  @override
  void initState() {
    super.initState();
    loadDB();
    //   setvisible();
    // }

    // _savetime값.isbefore.now 일 때 _visibility, _
    // now = DateFormat('HH:mm:ss').format(DateTime.now())
    // setvisible() {
    //   if (DateTime.parse(_savetime).isAfter(DateTime.now())) {
    //     setState(() {
    //       _visibility = true;
    //       _savebtn = false;
    //       _editbtn = true;
    //     });
    //   }
    // _savedText != null
    // // &&(DateFormat().format(_savetime).isbefore(DateFormat()))
    //     ? {
    //         setState(() {
    //           _visibility = true;
    //           _editbtn = true;
    //           _savebtn = false;
    //         })
    //       }
    //     : {
    //         setState(() {
    //           _visibility = true;
    //           _editbtn = false;
    //           _savebtn = true;
    //         })
    //       };
  }

  // 위젯
  @override
  Widget build(BuildContext context) {
    _textEditingController = TextEditingController(text: _savedText);
    String formattedDate = DateFormat('yyyy. MM. dd').format(day);
    return Scaffold(
      // 앱바 (뒤로가기)
      appBar: AppBar(
        backgroundColor: Colors.white10,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Color(0xff291872),
          onPressed: () {
            if (_textEditingController.text != _savedText) {
              _showAlertDialog();
            } else {
              GoRouter.of(context).go('/home');
            }
          },
        ),
      ),
      // 앱 페이지
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              formattedDate,
              style: const TextStyle(
                  color: Color(0xff291872),
                  fontSize: 27,
                  fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.only(top: 10),
              child: const Column(children: [
                SizedBox(
                  height: 30,
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
                      color: Color(0xffdbd5f6),
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
                        color: Color(0xff291872),
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
                      color: Color(0xffdbd5f6),
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
                        color: Color(0xff291872),
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
                              color: Color(0xffdbd5f6), size: 15),
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

            // 텍스트 영역
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Stack(children: [
                Visibility(
                  // 일기 작성
                  visible: _visibility,
                  child: TextFormField(
                    cursorColor: Color(0xff291872),
                    controller: _textEditingController,
                    maxLength: 150,
                    maxLines: 8,
                    decoration: const InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff291872)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xff291872)),
                        ),
                        labelText: '일기 작성',
                        labelStyle: TextStyle(color: Color(0xff291872))),
                  ),
                ),
                Visibility(
                    // 일기 열람
                    visible: !_visibility,
                    child: Text(_savedText!))
              ]),
            ),
            // 저장 or 수정 버튼
            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: _savebtn,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Color(0xffdbd5f6))),
                        onPressed: () {
                          // _visibility ? _hide() : _show();
                          setState(() {
                            _savebtn = false;
                            _editbtn = true;
                            _savetime = DateFormat('yyyy-MM-dd HH:mm:ss')
                                .format(
                                    DateTime.now().add(Duration(hours: 24)));
                            _savedText = _textEditingController.text;
                          });
                          saveDB();
                          // loadDB();
                        },
                        child: const Text(
                          '저장',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff291872),
                              backgroundColor: Color(0xffdbd5f6)),
                        ),
                      ),
                    ),
                    Visibility(
                        visible: _editbtn,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Color(0xffdbd5f6))),
                          onPressed: () {
                            setState(() {
                              _savedText = _textEditingController.text;
                            });
                            editDB();
                            // loadDB();
                          },
                          child: const Text(
                            '수정',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff291872),
                                backgroundColor: Color(0xffdbd5f6)),
                          ),
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
          title: const Text(
            '경고',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('정말 뒤로 가시겠습니까? 작성 중인 내용이 저장되지 않을 수 있습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                '계속 적기',
                style: TextStyle(
                    color: Color(0xff291872), fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go('/home');
              },
              child: const Text(
                '나가기',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // DB로부터 데이터 가져오기
  loadDB() async {
    final conn = await dbcon();
    IResultSet result;

    try {
      result = await conn
          .execute("SELECT * FROM content WHERE date = :day", {"day": day});

      if (result.numOfRows > 0) {
        for (final row in result.rows) {
          print(row.assoc());
          setState(() {
            if (row.colByName('text') == null) {
              _savedText = null;
            } else {
              _savedText = row.colByName('text');
            }
            if (row.colByName('savetime') == null) {
              _savetime = null;
            } else {
              _savetime = row.colByName('savetime');
            }
            if (row.colByName('emotion') == null) {
              _emotion = null;
            } else {
              _emotion = row.colByName('emotion');
            }
            if (row.colByName('music') == null) {
              _music = null;
            } else {
              _music = row.colByName('music');
            }
          });
        }
      }
    } catch (e) {
      print('load Error : $e');
    } finally {
      await conn.close();
    }
  }

  // DB에 date, text 데이터 추가
  saveDB() async {
    final conn = await dbcon();
    IResultSet result;

    try {
      result = await conn.execute(
          "INSERT INTO content (date, text, savetime) VALUES (:day, :text, :savetime)",
          {
            "day": DateFormat('yyyy-MM-dd').format(day),
            "text": _savedText,
            "savetime": _savetime
          });

      if (result.numOfRows > 0) {
        for (final row in result.rows) {
          setState(() {
            _savedText = row.colByName('text')!;
            _savetime = row.colByName('savetime')!;
            _emotion = row.colByName('emotion')!;
            _music = row.colByName('music')!;
          });
        }
        loadDB();
      }
    } catch (e) {
      print(' save Error : $e');
    } finally {
      await conn.close();
    }
  }

  // 현재 존재하는 키값의 text column 데이터 편집
  editDB() async {
    final conn = await dbcon();
    IResultSet result;

    try {
      result = await conn.execute(
          "UPDATE content SET text =:text WHERE (date = :day)",
          {"text": _savedText, "day": DateFormat('yyyy-MM-dd').format(day)});

      if (result.numOfRows > 0) {
        for (final row in result.rows) {
          setState(() {
            _date = row.colByName('date')!;
            _savedText = row.colByName('text')!;
            _savetime = row.colByName('savetime')!;
            _emotion = row.colByName('emotion')!;
            _music = row.colByName('music')!;
          });
        }
        loadDB();
      }
    } catch (e) {
      print('edit Error : $e');
    } finally {
      await conn.close();
    }
  }
}

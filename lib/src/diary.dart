import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'home.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mysql_client/mysql_client.dart';

class Diary extends StatefulWidget {
  const Diary({super.key});

  @override
  State<Diary> createState() => _DiaryState();
}

Future<MySQLConnection> dbcon() async {
  // MySQL 접속 설정
  final conn = await MySQLConnection.createConnection(
    // host: '127.0.0.1',
    // port: 3306,
    // userName: 'root',
    // password: 'qwer1234',
    // databaseName: 'diary', // optional

    host: '192.168.0.158',
    port: 3306,
    userName: 'user',
    password: 'qlalfqjsgh1234',
    databaseName: 'diary',
  );
  await conn.connect();
  print("Connected");

  return conn;
}

// 이미지 선택기능
final picker = ImagePicker();

class _DiaryState extends State<Diary> {
  late TextEditingController _textEditingController = TextEditingController();
  bool _visibility = true;
  bool _editbtn = false;
  bool _savebtn = true;
  String? _savetime = '';
  String? _emotion = '';
  String? _music = '';
  String? _savedText = '';
  String _result = '';
  final player = AudioPlayer();
  bool _isPlaying = true;
  XFile? image;

  Widget imageWidget = const SizedBox(
    height: 1,
    width: 1,
  );

  setImage() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    if (image != null) {
      setState(() {
        imageWidget = Stack(
          children: [
            SizedBox(height: 100, child: Image.file(File(image!.path))),
            IconButton(
                onPressed: () {
                  image = null;
                  setImage();
                },
                icon: const Icon(Icons.disabled_by_default))
          ],
        );
      });
    } else if (File(
            '${documentsDirectory.path}/${DateFormat('yyyy-MM-dd').format(day)}.jpg')
        .existsSync()) {
      setState(() {
        imageWidget = Stack(
          children: [
            SizedBox(
                height: 100,
                child: Image.file(File(
                    '${documentsDirectory.path}/${DateFormat('yyyy-MM-dd').format(day)}.jpg'))),
            IconButton(
                onPressed: () {
                  setState(() {
                    image = null;
                    imageWidget = const SizedBox(
                      height: 1,
                      width: 1,
                    );
                  });
                },
                icon: const Icon(Icons.disabled_by_default))
          ],
        );
      });
    } else {
      setState(() {
        imageWidget = const SizedBox(
          height: 1,
          width: 1,
        );
      });
    }
  }

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
    setImage();
    super.initState();
    loadDB();
  }

  saveImage() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    File file = File(
        '${documentsDirectory.path}/${DateFormat('yyyy-MM-dd').format(day)}.jpg');
    if (image != null) {
      file.writeAsBytesSync(await image!.readAsBytes());
    } else if (file.existsSync()) {
      file.deleteSync();
    }
  }

  // _loadSavedImage() async {
  //   Directory documentsDirectory = await getApplicationDocumentsDirectory();
  //   String imageFile =
  //       '${documentsDirectory.path}/${DateFormat('yyyy-MM-dd').format(day)}.jpg';
  //   if (File(imageFile).existsSync()) {
  //     setState(() {
  //       image = XFile.fromData(File(imageFile).readAsBytesSync());
  //     });
  //   }
  // }

  Future<void> _analyzeSentiment(String text) async {
    final response = await http.post(
      Uri.parse('http://192.168.0.55:5000/api/sentiment'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'text': text}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _result = '${data['emotion']}';
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  // 위젯
  @override
  Widget build(BuildContext context) {
    _textEditingController = TextEditingController(text: _savedText);
    String formattedDate = DateFormat('yyyy. MM. dd').format(day);

    if (_savedText != '' &&
        DateTime.now()
            .isBefore(DateFormat('yyyy-MM-dd HH:mm:ss').parse(_savetime!))) {
      _savebtn = false;
      _editbtn = true;
    } else if (_savedText != '' &&
        DateTime.now()
            .isAfter(DateFormat('yyyy-MM-dd HH:mm:ss').parse(_savetime!))) {
      _visibility = false;
      _savebtn = false;
      _editbtn = false;
    }

    return MaterialApp(
      theme: ThemeData(fontFamily: 'NPS'),
      home: Scaffold(
        // 앱바 (뒤로가기)
        appBar: AppBar(
          backgroundColor: Colors.white10,
          elevation: 0,
          // title: Text(formattedDate,
          //     style: const TextStyle(
          //       color: Color(0xff291872),
          //       fontSize: 20,
          //       // fontWeight: FontWeight.bold),
          //     )),
          // centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Color(0xff291872),
            onPressed: () {
              if (_textEditingController.text != _savedText) {
                _showAlertDialog();
              } else {
                GoRouter.of(context).go('/home');
              }
              visitedDate = day;
              player.dispose();
              image = null;
            },
          ),
        ),
        // 앱 페이지
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 0.15 * MediaQuery.of(context).size.height),
              IconButton(
                  onPressed: () {
                    if (_isPlaying) {
                      player.pause();
                    } else {
                      player.resume();
                    }
                    setState(() {
                      _isPlaying = !_isPlaying;
                    });
                  },
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow)),
              Text(
                formattedDate,
                style: const TextStyle(
                    color: Color(0xff291872),
                    fontSize: 27,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
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
                          XFile? pickedImage = await picker.pickImage(
                              source: ImageSource.camera);
                          if (pickedImage != null) {
                            setState(
                              () {
                                image = pickedImage;
                              },
                            );
                          }
                          setImage();
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
                          XFile? pickedImage = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (pickedImage != null) {
                            setState(
                              () {
                                image = pickedImage;
                              },
                            );
                          }
                          imageWidget = const SizedBox(
                            height: 1,
                            width: 1,
                          );
                          setImage();
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
              Padding(
                  padding: const EdgeInsets.fromLTRB(25, 25, 25, 25),
                  child: imageWidget),
              // 텍스트 영역
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Stack(children: [
                  Visibility(
                    // 일기 작성
                    visible: _visibility,
                    child: TextFormField(
                      style: TextStyle(fontSize: 17, height: 1.5),
                      cursorColor: Color(0xff291872),
                      controller: _textEditingController,
                      maxLength: 150,
                      maxLines: 5,
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 20),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff291872)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xff291872)),
                          ),
                          labelText: '일기 내용',
                          labelStyle: TextStyle(
                              color: Color(0xff291872), fontSize: 15)),
                    ),
                  ),
                  Visibility(
                      // 일기 열람
                      visible: !_visibility,
                      child: Text(
                        _savedText!,
                        style: TextStyle(fontSize: 18, height: 1.7),
                        textAlign: TextAlign.center,
                        maxLines: 7,
                      ))
                ]),
              ),
              // 저장 or 수정 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: _savebtn,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Color(0xffdbd5f6))),
                      onPressed: () async {
                        Directory documentsDirectory =
                            await getApplicationDocumentsDirectory();
                        if (_textEditingController.text != '') {
                          setState(() {
                            _savetime = DateFormat('yyyy-MM-dd HH:mm:ss')
                                .format(
                                    DateTime.now().add(Duration(hours: 24)));
                            _savedText = _textEditingController.text;
                          });
                          await _analyzeSentiment(_textEditingController.text);
                          String jsonString =
                              await rootBundle.loadString('assets/DB.json');

                          List<dynamic> jsonDataList = json.decode(jsonString);

                          List<Map<String, dynamic>> typedJsonDataList =
                              List<Map<String, dynamic>>.from(jsonDataList);

                          var emotionDataList = typedJsonDataList
                              .where((data) =>
                                  data['EMOTION'] == int.parse(_result))
                              .toList();

                          var random = Random();
                          var randomData = emotionDataList[
                              random.nextInt(emotionDataList.length)];
                          var emo = randomData['EMOTION'];
                          var url = randomData['URL'];
                          await player.play(UrlSource(url));
                          setState(() {
                            _emotion = emo.toString();
                            _music = url;
                            _savebtn = false;
                            _editbtn = true;
                          });
                        }
                        if (imageWidget !=
                            Stack(
                              children: [
                                SizedBox(
                                    height: 100,
                                    child: Image.file(File(
                                        '${documentsDirectory.path}/${DateFormat('yyyy-MM-dd').format(day)}.jpg'))),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        image = null;
                                        imageWidget = const SizedBox(
                                          height: 1,
                                          width: 1,
                                        );
                                      });
                                    },
                                    icon: const Icon(Icons.disabled_by_default))
                              ],
                            )) {
                          await saveImage();
                        }

                        saveDB();
                        await setImage();
                      },
                      child: const Text(
                        '저장',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff291872),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _editbtn,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Color(0xffdbd5f6))),
                      onPressed: () async {
                        Directory documentsDirectory =
                            await getApplicationDocumentsDirectory();
                        if (_textEditingController.text != '') {
                          setState(() {
                            _savedText = _textEditingController.text;
                          });
                          await _analyzeSentiment(_textEditingController.text);
                          String jsonString =
                              await rootBundle.loadString('assets/DB.json');

                          List<dynamic> jsonDataList = json.decode(jsonString);

                          List<Map<String, dynamic>> typedJsonDataList =
                              List<Map<String, dynamic>>.from(jsonDataList);

                          var emotionDataList = typedJsonDataList
                              .where((data) =>
                                  data['EMOTION'] == int.parse(_result))
                              .toList();

                          var random = Random();
                          var randomData = emotionDataList[
                              random.nextInt(emotionDataList.length)];
                          var emo = randomData['EMOTION'];
                          var url = randomData['URL'];
                          await player.play(UrlSource(url));
                          if (imageWidget !=
                              Stack(
                                children: [
                                  SizedBox(
                                      height: 100,
                                      child: Image.file(File(
                                          '${documentsDirectory.path}/${DateFormat('yyyy-MM-dd').format(day)}.jpg'))),
                                  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          image = null;
                                          imageWidget = const SizedBox(
                                            height: 1,
                                            width: 1,
                                          );
                                        });
                                      },
                                      icon:
                                          const Icon(Icons.disabled_by_default))
                                ],
                              )) {
                            await saveImage();
                          }
                          setState(() {
                            _emotion = emo.toString();
                            _music = url;
                            image = null;
                          });
                          editDB();
                          await setImage();
                        }
                      },
                      child: const Text(
                        '수정',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xff291872),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
            ],
          ),
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
            style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'NPS'),
          ),
          content: const Text(
            '정말 뒤로 가시겠습니까? 작성 중인 내용이 저장되지 않을 수 있습니다.',
            style: TextStyle(
              fontFamily: 'NPS',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                '계속 적기',
                style: TextStyle(
                    color: Color(0xff291872),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NPS'),
              ),
            ),
            TextButton(
              onPressed: () {
                GoRouter.of(context).go('/home');
              },
              child: const Text(
                //'저장하고 나가기'로 develop
                '나가기',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NPS'),
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
          "INSERT INTO content (date, text, savetime, emotion, music) VALUES (:day, :text, :savetime, :emotion, :music)",
          {
            "day": DateFormat('yyyy-MM-dd').format(day),
            "text": _savedText,
            "savetime": _savetime,
            "emotion": _emotion,
            "music": _music
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
          "UPDATE content SET text =:text, emotion=:emotion, music=:music WHERE (date = :day)",
          {
            "text": _savedText,
            "emotion": _emotion,
            "music": _music,
            "day": DateFormat('yyyy-MM-dd').format(day),
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
      print('edit Error : $e');
    } finally {
      await conn.close();
    }
  }
}

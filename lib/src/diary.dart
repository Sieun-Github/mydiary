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
    // // localhost
    // host: '127.0.0.1',
    // port: 3306,
    // userName: 'root',
    // password: 'qwer1234',
    // databaseName: 'diary',

    // 외부 컴퓨터로 사용 시
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
  late Timer _timer;
  bool _visibility = true;
  bool _editbtn = false;
  bool _savebtn = true;
  bool isPositionedVisible = false;
  // late bool isPositionedVisible;
  String? _savetime = '';
  String? _emotion = '';
  String? _music = '';
  String? _savedText = '';
  String? singerdb = '';
  String? titledb = '';
  String _result = '';
  String? _title = '';
  String? _singer = '';
  double _currentPosition = 0.0;
  double _totalDuration = 0.0;
  // AudioPlayer p = AudioPlayer();
  final player = AudioPlayer();
  bool _isPlaying = false;
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

  // 데이터 저장 관련 함수
  @override
  void initState() {
    setImage();
    super.initState();
    loadDB();

    // 현재 오디오의 위치를 주기적으로 가져오기 위한 Timer 설정
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (_isPlaying) {
        Duration? duration = await player.getCurrentPosition();
        if (duration != null) {
          setState(() {
            _currentPosition = duration.inSeconds.toDouble();
          });
        }
      }
    });
    // 현재 오디오의 총 시간을 가져오기 위한 이벤트 리스너 등록
    player.onDurationChanged.listen((Duration duration) {
      setState(() {
        _totalDuration = duration.inSeconds.toDouble();
      });
    });
    //오디오가 종료될 때 타이머도 취소하도록 하세요.
    player.onPlayerComplete.listen((event) {
      _timer.cancel();
    });
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

    // 수정 가능 / 수정 불가능 페이지 구분
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

    if (_music != '') {
      isPositionedVisible = true;
      player.setSourceUrl(_music!);
      // if (!_isPlaying) {
      //   player.pause();
      // } else {
      //   player.resume();
      // }
    }

    return MaterialApp(
      theme: ThemeData(fontFamily: 'NPS'),
      home: Scaffold(
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
              visitedDate = day;
              player.dispose();
              _timer.cancel();
              isPositionedVisible = false;
              image = null;
            },
          ),
        ),
        // 앱 페이지
        body: Container(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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
                                    contentPadding:
                                        EdgeInsets.fromLTRB(10, 0, 10, 20),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xff291872)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Color(0xff291872)),
                                    ),
                                    labelText: '일기 내용',
                                    labelStyle: TextStyle(
                                        color: Color(0xff291872),
                                        fontSize: 15)),
                              ),
                            ),
                            Visibility(
                                // 일기 열람
                                visible: !_visibility,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    // border: Border.all(
                                    //     width: 1.3,
                                    //     color:
                                    //         Color.fromARGB(255, 211, 203, 246)),
                                    border: Border(
                                      right: BorderSide(
                                        color:
                                            Color.fromARGB(255, 211, 203, 246),
                                        width: 1.3,
                                      ),
                                      top: BorderSide(
                                        color:
                                            Color.fromARGB(255, 211, 203, 246),
                                        width: 1.3,
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 0, 5, 5),
                                    child: Text(
                                      _savedText!,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          height: 1.7,
                                          color: Color(0xff291872)),
                                      textAlign: TextAlign.center,
                                      maxLines: 7,
                                    ),
                                  ),
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
                                    backgroundColor: MaterialStateProperty.all(
                                        Color(0xffdbd5f6))),
                                onPressed: () async {
                                  // p.dispose();
                                  Directory documentsDirectory =
                                      await getApplicationDocumentsDirectory();
                                  if (_textEditingController.text != '') {
                                    setState(() {
                                      _savetime =
                                          DateFormat('yyyy-MM-dd HH:mm:ss')
                                              .format(DateTime.now()
                                                  .add(Duration(hours: 24)));
                                      _savedText = _textEditingController.text;
                                    });
                                    await _analyzeSentiment(
                                        _textEditingController.text);
                                    String jsonString = await rootBundle
                                        .loadString('assets/DB.json');

                                    List<dynamic> jsonDataList =
                                        json.decode(jsonString);

                                    List<Map<String, dynamic>>
                                        typedJsonDataList =
                                        List<Map<String, dynamic>>.from(
                                            jsonDataList);

                                    var emotionDataList = typedJsonDataList
                                        .where((data) =>
                                            data['EMOTION'] ==
                                            int.parse(_result))
                                        .toList();

                                    var random = Random();
                                    var randomData = emotionDataList[
                                        random.nextInt(emotionDataList.length)];
                                    var emo = randomData['EMOTION'];
                                    var url = randomData['URL'];
                                    var title = randomData['TITLE'];
                                    var singer = randomData['SINGER'];
                                    await player.setSourceUrl(url);
                                    setState(() {
                                      _emotion = emo.toString();
                                      _music = url;
                                      _savebtn = false;
                                      _editbtn = true;
                                      _title = title;
                                      _singer = singer;
                                      isPositionedVisible = true;
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
                                              icon: const Icon(
                                                  Icons.disabled_by_default))
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
                                    backgroundColor: MaterialStateProperty.all(
                                        Color(0xffdbd5f6))),
                                onPressed: () async {
                                  // p.dispose();
                                  final player = AudioPlayer();
                                  Directory documentsDirectory =
                                      await getApplicationDocumentsDirectory();
                                  if (_textEditingController.text != '') {
                                    setState(() {
                                      _savedText = _textEditingController.text;
                                    });
                                    await _analyzeSentiment(
                                        _textEditingController.text);
                                    String jsonString = await rootBundle
                                        .loadString('assets/DB.json');

                                    List<dynamic> jsonDataList =
                                        json.decode(jsonString);

                                    List<Map<String, dynamic>>
                                        typedJsonDataList =
                                        List<Map<String, dynamic>>.from(
                                            jsonDataList);

                                    var emotionDataList = typedJsonDataList
                                        .where((data) =>
                                            data['EMOTION'] ==
                                            int.parse(_result))
                                        .toList();

                                    var random = Random();
                                    var randomData = emotionDataList[
                                        random.nextInt(emotionDataList.length)];
                                    var emo = randomData['EMOTION'];
                                    var url = randomData['URL'];
                                    var title = randomData['TITLE'];
                                    var singer = randomData['SINGER'];
                                    await player.setSourceUrl(url);
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
                                                    imageWidget =
                                                        const SizedBox(
                                                      height: 1,
                                                      width: 1,
                                                    );
                                                  });
                                                },
                                                icon: const Icon(
                                                    Icons.disabled_by_default))
                                          ],
                                        )) {
                                      await saveImage();
                                    }
                                    setState(() {
                                      _emotion = emo.toString();
                                      _music = url;
                                      _title = title;
                                      _singer = singer;
                                      image = null;
                                      isPositionedVisible = true;
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
                    )),
              ),
              // 하단바 (TITLE, SINGER, ICON)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Visibility(
                  visible: isPositionedVisible,
                  child: AppBar(
                    backgroundColor: Color.fromARGB(255, 219, 213, 246),
                    elevation: 0.0,
                    title: Row(
                      children: [
                        // TITLE과 SINGER를 묶어서 좌측 상단에 배치
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, top: 8.0),
                                child: Text(
                                  _title!,
                                  style: TextStyle(
                                      color: Color(0xff291872), fontSize: 14),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, bottom: 8.0),
                                child: Text(
                                  _singer!,
                                  style: TextStyle(
                                      color: Color(0xff291872), fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Play/Pause 아이콘
                        IconButton(
                          onPressed: () {
                            // player.onPlayerStateChanged.listen((event) {
                            //   if(event == PlayerState.playing){
                            //     player.pause();
                            //   }else if(event == PlayerState.paused){
                            //     player.resume();
                            //   }
                            //  });
                            if (_isPlaying) {
                              player.pause();
                              
                            } else {
                              player.resume();
                            }
                            setState(() {
                              _isPlaying = !_isPlaying;
                            });
                          },
                          icon:
                              Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                          color: Color(0xff291872),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // 프로그레스 바 추가
              Positioned(
                left: -50,
                right: -50,
                bottom: kToolbarHeight - 29,
                child: Visibility(
                  visible: isPositionedVisible,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    title: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      child: SliderTheme(
                        data: SliderThemeData(
                          thumbShape: SliderComponentShape.noThumb,
                          overlayShape: SliderComponentShape.noOverlay,
                          inactiveTrackColor: Colors.white,
                        ),
                        child: Slider(
                          value: _currentPosition,
                          min: 0.0,
                          max: _totalDuration,
                          onChanged: (value) {
                            player.seek(Duration(seconds: value.toInt()));
                          },
                        ),
                      ),
                    ),
                  ),
                ),
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

            if (row.colByName('title') == null) {
              _title = null;
            } else {
              _title = row.colByName('title');
            }

            if (row.colByName('singer') == null) {
              _singer = null;
            } else {
              _singer = row.colByName('singer');
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
          "INSERT INTO content (date, text, savetime, emotion, music, singer, title) VALUES (:day, :text, :savetime, :emotion, :music, :singer, :title)",
          {
            "day": DateFormat('yyyy-MM-dd').format(day),
            "text": _savedText,
            "savetime": _savetime,
            "emotion": _emotion,
            "music": _music,
            "singer": _singer,
            "title": _title
          });

      if (result.numOfRows > 0) {
        for (final row in result.rows) {
          setState(() {
            _savedText = row.colByName('text')!;
            _savetime = row.colByName('savetime')!;
            _emotion = row.colByName('emotion')!;
            _music = row.colByName('music')!;
            _title = row.colByName('singer')!;
            _singer = row.colByName('title')!;
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
          "UPDATE content SET text =:text, emotion=:emotion, music=:music, singer=:singer, title=:title WHERE (date = :day)",
          {
            "text": _savedText,
            "emotion": _emotion,
            "music": _music,
            "singer": _singer,
            "title": _title,
            "day": DateFormat('yyyy-MM-dd').format(day),
          });

      if (result.numOfRows > 0) {
        for (final row in result.rows) {
          setState(() {
            _savedText = row.colByName('text')!;
            _savetime = row.colByName('savetime')!;
            _emotion = row.colByName('emotion')!;
            _music = row.colByName('music')!;
            titledb = row.colByName('title');
            singerdb = row.colByName('singer');
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

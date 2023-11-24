import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'home.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Diary extends StatefulWidget {
  const Diary({super.key});

  @override
  State<Diary> createState() => _DiaryState();
}

final picker = ImagePicker();
XFile? image;
List<XFile?> multiImage = [];
List<XFile?> images = [];

class _DiaryState extends State<Diary> {
  late SharedPreferences prefs;
  late TextEditingController _textEditingController = TextEditingController();
  bool _visibility = true;
  String _savedText = '';

  //visibility 설정
  void _show(){
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
    _loadSavedText();
  }

  _loadSavedText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedText = prefs.getString('$day') ?? "";
    });
  }

  _saveText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('$day', _textEditingController.text);
    _loadSavedText(); // 저장 후에는 불러와서 화면에 반영
  }

  //위젯
  @override
  Widget build(BuildContext context) {

    _textEditingController = TextEditingController(text: _savedText);
    String formattedDate = DateFormat('yyyy. MM. dd.').format(day);
    return Scaffold(
      //앱바
      appBar: AppBar(backgroundColor:Colors.white10,
      elevation:0,
      leading:IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Color(0xff291872),
                onPressed: () {
                _showAlertDialog();
                },
              ),),
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
                  visible:_visibility,
                child:
                Container(
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
                ),),
                // 갤러리에서 추가 아이콘
                Visibility(visible: _visibility,
                  child:
                Container(
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
                ),)
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
              child: Stack (
                children: [
                  Visibility(
                    // 일기 작성
                visible: _visibility,
                child:
               TextFormField( 
                controller: _textEditingController,
                maxLength: 150,
                maxLines: 8,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '일기 작성',
                ),
              ),),
              Visibility(
                // 일기 열람
                visible: !_visibility,
              child: Text(_savedText))]),
              
            ),
            // 저장 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Visibility(visible: _visibility,
               child:ElevatedButton(
              onPressed: () {
                _visibility? _hide():_show();
                _saveText();
                _loadSavedText();
              },
              child: const Text('저장'),
            ),)],)
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
                GoRouter.of(context).go('/');
              },
              child: const Text('나가기'),
            ),
          ],
        );
      },
    );
  }
}

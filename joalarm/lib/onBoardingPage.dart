import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joalarm/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert' show ascii, base64, json, utf8;
import 'dart:convert';
import 'dart:async';
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:joalarm/main.dart';

final safeStorage = FlutterSecureStorage();
File? _image;

class OnBoardingPage extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void displayDialog(context, title, text) => showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );

  Future<String> attemptLogIn(String username, String password) async {
    var url = Uri.parse('$SERVER_IP/login');
    var res = await http
        .post(url, body: {"username": username, "password": password});

    if (res.statusCode == 200) return res.body;
    return 'Failed..';
  }

  Future<int> attemptSignUp(String username, String password) async {
    var url = Uri.parse('$SERVER_IP/signup');
    var res = await http
        .post(url, body: {"username": username, "password": password});
    return res.statusCode;
  }

  final storage = FlutterSecureStorage();
  upload(File imageFile) async {
    String? _jwt = await storage.read(key: 'jwt');
    Map<String, dynamic> _payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(_jwt!.split(".")[1]))));

    // open a bytestream
    var stream =
        new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();

    // string to uri
    var uri = Uri.parse("$SERVER_IP/upload");

    // create multipart request
    var request = new http.MultipartRequest("POST", uri)
      ..fields['userid'] = "${_payload['userid']}";

    // multipart that takes file
    var multipartFile = new http.MultipartFile('myFile', stream, length,
        filename: basename(imageFile.path));

    // add file to multipart
    request.files.add(multipartFile);

    // send
    var response = await request.send();
    print(response.statusCode);

    // listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      print(value);
    });

    // fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 30,
          ),
          MyPhotoPage(),
          SizedBox(
            height: 10,
          ),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: '用戶名稱'),
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: '用戶密碼'),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  var username = _usernameController.text;
                  var password = _passwordController.text;
                  var jwt = await attemptLogIn(username, password);
                  print(jwt != 'Failed..');
                  if (jwt != 'Failed..' &&
                      username.isNotEmpty &&
                      password.isNotEmpty) {
                    safeStorage.write(key: "jwt", value: jwt);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePage.fromBase64(jwt)));
                  } else {
                    displayDialog(context, "Ooops!錯誤..", "沒有這個帳號(前往[註冊]或檢查密碼)");
                  }
                },
                child: Text("登入"),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () async {
                  var username = _usernameController.text;
                  var password = _passwordController.text;

                  if (username.length < 4)
                    displayDialog(context, "太短的帳號!", "帳號名稱請至少輸入4個文字或符號");
                  else if (password.length < 4)
                    displayDialog(context, "太短的密碼!", "為了安全，密碼請至少輸入4個文字或符號");
                  else {
                    var res = await attemptSignUp(username, password);
                    if (res == 201)
                      displayDialog(context, "太讚了!成功喇~", "我們已為您註冊好帳號。快去[登入]吧!");
                    else if (res == 409)
                      displayDialog(context, "這個帳號名稱已被其他人使用過了..可惜",
                          "請試試看其他帳號名稱或[登入]已有的帳號");
                    else {
                      displayDialog(context, "糟糕..", "這是甚麼錯誤我們也不知道，重開app看看吧~");
                    }
                  }
                  await attemptUpdateUserToken();
                  await upload(_image!);
                },
                child: Text("註冊"),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
              )
            ],
          )
        ],
      ),
    ));
  }
}

class MyPhotoPage extends StatefulWidget {
  @override
  _MyPhotoPageState createState() => _MyPhotoPageState();
}

class _MyPhotoPageState extends State<MyPhotoPage> {
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Center(
        child: _image == null
            ? Text('請選取一張照片..')
            : CircleAvatar(radius: 99, child: Image.file(_image!)),
      ),
      IconButton(
          tooltip: '請選取相片', onPressed: getImage, icon: Icon(Icons.add_a_photo))
    ]);
  }
}

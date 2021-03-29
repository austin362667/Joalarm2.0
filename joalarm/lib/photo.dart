import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:async';
import 'package:async/async.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joalarm/constants.dart';
import 'package:path/path.dart';

class ImageUpload extends StatefulWidget {
  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  File? _image;
  final picker = ImagePicker();

  Future<void> getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('請選取照片!');
      }
    });
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

    fetch();
  }

  bool isloaded = false;
  var result;
  fetch() async {
    String? _jwt = await storage.read(key: 'jwt');
    Map<String, dynamic> _payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(_jwt!.split(".")[1]))));
    print("fetch: ${_payload['userid']}");

    var url = Uri.parse('$SERVER_IP/image');
    var res = await http.post(url, body: {"userid": "${_payload['userid']}"});

    // var response = await http
    // .post('$SERVER_IP/image', body: {"userid": "${_payload['userid']}"});
    result = res.body;
    print("r   " + result.toString());
    setState(() {
      isloaded = true;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("編輯個人檔案"),
        ),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("選取一張照片"),
              ElevatedButton.icon(
                onPressed: () async => await getImage(),
                icon: Icon(Icons.image),
                label: Text("瀏覽相簿"),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              isloaded
                  ? CircleAvatar(
                      radius: 99,
                      backgroundImage: NetworkImage(
                        '$SERVER_IP/$result',
                      ))
                  : CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
              SizedBox(
                height: 15,
              ),
              ElevatedButton.icon(
                onPressed: () => upload(_image!),
                icon: Icon(Icons.upload_rounded),
                label: Text("馬上更新"),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
              )
            ],
          ),
        )));
  }
}

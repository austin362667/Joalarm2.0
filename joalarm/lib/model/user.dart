import 'dart:convert';

import 'package:http/http.dart';

class JUser {
  final String? id;
  final String? name;
  final String? cnt;
  final String? token;
  final String? image;

  JUser({this.id, this.name, this.token, this.cnt, this.image});

  factory JUser.fromJson(Map<String, dynamic> json) {
    return JUser(
      id: json['id'].toString(),
      name: json['name'].toString(),
      token: json['token'].toString(),
      cnt: json['cnt'].toString(),
      image: json['image'].toString(),
    );
  }
}

// class UserViewModel {
//   static List<User> users;

//   static Future loadUsers() async {
//     try {
//       List<User> _users;
//       Response res = await get('http://66.228.52.222:3000/allUser');
//       String jsonString = res.body.toString();
//       Map parsedJson = json.decode(jsonString);
//       // var categoryJson = parsedJson['users'] as List;
//       for (int i = 0; i < parsedJson.length; i++) {
//         _users.add(new User.fromJson(parsedJson[i]));
//       }
//       users = _users;
//     } catch (e) {
//       print(e);
//     }
//   }
// }

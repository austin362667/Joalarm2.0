import 'dart:async';
import 'dart:convert';
import 'dart:math';
// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:joalarm/constants.dart';
import 'package:joalarm/introPage.dart';
import 'package:joalarm/model/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:joalarm/onBoardingPage.dart';
import 'package:joalarm/photo.dart';
import 'package:joalarm/simple_animations_package.dart';
import 'package:geolocator/geolocator.dart';
import 'package:joalarm/messaging.dart';
import 'package:joalarm/welcome.dart';
// import 'package:workmanager/workmanager.dart';
import 'package:joalarm/notification.dart' as notif;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:like_button/like_button.dart';

const fetchBackground = "fetchBackground";
FirebaseMessaging? firebaseMessaging;
bool isLike = false;
var client = http.Client();
// void callbackDispatcher() {
//   Workmanager.executeTask((task, inputData) async {
//     switch (task) {
//       case fetchBackground:
//         //Geolocator geoLocator = Geolocator()..forceAndroidLocationManager = true;
//         Position userLocation = await Geolocator()
//             .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//         notif.Notification notification = new notif.Notification();
//         notification.showNotificationWithoutSound(userLocation);
//         // SharedPreferences prefs = await SharedPreferences.getInstance();
//         // String userId = prefs.getString('user_id');
//         // await _updateUserLocation(userLocation, userId);
//         await attemptUpdateUserLocation();

//         break;
//     }
//     return Future.value(true);
//   });
// }

String serverResponse = 'Hi';
Future<String> attemptGetUser() async {
  String? _jwt = await safeStorage.read(key: 'jwt');
  Map<String, dynamic> _payload = json.decode(
      ascii.decode(base64.decode(base64.normalize(_jwt!.split(".")[1]))));

  // var res = await http.post('$SERVER_IP/user',
  //     headers: {"Authorization": _jwt},
  //     body: {"userid": "${_payload['userid']}"});

  var url = Uri.parse('$SERVER_IP/user');
  var res = await http.post(url,
      headers: {"Authorization": _jwt},
      body: {"userid": "${_payload['userid']}"});

  if (res.statusCode == 201) return res.body;
  return res.statusCode.toString();
}

Future<int> attemptUpdateUserLocation() async {
  print('location upd');
  String? _jwt = await safeStorage.read(key: 'jwt');
  Map<String, dynamic> _payload = json.decode(
      ascii.decode(base64.decode(base64.normalize(_jwt!.split(".")[1]))));

  Position userLocation = await _determinePosition();
  // await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  String _long = userLocation.longitude.toString();
  String _lat = userLocation.latitude.toString();

  var url = Uri.parse('$SERVER_IP/userLocation');
  var res = await http.post(url, headers: {
    "Authorization": _jwt
  }, body: {
    "userid": "${_payload['userid']}",
    "long": "$_long",
    "lat": "$_lat"
  });

  // var res = await http.post('$SERVER_IP/userLocation', headers: {
  //   "Authorization": _jwt
  // }, body: {
  //   "userid": "${_payload['userid']}",
  //   "long": "$_long",
  //   "lat": "$_lat"
  // });
  return res.statusCode;
}

Future<int> attemptUpdateUserToken() async {
  String? _jwt = await safeStorage.read(key: 'jwt');
  Map<String, dynamic> _payload = json.decode(
      ascii.decode(base64.decode(base64.normalize(_jwt!.split(".")[1]))));

  firebaseMessaging = await configureMessaging();
  String? _fmsToken = await firebaseMessaging!.getToken();
  _fmsToken = _fmsToken.toString();
  var url = Uri.parse('$SERVER_IP/userToken');
  var res = await http.post(url,
      headers: {"Authorization": _jwt},
      body: {"userid": "${_payload['userid']}", "token": "$_fmsToken"});

  // var res = await http.post('$SERVER_IP/userToken',
  //     headers: {"Authorization": _jwt},
  //     body: {"userid": "${_payload['userid']}", "token": "$_fmsToken"});
  return res.statusCode;
}

Future<String> attemptCheckDistance() async {
  String? _jwt = await safeStorage.read(key: 'jwt');
  Map<String, dynamic> _payload = json.decode(
      ascii.decode(base64.decode(base64.normalize(_jwt!.split(".")[1]))));

  // var res = await http.post('$SERVER_IP/chkDistance',
  //     headers: {"Authorization": _jwt},
  //     body: {"userid": "${_payload['userid']}"});

  var url = Uri.parse('$SERVER_IP/chkDistance');
  var res = await http.post(url,
      headers: {"Authorization": _jwt},
      body: {"userid": "${_payload['userid']}"});
  return res.body;
}

Future<int> attemptCreateFollow(String followee) async {
  String? _jwt = await safeStorage.read(key: 'jwt');
  Map<String, dynamic> _payload = json.decode(
      ascii.decode(base64.decode(base64.normalize(_jwt!.split(".")[1]))));

  // var res = await http.post('$SERVER_IP/createFollow',
  //     headers: {"Authorization": _jwt},
  //     body: {"follower": "${_payload['userid']}", "followee": followee});
  var url = Uri.parse('$SERVER_IP/createFollow');
  var res = await http.post(url,
      headers: {"Authorization": _jwt},
      body: {"follower": "${_payload['userid']}", "followee": followee});
  return res.statusCode;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // await attemptUpdateUserLocation();
  // await attemptUpdateUserToken();
  runApp(MyApp());
}

class HomePage extends StatelessWidget {
  HomePage(this.jwt, this.payload);
  factory HomePage.fromBase64(String jwt) => HomePage(
      jwt,
      json.decode(
          ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1])))));
  final String jwt;
  final Map<String, dynamic> payload;

  void initState() async {
    // super.initState();
    await attemptUpdateUserLocation();
    await attemptUpdateUserToken();
    await attemptCheckDistance();
    // Workmanager.initialize(
    //   callbackDispatcher,
    //   isInDebugMode: true,
    // );

    // Workmanager.registerPeriodicTask(
    //   "1",
    //   fetchBackground,
    //   frequency: Duration(minutes: 15),
    // );
  }

  // @override
  // HomePageState createState() {
  //   return new HomePageState();
  // }
  @override
  // Widget build(BuildContext context) => Scaffold(
  //     appBar: AppBar(title: Text("Secret Data Screen")),
  //     body: Center(
  //       child: FutureBuilder(
  //           future: attemptGetUser("${payload['userid']}", jwt),
  //           builder: (context, snapshot) => snapshot.hasData
  //               ? Column(
  //                   children: <Widget>[
  //                     Text("${payload['username']}, here's the data:"),
  //                     Text(snapshot.data,
  //                         style: Theme.of(context).textTheme.headline4)
  //                   ],
  //                 )
  //               : snapshot.hasError
  //                   ? Text("An error occurred")
  //                   : CircularProgressIndicator()),
  //     ),
  //     floatingActionButton: FloatingActionButton(onPressed: () async {
  //       await attemptUpdateUserLocation("${payload['userid']}", jwt);
  //       await attemptUpdateUserToken("${payload['userid']}", jwt);
  //       await attemptCheckDistance("${payload['userid']}", jwt);
  //     }));
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('Joalarm'),
        // ),
        body: Center(
          child: Stack(
            children: <Widget>[
              // Positioned.fill(child: AnimatedBackground()),
              Positioned.fill(child: Particles(20)),
              Positioned.fill(child: CenteredText()),
            ],
          ),
        ),
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            backgroundColor: Colors.black,
            child: Icon(Icons.person),
            onPressed: () {
              // Navigate to the second screen using a named route.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageUpload(),
                ),
              );
            },
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            backgroundColor: Colors.black,
            child: Icon(
              Icons.search,
            ),
            onPressed: () {
              // Navigate to the second screen using a named route.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingPage(jwt, payload),
                ),
              );
            },
          ),
        ]));
  }
}

// class HomePageState extends State<HomePage> {
//   SharedPreferences _prefs;
//   FirebaseMessaging _firebaseMessaging;

//   @override
//   void initState() {
//     super.initState();

//     _firebaseMessaging = configureMessaging();
//     Workmanager.initialize(
//       callbackDispatcher,
//       isInDebugMode: true,
//     );

//     Workmanager.registerPeriodicTask(
//       "1",
//       fetchBackground,
//       frequency: Duration(minutes: 15),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Text('Joalarm'),
//       // ),
//       body: Center(
//         child: Stack(
//           children: <Widget>[
//             Positioned.fill(child: AnimatedBackground()),
//             Positioned.fill(child: Particles(20)),
//             Positioned.fill(child: CenteredText()),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.settings),
//         onPressed: () {
//           // Navigate to the second screen using a named route.
//           Navigator.pushNamed(context, '/second');
//         },
//       ),
//     );
//   }
// }

// class RegisterPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Register Page'),
//       ),
//       body: Center(),
//     );
//   }
// }

// class SettingPage extends StatefulWidget {
//   @override
//   _SettingPageState createState() => new _SettingPageState();
// }

class SettingPage extends StatelessWidget {
  SettingPage(this.jwt, this.payload);
  factory SettingPage.fromBase64(String jwt) => SettingPage(
      jwt,
      json.decode(
          ascii.decode(base64.decode(base64.normalize(jwt.split(".")[1])))));
  final String jwt;
  final Map<String, dynamic> payload;

  final TextEditingController nameController = new TextEditingController();
  // final TextEditingController followeeController = new TextEditingController();
  // StreamController<List<User>> _userStream;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  JUser? _selectedUser = new JUser();

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("搜尋其他人"),
        ),
        body: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              children: <Widget>[
                // Text('You'),
                // TextField(
                //   controller: nameController,
                //   decoration: InputDecoration(
                //     hintText: "Name..",
                //     // suffixIcon: IconButton(
                //     //   onPressed: _createUser(),
                //     //   icon: Icon(Icons.done),
                //     // ),
                //   ),
                // ),
                // ElevatedButton(
                //     onPressed: () {
                //       _createUser();
                //     },
                //     child: Icon(Icons.done)),
                Form(
                  key: this._formKey,
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: <Widget>[
                        Text(
                          '請輸入對方的名稱\n(不在名單裡嗎?快邀請朋友加入!)',
                          textAlign: TextAlign.center,
                        ),
                        TypeAheadFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: this._typeAheadController,
                          ),
                          suggestionsCallback: (pattern) async {
                            return await _fetchUserList(pattern);
                          },
                          itemBuilder: (context, JUser? suggestion) {
                            var isEmpty;
                            return Padding(
                                padding: EdgeInsets.all(5),
                                child: Row(children: [
                                  CircleAvatar(
                                      radius: 25,
                                      backgroundImage: NetworkImage(
                                        '$SERVER_IP/${suggestion!.image}',
                                      )),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    suggestion.name!,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ]));
                          },
                          transitionBuilder:
                              (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          onSuggestionSelected: (JUser? suggestion) async {
                            this._typeAheadController.text = suggestion!.name!;
                            this._selectedUser = suggestion;
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString('ta_id', suggestion.id!);
                            prefs.setString('ta_name', suggestion.name!);
                          },
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return '請選擇1位用戶!';
                            }
                          },
                          // onSaved: (value) => this._selectedUser = value,
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        ElevatedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: Icon(
                            Icons.done,
                          ),
                          onPressed: () {
                            if (this._formKey.currentState!.validate()) {
                              this._formKey.currentState!.save();
                              print(this._selectedUser!.id);
                              attemptCreateFollow(this._selectedUser!.id!);
                              // _createFollow();
                              // Scaffold.of(context).showSnackBar(SnackBar(
                              //   content: Text('Your Favorite City is ${this._selectedCity}')
                              // ));
                              displayDialog(
                                  context,
                                  "成功啦~ 擊掌!",
                                  "當你們彼此相距小於100m時\n❤❤" +
                                      this._selectedUser!.name! +
                                      " 的戀愛鈴將會秘密地被敲響!\n");
                            }
                          },
                        )
                      ],
                    ),
                  ),
                )
              ],
            )));
  }

  Future<List<JUser>> _fetchUserList(String val) async {
    List<JUser> _userList = [];
    var url = Uri.parse('http://66.228.52.222:3000/autocompleteUser/$val');
    var response = await http.get(url);
    // var response =
    // await http.get('http://66.228.52.222:3000/autocompleteUser/$val');
    if (response.statusCode == 200) {
      String jsonString = response.body.toString();
      final parsedJson = json.decode(jsonString);
      for (int i = 0; i < parsedJson.length; i++) {
        _userList.add(new JUser.fromJson(parsedJson[i]));
      }
    }
    return _userList;
  }

  // _createUser() async {
  //   // Response response;
  //   SharedPreferences prefs;
  //   prefs = await SharedPreferences.getInstance();

  //   if (nameController.text.isNotEmpty) {
  //     String userName = nameController.text;
  //     String fmsToken = await firebaseMessaging.getToken();
  //     var response = await http
  //         .get("http://66.228.52.222:3000/createUser/$userName/0/0/$fmsToken");

  //     await prefs.setString('user_name', userName);
  //     await prefs.setString(
  //         'user_id', response.body.toString().split(':')[1].split('}')[0]);
  //     // setState(() {
  //     //   serverResponse = response.body.toString() + ' ' + fmsToken;
  //     // });
  //   }
  //   // setState(() {
  //   //   serverResponse = 'Hi ' + prefs.getString('user_id');
  //   // });
  // }

  // _createFollow() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   String followerId = prefs.getString('user_id');
  //   String followeeId = prefs.getString('ta_id');
  //   // String followeeName = followeeController.text;
  //   // prefs.setString('followee_name', followeeName);
  //   // Response response =
  //   // await get("http://66.228.52.222:3000/userName/$followeeName");
  //   // String followeeId = response.body.toString().split(':')[1].split(',')[0];
  //   await http
  //       .get("http://66.228.52.222:3000/createFollow/$followerId/$followeeId");
  // }
}

// _updateUserLocation(Position userLocation, String _userId) async {
//   // SharedPreferences prefs = await SharedPreferences.getInstance();
//   // String userId = prefs.getString('user_id');
//   String long = userLocation.longitude.toString();
//   String lat = userLocation.latitude.toString();
//   await http
//       .get("http://66.228.52.222:3000/updateUserLocation/$_userId/$long/$lat");
// }

class Particles extends StatefulWidget {
  final int numberOfParticles;

  Particles(this.numberOfParticles);

  @override
  _ParticlesState createState() => _ParticlesState();
}

class _ParticlesState extends State<Particles> {
  final Random random = Random();

  final List<ParticleModel> particles = [];

  @override
  void initState() {
    List.generate(widget.numberOfParticles, (index) {
      particles.add(ParticleModel(random));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Rendering(
      startTime: Duration(seconds: 30),
      onTick: _simulateParticles,
      builder: (context, time) {
        return CustomPaint(
          painter: ParticlePainter(particles, time),
        );
      },
    );
  }

  _simulateParticles(Duration time) {
    particles.forEach((particle) => particle.maintainRestart(time));
  }
}

class ParticleModel {
  Animatable? tween;
  double? size;
  AnimationProgress? animationProgress;
  Random random;

  ParticleModel(this.random) {
    restart();
  }

  restart({Duration time = Duration.zero}) {
    final startPosition = Offset(-0.2 + 1.4 * random.nextDouble(), 1.2);
    final endPosition = Offset(-0.2 + 1.4 * random.nextDouble(), -0.2);
    final duration = Duration(milliseconds: 3000 + random.nextInt(6000));

    tween = MultiTrackTween([
      Track("x").add(
          duration, Tween(begin: startPosition.dx, end: endPosition.dx),
          curve: Curves.easeInOutSine),
      Track("y").add(
          duration, Tween(begin: startPosition.dy, end: endPosition.dy),
          curve: Curves.easeIn),
    ]);
    animationProgress = AnimationProgress(duration: duration, startTime: time);
    size = 0.2 + random.nextDouble() * 0.4;
  }

  maintainRestart(Duration time) {
    if (animationProgress!.progress(time) == 1.0) {
      restart(time: time);
    }
  }
}

class ParticlePainter extends CustomPainter {
  List<ParticleModel> particles;
  Duration time;

  ParticlePainter(this.particles, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    //indigoAccent
    final paint = Paint()..color = Colors.pinkAccent.withAlpha(25);

    particles.forEach((particle) {
      var progress = particle.animationProgress!.progress(time);
      final animation = particle.tween!.transform(progress);
      final position =
          Offset(animation["x"] * size.width, animation["y"] * size.height);
      canvas.drawCircle(position, size.width * 0.2 * particle.size!, paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("color1").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xff8a113a), end: Colors.black)),
      Track("color2").add(Duration(seconds: 3),
          ColorTween(begin: Color(0xff440216), end: Colors.blueAccent))
    ]);

    return ControlledAnimation(
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (context, dynamic animation) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [animation!['color1'], animation!["color2"]])),
        );
      },
      builderWithChild:
          (BuildContext, Widget child, Map<String, dynamic> animatedValue) {},
    );
  }
}

class CenteredText extends StatefulWidget {
  CenteredText();
  @override
  CenteredTextWidgetState createState() {
    return new CenteredTextWidgetState();
  }
}

class CenteredTextWidgetState extends State<CenteredText>
    with TickerProviderStateMixin {
  String cnt = '0';

  // _sync() async {
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // String userId = prefs.getString('user_id');
  // // String followeeName = prefs.getString('followee_name');
  // String followeeId = prefs.getString('ta_id');
  // var res = await http.get("http://66.228.52.222:3000/userId/$followeeId");
  // // String followeeId = res.body.toString().split(':')[1].split(',')[0];
  // // String followeeToken = res.body.toString().split(':"')[3].split('"')[0];
  // User _followee;
  // String jsonString = res.body.toString();
  // final parsedJson = json.decode(jsonString);
  // _followee = new User.fromJson(parsedJson);

  // Position userLocation = await Geolocator()
  //     .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  // await _updateUserLocation(userLocation, userId);

  // res =
  //     await http.get("http://66.228.52.222:3000/chkDis/$userId/$followeeId");
  // double distance =
  //     double.parse(res.body.toString().split(':')[1].split('}')[0]);

  //   if (distance <= 250) {
  //     await http.get("http://66.228.52.222:3000/updateUserCnt/$followeeId");
  //     await sendAndRetrieveMessage(_followee.token, '💖💖半徑100m內有喜歡妳/你的人!');
  //     setState(() {
  //       // cnt = _followee.token;
  //     });
  //   } else {
  //     await sendAndRetrieveMessage(_followee.token, '半徑100m內沒有喜歡妳/你的人，但是...');
  //   }

  //   var res2 = await http.get("http://66.228.52.222:3000/userId/$userId");
  //   User _user;
  //   String jsonString2 = res2.body.toString();
  //   final parsedJson2 = json.decode(jsonString2);
  //   _user = new User.fromJson(parsedJson2);
  //   setState(() {
  //     cnt = '${_user.cnt}';
  //     // prefs.setInt('cnt', int.parse(cnt));
  //   });
  // }

  AnimationController? _controller;
  Tween<double> _tween = Tween(begin: 0.75, end: 2);
  String? jwt;
  Map<String, dynamic>? payload;

  @override
  void initState() {
    super.initState();
    // _sync();
    _controller =
        AnimationController(duration: const Duration(seconds: 10), vsync: this);
    _controller!.repeat(reverse: true);
  }

  // Future getData() async {
  //   print('good');
  //   String _jwt = await safeStorage.read(key: 'jwt');
  //   Map<String, dynamic> _payload = json.decode(
  //       ascii.decode(base64.decode(base64.normalize(_jwt.split(".")[1]))));
  //   setState(() {
  //     jwt = _jwt;
  //     payload = _payload;
  //   });
  // }

  bool isloaded = false;
  var result;
  fetch() async {
    String? _jwt = await safeStorage.read(key: 'jwt');
    Map<String, dynamic> _payload = json.decode(
        ascii.decode(base64.decode(base64.normalize(_jwt!.split(".")[1]))));

    var url = Uri.parse('$SERVER_IP/user');
    var res = await http.post(url,
        headers: {"Authorization": _jwt},
        body: {"userid": "${_payload['userid']}"});

    // var res = await http.post('$SERVER_IP/user',
    //     headers: {"Authorization": _jwt},
    //     body: {"userid": "${_payload['userid']}"});
    result = res.body;
    setState(() {
      isloaded = true;
    });
    // print(
    //   isloaded,
    // );
  }

  @override
  Widget build(BuildContext context) {
    fetch(); //TODO
    attemptUpdateUserLocation();
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          // Container(
          //   // child: InkWell(
          //   child: ScaleTransition(
          //     scale: _tween.animate(CurvedAnimation(
          //         parent: _controller!, curve: Curves.elasticInOut)),
          //     child: LikeButton(
          //       size: 60,
          //       onTap: onLikeButtonTapped,
          //     ),
          //   ),
          //   // ),
          //   padding: EdgeInsets.all(15),
          // ),
          Container(
            child: isloaded
                ? Text(
                    JUser.fromJson(json.decode(result)).cnt!,
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.w200),
                    textScaleFactor: 6,
                  )
                : CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
            // FutureBuilder(
            //     future: attemptGetUser(),
            //     builder: (context, snapshot) => snapshot.hasData
            //         ? Column(
            //             children: <Widget>[
            //               // Text("${payload['username']}, here's the data:"),
            //               Text(
            //                 User.fromJson(json.decode(snapshot.data)).cnt,
            //                 style: TextStyle(
            //                     color: Colors.black,
            //                     fontWeight: FontWeight.w200),
            //                 textScaleFactor: 4,
            //               ),
            //             ],
            //           )
            //         : snapshot.hasError
            //             ? Text("An error occurred")
            //             : CircularProgressIndicator(
            //                 strokeWidth: 3,
            //                 valueColor: new AlwaysStoppedAnimation<Color>(
            //                     Colors.black),
            //               )),
          ),
          SizedBox(height: 40),
          Text(
            'Joalarm',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w200),
          )
        ]));
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    /// send your request here
    // final bool success= await sendRequest();

    /// if failed, you can do nothing
    // return success? !isLiked:isLiked;
    attemptUpdateUserLocation();
    fetch();
    doSomeThing();
    return !isLiked;
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joalarm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      initialRoute: '/welcome',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/welcome': (context) => IntroPage(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        // '/setting': (context) => SettingPage(),
      },
    );
  }
}

void displayDialog(context, title, text) => showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(title: Text(title), content: Text(text)),
    );

Future<void> doSomeThing() async {
  if (true) {
    print('do');
    await attemptUpdateUserLocation();
    await attemptUpdateUserToken();
    var r = await attemptCheckDistance();
    var pr = json.decode(r);
    bool v = pr['data'];
    String followeeId = pr['followee'];
    print(followeeId);

    var url = Uri.parse("http://66.228.52.222:3000/userId/$followeeId");
    var response = await http.get(url);

    // var res = await http.get("http://66.228.52.222:3000/userId/$followeeId");
    JUser _followee = JUser.fromJson(json.decode(response.body.toString()));
    print(_followee.token);
    if (v) {
      await sendAndRetrieveMessage(_followee.token!, '💖💖100m內有人敲響妳/你的戀愛鈴呢!');
    } else {
      await sendAndRetrieveMessage(_followee.token!, '敲響妳/你戀愛鈴的人似乎在100m外唷~');
    }
  }
}

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

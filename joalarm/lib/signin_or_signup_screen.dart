import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:joalarm/onBoardingPage.dart';
import 'package:joalarm/primary_button.dart';
import 'package:joalarm/constants.dart';
import 'package:joalarm/main.dart';
import 'package:flutter/material.dart';

final storage = FlutterSecureStorage();

class SigninOrSignupScreen extends StatelessWidget {
  Future<String> get jwtOrEmpty async {
    var jwt = await storage.read(key: "jwt");
    if (jwt == null) return "";
    return jwt;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
            future: jwtOrEmpty,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              if (snapshot.data != "") {
                String? str = snapshot.data.toString();
                var jwt = str.split(".");

                if (jwt.length != 3) {
                  return OnBoardingPage();
                } else {
                  var payload = json.decode(
                      ascii.decode(base64.decode(base64.normalize(jwt[1]))));
                  if (DateTime.fromMillisecondsSinceEpoch(payload["exp"] * 1000)
                      .isAfter(DateTime.now())) {
                    return HomePage(str, payload);
                  } else {
                    return OnBoardingPage();
                  }
                }
              } else {
                return OnBoardingPage();
              }
            }),
        // Image.asset(
        //   MediaQuery.of(context).platformBrightness == Brightness.light
        //       ? "icon.png"
        //       : "icon.png",
        //   height: 146,
        // ),
        // PrimaryButton(
        //   text: "Sign In",
        //   press: () {
        //     Navigator.pushNamed(context, '/');
        //   },
        // ),
        // SizedBox(height: kDefaultPadding * 1.5),
        // PrimaryButton(
        //   color: Theme.of(context).colorScheme.secondary,
        //   text: "Sign Up",
        //   press: () {},
        // ),
      ),
    );
  }
}

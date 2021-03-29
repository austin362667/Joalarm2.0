import 'package:joalarm/constants.dart';
import 'package:joalarm/signin_or_signup_screen.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Spacer(flex: 2),
            Image.asset("welcome_image.png"),
            Spacer(flex: 3),
            Text(
              "歡迎加入 Joalarm\n",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headline5!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Text(
              "戀愛鈴將被敲響，當方圓100m有人因妳/你而心動時。\n喜歡的話，快敲響對方的戀愛鈴吧！\n1.設定對象\n2.敲擊愛心\n3.???",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .color!
                    .withOpacity(0.64),
              ),
            ),
            Spacer(flex: 3),
            FittedBox(
              child: TextButton(
                  onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SigninOrSignupScreen(),
                        ),
                      ),
                  child: Row(
                    children: [
                      Text(
                        "Skip",
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .color!
                                .withOpacity(0.8)),
                      ),
                      SizedBox(width: kDefaultPadding / 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .color!
                            .withOpacity(0.8),
                      )
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}

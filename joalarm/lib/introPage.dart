import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:joalarm/onBoardingPage.dart';

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: listPagesViewModel,
      onDone: () {
        // When done button is press
      },
      onSkip: () {
        // You can also override onSkip callback
      },
      showSkipButton: false,
      skip: const Icon(Icons.skip_next),
      next: const Icon(Icons.navigate_next),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
          size: const Size.square(10.0),
          activeSize: const Size(20.0, 10.0),
          activeColor: Colors.black,
          color: Colors.black26,
          spacing: const EdgeInsets.symmetric(horizontal: 3.0),
          activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0))),
    );
  }
}

List<PageViewModel> listPagesViewModel = [
  PageViewModel(
      title: "歡迎使用 Joalarm",
      bodyWidget: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text(
            "在 Joalarm 的世界裡\n每個人都有專屬的一顆戀愛鈴",
            textAlign: TextAlign.center,
          ),
        ],
      ),
      image: const Center(child: Image(image: AssetImage('0.png')))),
  PageViewModel(
    title: "當周遭100m內",
    bodyWidget: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Text(
          "有人對您滋生情愫時\n戀愛鈴就會被敲響!",
          textAlign: TextAlign.center,
        ),
      ],
    ),
    image: const Center(child: Image(image: AssetImage('1.png'))),
  ),
  PageViewModel(
    title: "至於如何秘密地敲響對方的鈴呢?",
    bodyWidget: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Text(
          "完成帳號設定後\n點擊🔍️以告訴 Joalarm 演算法\n那個讓您怦然心動的人是誰",
          textAlign: TextAlign.center,
        ),
      ],
    ),
    image: const Center(child: Image(image: AssetImage('2.png'))),
  ),
  PageViewModel(
    title: "喜歡的話",
    bodyWidget: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Text(
          "就請敲響彼此的戀愛鈴吧~",
          textAlign: TextAlign.center,
        ),
      ],
    ),
    image: const Center(child: Image(image: AssetImage('3.png'))),
  ),
  PageViewModel(title: '', bodyWidget: OnBoardingPage())
];

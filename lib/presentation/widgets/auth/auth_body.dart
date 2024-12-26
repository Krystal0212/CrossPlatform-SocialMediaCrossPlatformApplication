import 'package:flutter/material.dart';

import '../../../utils/styles/themes.dart';

class AuthBody extends StatelessWidget {
  const AuthBody(
      {super.key,
      required this.child,
      required this.marginTop,
      required this.height,
      required this.isWeb});

  final double marginTop;
  final double height;
  final Widget child;
  final bool isWeb;
  final double cardWidth = 500;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double deviceWidth = constraints.constrainWidth();

      if (isWeb && constraints.constrainWidth() < 530) {
        return AuthBodyForm(
          edgeInsets: EdgeInsets.only(top: marginTop),
          width: deviceWidth,
          height: height,
          child: child,
        );
      } else {
        return AuthBodyForm(
          edgeInsets: EdgeInsets.only(top: marginTop),
          width: cardWidth,
          height: height,
          child: child,
        );
      }
    });
  }
}

class AuthBodyForm extends StatelessWidget {
  final double width, height;
  final Widget child;
  final EdgeInsets edgeInsets;

  const AuthBodyForm(
      {super.key,
      required this.edgeInsets,
      required this.width,
      required this.height,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: edgeInsets,
      width: width,
      height: height,
      padding: const EdgeInsets.only(top: 20, left: 25, right: 25),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: child,
    );
  }
}

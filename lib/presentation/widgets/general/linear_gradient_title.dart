import 'package:flutter/material.dart';
import 'package:socialapp/utils/styles/themes.dart';

class LinearGradientTitle extends StatelessWidget {
  const LinearGradientTitle(
      {super.key, required this.text, required this.textStyle});

  final String text;
  final TextStyle textStyle;
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect rect) {
        return AppTheme.mainGradient.createShader(Rect.fromLTWH(0, 0, rect.width, rect.height),);
      },
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}
import 'package:flutter/material.dart';

import 'colors.dart';

abstract class AppTextStyle {
  static const TextStyle uppercaseWhiteBigStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle uppercaseWhiteNormalStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle timestampStyle = TextStyle(
      fontSize: 18,
      color:AppColors.blackOak,
  );

  static const TextStyle tabItemStyle = TextStyle(
    fontSize: 12,
  );

  static const TextStyle contentPost = TextStyle(
      fontSize: 14,
      color: AppColors.trolleyGrey,
      fontFamily: 'CircularStd',
      wordSpacing: 1.5
  );
}
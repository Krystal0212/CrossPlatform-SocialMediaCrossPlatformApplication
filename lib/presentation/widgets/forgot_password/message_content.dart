import 'package:flutter/material.dart';

import '../../../utils/styles/colors.dart';

class MessageContent extends StatelessWidget {
  const MessageContent({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: AppColors.foundationWhite,
          borderRadius: BorderRadius.circular(12)),
      child:
      Text(
        text,
        style: const TextStyle(
          color: AppColors.verifiedBlack,
        ),
        textAlign: TextAlign.center,
      )
      ,
    );
  }
}

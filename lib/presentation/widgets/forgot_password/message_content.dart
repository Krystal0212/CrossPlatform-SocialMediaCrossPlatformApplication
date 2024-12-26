import 'package:flutter/material.dart';

import '../../../utils/styles/colors.dart';

class MessageContent extends StatelessWidget {
  const MessageContent({super.key, required this.stringNotifier});

  final ValueNotifier<String> stringNotifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: AppColors.foundationWhite,
          borderRadius: BorderRadius.circular(12)),
      child: ValueListenableBuilder(
        valueListenable: stringNotifier,
        builder: (context, value, child) {
          return Text(
            value,
            style: const TextStyle(
              color: AppColors.verifiedBlack,
            ),
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }
}

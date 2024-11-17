import 'package:flutter/material.dart';

import '../../../utils/constants/image_path.dart';
import '../../../utils/styles/colors.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key, this.center, this.column});

  final Center? center;
  final Column? column;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        height: MediaQuery.of(context).size.height * 1,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(AppImages.splashBackground), fit: BoxFit.cover),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.4,
              child: Container(
                color: AppColors.iric,
              ),
            ),
            if (center != null) center!,
            if (column != null) column!,
          ],
        ),
      ),
    );
  }
}

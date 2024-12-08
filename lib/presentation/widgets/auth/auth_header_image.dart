import 'package:flutter/material.dart';
import 'package:socialapp/utils/constants/image_path.dart';
import 'package:socialapp/utils/styles/colors.dart';

class AuthHeaderImage extends StatelessWidget {
  final double heightRatio, childAspectRatio;
  final bool isWeb;
  final Positioned? positioned;

  final double cardWidth = 500;
  final List<String> imagePaths = [
    AppImages.signInThumb1,
    AppImages.signInThumb2,
    AppImages.signInThumb3,
    AppImages.signInThumb4
  ];

  AuthHeaderImage(
      {super.key,
      required this.heightRatio,
      required this.isWeb,
      this.positioned,
      required this.childAspectRatio});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final double deviceWidth = constraints.constrainWidth();
      final double deviceHeight = constraints.constrainHeight();

      return Container(
        width: (isWeb && deviceWidth < 530) ? deviceWidth : 500,
        height: deviceHeight * heightRatio,
        color: AppColors.lead,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: (isWeb)? childAspectRatio*1.3 : childAspectRatio,
                // padding: EdgeInsets.zero,
                children: [
                  ...imagePaths.map((imagePath) => Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(imagePath), fit: BoxFit.cover),
                        ),
                      )),
                ],
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(AppImages.authMask),
                        fit: BoxFit.cover)),
              ),
            ),
            positioned ?? Container(),
          ],
        ),
      );
    });
  }
}

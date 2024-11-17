import 'package:flutter/material.dart';
import 'package:socialapp/utils/constants/image_path.dart';
import 'package:socialapp/utils/styles/colors.dart';

class AuthHeaderImage extends StatelessWidget {
  const AuthHeaderImage(
      {super.key,
      required this.height,
      this.positioned,
      required this.childAspectRatio});

  final double height;
  final Positioned? positioned;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * height,
      color: AppColors.lead,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: childAspectRatio,
              padding: EdgeInsets.zero,
              children: [
                for (var image in [
                  AppImages.signInThumb1,
                  AppImages.signInThumb2,
                  AppImages.signInThumb3,
                  AppImages.signInThumb4
                ])
                  Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(image), fit: BoxFit.cover),
                    ),
                  ),
              ],
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(AppImages.loginMask),
                      fit: BoxFit.cover)),
            ),
          ),
          if (positioned != null) positioned!,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:socialapp/utils/constants/image_path.dart';
import 'package:socialapp/utils/styles/colors.dart';

class AuthHeaderImage extends StatelessWidget {
  const AuthHeaderImage({super.key, required this.height});

  final double height;

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
              childAspectRatio: 1.5,
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
          Positioned.fill(
            top: -45,
            child: Center(
              child: Text(
                "WELCOME",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 40,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 2 // Độ dày của viền chữ
                    ..color = AppColors.white, // Màu viền
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

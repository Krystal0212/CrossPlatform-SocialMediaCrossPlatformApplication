import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

//Hình splash
class SplashImage extends StatelessWidget {
  const SplashImage(
      {super.key,
      this.top,
      this.left,
      this.bottom,
      this.right,
      required this.width,
      required this.height,
      this.gradient,
      this.image});

  final double? top;
  final double? left;
  final double? bottom;
  final double? right;

  final double width;
  final double height;

  final LinearGradient? gradient;
  final DecorationImage? image;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: ClipPath(
        clipper: ParallelogramClipper(),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: gradient,
            image: image,
          ),
        ),
      ),
    );
  }
}

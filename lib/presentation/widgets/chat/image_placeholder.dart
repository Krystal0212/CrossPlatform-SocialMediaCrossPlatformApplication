import 'package:socialapp/utils/import.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ImagePlaceholder extends StatelessWidget {
  final double height;
  final double width;

  const ImagePlaceholder({
    super.key,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: const Color.fromARGB(255, 216, 216, 216),
        highlightColor: const Color.fromARGB(255, 255, 255, 255),
        child: Container(
          color: Colors.amber,
          width: width,
          height: height,
        ));
  }
}

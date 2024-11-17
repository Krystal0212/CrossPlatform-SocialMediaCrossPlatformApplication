import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class SvgIconButton extends StatelessWidget {
  final String assetPath;
  final double iconSize;
  final VoidCallback onPressed;

  const SvgIconButton({
    super.key,
    required this.assetPath,
    this.iconSize = 18.0, // Default icon size 24
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color:  Colors.blue,
      icon: SvgPicture.asset(
        assetPath,
        height: iconSize,
        width: iconSize,
      ),
      onPressed: onPressed,
    );
  }
}

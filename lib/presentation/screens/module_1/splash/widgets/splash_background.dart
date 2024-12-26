import 'package:flutter/material.dart';
import 'package:socialapp/presentation/widgets/general/custom_container.dart';

class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key, this.center, this.column});

  final Center? center;
  final Column? column;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: BackgroundContainer(opacity: 0.1, center: center, column: column)
    );
  }
}

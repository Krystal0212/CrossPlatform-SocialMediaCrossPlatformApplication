import 'package:flutter/material.dart';
import '../../../utils/styles/themes.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double width;

  const CustomFloatingActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.width,

  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: AppTheme.gradientFabBoxDecoration,
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        label: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: AppTheme.buttonGradientStyle,
          ),
        ),
      ),
    );
  }
}

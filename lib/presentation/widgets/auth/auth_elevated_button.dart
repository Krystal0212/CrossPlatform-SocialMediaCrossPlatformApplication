import 'package:flutter/material.dart';
import 'package:socialapp/utils/styles/colors.dart';
import 'package:socialapp/utils/styles/themes.dart';

class AuthElevatedButton extends StatelessWidget {
  const AuthElevatedButton(
      {super.key,
      required this.width,
      required this.height,
      required this.inputText,
      this.onPressed,
      required this.isLoading, this.isDisable});

  final double width;
  final double height;
  final String inputText;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool? isDisable;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: (isDisable??false) ? AppTheme.disableGradient : AppTheme.mainGradient,
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        onPressed: isLoading ?(){}: onPressed ,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppColors.iris,
                  strokeWidth: 2,
                ),
              )
            : Text(
                inputText,
                style: AppTheme.authWhiteText,
              ),
      ),
    );
  }
}


class AuthElevatedNoBackgroundButton extends StatelessWidget {
  const AuthElevatedNoBackgroundButton(
      {super.key,
        required this.width,
        required this.height,
        required this.inputText,
        this.onPressed,
        required this.isLoading,});

  final double width;
  final double height;
  final String inputText;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: ElevatedButton(
        onPressed: isLoading ?(){}: onPressed ,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent),
        child:  Text(
          inputText,
          style: AppTheme.authSignUpStyle,
        ),
      ),
    );
  }
}

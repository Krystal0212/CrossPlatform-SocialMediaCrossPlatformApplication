import 'package:flutter/material.dart';
import 'package:socialapp/utils/styles/colors.dart';

import '../../../utils/styles/themes.dart';

class AuthTextFormField extends StatelessWidget {
  const AuthTextFormField(
      {super.key,
      required this.textEditingController,
      required this.hintText,
      this.suffixIcon,
      this.obscureText = false,
      this.validator,
      this.textInputAction,
      this.textAlign});

  final TextEditingController textEditingController;
  final String hintText;
  final IconButton? suffixIcon;
  final bool obscureText;
  final FormFieldValidator? validator;
  final TextInputAction? textInputAction;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTheme.appHintStyle,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        fillColor: AppColors.chefsHat,
        filled: true,
        suffixIcon: suffixIcon,
      ),
      autovalidateMode: AutovalidateMode.onUnfocus,
      obscureText: obscureText,
      validator: validator,
      textInputAction: textInputAction,
      textAlign: textAlign ?? TextAlign.start,
    );
  }
}

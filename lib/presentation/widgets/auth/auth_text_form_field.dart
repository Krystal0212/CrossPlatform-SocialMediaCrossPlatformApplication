import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
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
      this.textAlign,  this.focusNode,  this.onFieldSubmitted});

  final TextEditingController textEditingController;
  final String hintText;
  final IconButton? suffixIcon;
  final bool obscureText;
  final FormFieldValidator? validator;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
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
      focusNode: focusNode,
      onFieldSubmitted: onFieldSubmitted,
      autovalidateMode: AutovalidateMode.onUnfocus,
      obscureText: obscureText,
      validator: validator,
      textInputAction: textInputAction,
      textAlign: textAlign ?? TextAlign.start,
    );
  }
}

class PinCodeTextFieldWidget extends StatelessWidget {
  final ValueChanged<String> onCompleted;

  const PinCodeTextFieldWidget({super.key, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      length: 6,
      obscureText: false,
      keyboardType: TextInputType.number,
      animationType: AnimationType.fade,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(10),
        fieldHeight: 50,
        fieldWidth: 45,
        activeFillColor: Colors.white,
        inactiveFillColor: Colors.white,
        selectedFillColor: Colors.white,
      ),
      cursorColor: AppColors.iris,
      animationDuration: const Duration(milliseconds: 300),
      enableActiveFill: false,
      onCompleted: onCompleted,
      appContext: context,
    );
  }
}
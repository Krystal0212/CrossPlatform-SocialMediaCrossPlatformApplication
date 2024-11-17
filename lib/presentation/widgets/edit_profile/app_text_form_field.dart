import 'package:flutter/material.dart';
import 'package:socialapp/utils/styles/colors.dart';
import 'package:socialapp/utils/styles/themes.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField(
      {super.key,
        required this.controller,
        required this.label,
        required this.hintText,
        required this.width,
        this.suffixIcon,
        this.obscureText = false,
        this.validator,
        this.textInputAction,
        this.textAlign, required this.focusNode, required this.onFieldSubmitted});

  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hintText;
  final double width;
  final IconButton? suffixIcon;
  final bool obscureText;
  final FormFieldValidator? validator;
  final TextInputAction? textInputAction;
  final TextAlign? textAlign;
  final Function(String?) onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.appLabelStyle,),
          const SizedBox(height: 10,),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            onFieldSubmitted: onFieldSubmitted,
            decoration: InputDecoration(
              hintText: hintText,
              contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
              suffixIcon: suffixIcon,
            ),
            obscureText: obscureText,
            validator: validator,
            textInputAction: textInputAction,
            style: AppTheme.profileCasualStyle.copyWith(color: AppColors.blackOak),
            textAlign: textAlign ?? TextAlign.start,
            autovalidateMode: AutovalidateMode.onUnfocus,
          ),
        ],
      ),
    );
  }
}

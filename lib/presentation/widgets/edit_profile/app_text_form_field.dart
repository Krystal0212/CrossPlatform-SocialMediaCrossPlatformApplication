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
        this.keyboardType,
      this.textAlign,
      required this.focusNode,
      required this.onFieldSubmitted,
      required this.onChanged});

  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hintText;
  final double width;
  final IconButton? suffixIcon;
  final bool obscureText;
  final FormFieldValidator? validator;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final TextAlign? textAlign;
  final Function(String?) onFieldSubmitted;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.appLabelStyle,
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            onFieldSubmitted: onFieldSubmitted,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTheme.appHintStyle.copyWith(fontSize: 22),
              errorStyle: AppTheme.appErrorStyle,
              errorMaxLines: 2,
              border: OutlineInputBorder(
                borderRadius: AppTheme.smallBorderRadius,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
              suffixIcon: suffixIcon,
            ),
            onChanged: onChanged,
            obscureText: obscureText,
            validator: validator,
            textInputAction: textInputAction,
            style: AppTheme.profileCasualStyle
                .copyWith(color: AppColors.blackOak, fontSize: 22),
            textAlign: textAlign ?? TextAlign.start,
            keyboardType: keyboardType,
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ],
      ),
    );
  }
}

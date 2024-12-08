import 'package:flutter/material.dart';
import 'package:socialapp/utils/styles/colors.dart';

class CommentIcon extends StatelessWidget {
  const CommentIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: () {
    }, icon: const Icon(Icons.comment_outlined, color: AppColors.carbon,));
  }
}
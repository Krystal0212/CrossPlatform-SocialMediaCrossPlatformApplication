import 'package:flutter/material.dart';
import 'package:socialapp/utils/styles/text_style.dart';

class TabItem extends StatelessWidget {
  final String title;
  // final int count;

  const TabItem({
    super.key,
    required this.title,
    // required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyle.tabItemStyle
      ),
    );
  }
}
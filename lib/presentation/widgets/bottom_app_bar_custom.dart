import 'package:flutter/material.dart';
import 'package:socialapp/utils/styles/colors.dart';

class BottomNavBarCustom extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBarCustom({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 76,
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.home, size: 20, color: AppColors.carbon),
            onPressed: () => onTap(0), // Navigate to Home
          ),
          IconButton(
            icon: const Icon(Icons.category_sharp, size: 20, color: AppColors.carbon),
            onPressed: () => onTap(1), // Navigate to Categories
          ),
          IconButton(
            icon: const Icon(Icons.notifications, size: 20, color: AppColors.carbon),
            onPressed: () => onTap(2), // Navigate to Notifications
          ),
          IconButton(
            icon: const Icon(Icons.person, size: 20, color: AppColors.carbon),
            onPressed: () => onTap(3), // Navigate to Profile
          ),
        ],
      ),
    );
  }
}
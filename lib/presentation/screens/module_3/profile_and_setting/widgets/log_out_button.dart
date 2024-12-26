
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:socialapp/domain/repository/auth/auth_repository.dart';
import 'package:socialapp/service_locator.dart';

import '../../../../utils/constants/icon_path.dart';
import '../../../../utils/styles/themes.dart';
import '../cubit/profile_cubit.dart';

class LogOutButton extends StatelessWidget {
  const LogOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // context.read<ProfileCubit>().signOut(); // Trigger logout
        serviceLocator<AuthRepository>().signOut();
        context.go('/sign-in');
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: AppTheme.black,
        backgroundColor:  AppTheme.white,
        // Text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Border radius
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        // Padding
        elevation: 2, // Elevation for shadow effect
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        // Minimize the button size to fit content
        children: [
          SvgPicture.asset(
            AppIcons.logOut, // Path to your logout icon
            height: 24, // Size of the icon
            width: 24,
          ),
          const SizedBox(width: 8), // Space between icon and text
          Text(
            'Logout',
            style: AppTheme.logOutButtonStyle, // Text style
          ),
        ],
      ),
    );
  }
}

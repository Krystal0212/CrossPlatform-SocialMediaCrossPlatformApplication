import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/presentation/screens/profile_and_setting/profile_part.dart';
import 'package:socialapp/presentation/screens/profile_and_setting/setting_part.dart';
import 'package:socialapp/presentation/screens/profile_and_setting/widgets/profile_box.dart';

import '../../../utils/constants/image_path.dart';
import '../../../utils/styles/themes.dart';
import 'cubit/profile_cubit.dart';
import 'cubit/profile_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ProfileCubit()..fetchProfile()),
      ],
      child: MultiBlocListener(
        listeners: [
          // Listener for ProfileCubit to handle email change
          BlocListener<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileEmailChanged) {
                // Show alert dialog to notify user to verify the new email
                showDialog(
                  context: context,
                  builder: (BuildContext buildContext) {
                    return AlertDialog(
                      title: Text('Email Changed',style: AppTheme.blackHeaderStyle, ),
                      content: Text('Please verify your new email to continue using the account.', style: AppTheme.appHintStyle,),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(buildContext).pop();
                            context.read<ProfileCubit>().signOut();
                            Future.delayed(const Duration(milliseconds: 100), () {

                            });
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              } else if (state is ProfileLoggedOut) {
              }
              else if (state is ProfileError){
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Error During Changed',style: AppTheme.blackHeaderStyle, ),
                      content: Text(state.message, style: AppTheme.appHintStyle,),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.read<ProfileCubit>().signOut();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
        ],
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.settingBackground),
                fit: BoxFit.cover,
              ),
            ),
            child: const Stack(
              children: <Widget>[
                SettingPart(),
                ProfileBox(),
                ProfilePart(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


import 'package:socialapp/utils/import.dart';

import 'cubit/profile_cubit.dart';
import 'cubit/profile_state.dart';
import 'profile_part.dart';
import 'setting_part.dart';
import 'widgets/profile_box.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
      );
  }
}


// listener: (context, state) {
// if (state is ProfileEmailChanged) {
// showDialog(
// context: context,
// builder: (BuildContext buildContext) {
// return AlertDialog(
// title: Text(
// 'Email Changed',
// style: AppTheme.blackHeaderStyle,
// ),
// content: Text(
// 'Please verify your new email to continue using the account.',
// style: AppTheme.appHintStyle,
// ),
// actions: <Widget>[
// TextButton(
// onPressed: () {
// Navigator.of(buildContext).pop();
// context.read<ProfileCubit>().signOut();
// Future.delayed(
// const Duration(milliseconds: 100), () {});
// },
// child: const Text('OK'),
// ),
// ],
// );
// },
// );
// } else if (state is ProfileLoggedOut) {
// // Handle logged out state if needed
// } else if (state is ProfileError) {
// // if (kDebugMode) {
// //   print("Error during changed ${state.message}");
// // }
// // showDialog(
// //   context: context,
// //   builder: (BuildContext context) {
// //     return AlertDialog(
// //       title: Text('Error During Changed',style: AppTheme.blackHeaderStyle, ),
// //       content: Text(state.message, style: AppTheme.appHintStyle,),
// //       actions: <Widget>[
// //         TextButton(
// //           onPressed: () {
// //             Navigator.of(context).pop();
// //             context.read<ProfileCubit>().signOut();
// //           },
// //           child: const Text('OK'),
// //         ),
// //       ],
// //     );
// //   },
// // );
// }
// },
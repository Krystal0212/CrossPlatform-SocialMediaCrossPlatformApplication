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
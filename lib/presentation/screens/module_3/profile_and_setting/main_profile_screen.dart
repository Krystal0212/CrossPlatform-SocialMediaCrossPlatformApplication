import 'package:socialapp/utils/import.dart';

import 'cubit/profile_cubit.dart';
import 'cubit/profile_state.dart';
import 'setting_part.dart';
import 'widgets/profile_box.dart';

class ProfileScreen extends StatefulWidget {
  final bool isSignedIn;

  const ProfileScreen({super.key, required this.isSignedIn});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isSignedIn) {
      return const NoUserIsSignedInPlaceholder();
    }

    return Scaffold(
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
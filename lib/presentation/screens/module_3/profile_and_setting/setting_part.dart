import 'package:socialapp/utils/import.dart';

import 'widgets/rounded_icon_image.dart';

class SettingPart extends StatefulWidget {
  const SettingPart({super.key});

  @override
  State<SettingPart> createState() => _SettingPartState();
}

class _SettingPartState extends State<SettingPart> {
  late double deviceWidth;
  late double deviceHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.only(top: deviceHeight * 0.15),
        width: deviceWidth * 0.45,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrawerItem(title: AppStrings.changePassword, onPressed: () {}),
            DrawerItem(title: AppStrings.aboutZineround, onPressed: () {}),
            DrawerItem(
              title: AppStrings.termPrivacy,
              onPressed: () {},
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: LogOutButton(),
            )
          ],
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const DrawerItem({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        width: deviceWidth * 0.7,
        height: deviceHeight * 0.06,
        padding: const EdgeInsets.only(left: 16, right: 0, top: 7, bottom: 7),
        decoration: ShapeDecoration(
          color: Colors.white.withOpacity(0.3),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: AppTheme.drawerItemStyle,
            ),
            const Spacer(),
            RoundedTrailingIcon(
              ovalColor: AppTheme.white.withOpacity(0.4),
              iconSize: 36,
            ),
          ],
        ),
      ),
    );
  }
}

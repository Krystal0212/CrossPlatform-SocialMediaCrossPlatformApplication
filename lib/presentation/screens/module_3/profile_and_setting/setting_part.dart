


import 'package:socialapp/utils/import.dart';

import 'widgets/rounded_icon_image.dart';

class SettingPart extends StatefulWidget {
  const SettingPart({super.key});

  @override
  State<SettingPart> createState() => _SettingPartState();
}

class _SettingPartState extends State<SettingPart> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
        width: MediaQuery.of(context).size.width * 0.66,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DrawerItem(title: AppStrings.email, onPressed: () {}),
            DrawerItem(title: AppStrings.instagram, onPressed: () {}),
            DrawerItem(title: AppStrings.twitter, onPressed: () {}),
            DrawerItem(title: AppStrings.website, onPressed: () {}),
            DrawerItem(title: AppStrings.paypal, onPressed: () {}),
            DrawerItem(title: AppStrings.changePassword, onPressed: () {}),
            DrawerItem(title: AppStrings.aboutIClick, onPressed: () {}),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.06,
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

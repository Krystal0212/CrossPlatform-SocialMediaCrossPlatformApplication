import 'package:flutter/material.dart';

import '../../../../utils/constants/icon_path.dart';
import '../../../../utils/styles/colors.dart';
import '../../../../utils/styles/themes.dart';
import '../../../widgets/general/svg_icon_button.dart';

class ProfileBox extends StatelessWidget {
  const ProfileBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.1,
          color: AppColors.white.withOpacity(0.1),
          child: ListTile(
            title: Text(
              'Profile Box',
              style: AppTheme.profileCasualStyle,
            ),
            trailing: SvgIconButton(
              assetPath: AppIcons.editSquare,
              onPressed: () async {
                // ignore: unused_local_variable
                final Object? result;
                // if (result is UserModel){
                //   if(!result.emailChanged) {
                //   }else{
                // }}
              },
            ),
          ),
        ),
      ),
    );
  }
}
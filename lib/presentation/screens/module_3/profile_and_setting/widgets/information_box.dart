

import 'package:socialapp/utils/import.dart';

class InformationBox extends StatelessWidget {
  final UserModel userModel;
  final List<String> userFollowers;
  final List<String> userFollowings;


  const InformationBox({super.key, required this.userModel, required this.userFollowers, required this.userFollowings});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width*0.9,
      alignment: Alignment.center,
      child: Column(
        children: [
          Text('${userModel.name} ${userModel.lastName}', style: AppTheme.blackHeaderStyle),
          const SizedBox(
            height: 5,
          ),
          Text(
            userModel.location.isNotEmpty ? userModel.location: "Not updated" ,
            style: AppTheme.profileLocationStyle,
          ),
          const SizedBox(
            height: 25,
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.lynxWhite,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: userFollowers.length.toString(),
                        style: AppTheme.profileNumberStyle,
                      ),
                      TextSpan(
                        text: '  Followers',
                        style: AppTheme.profileCasualStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20,),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: userFollowings.length.toString(),
                        style: AppTheme.profileNumberStyle,
                      ),
                      TextSpan(
                        text: '  Following',
                        style: AppTheme.profileCasualStyle,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.55,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    if (kDebugMode) {
                      print(userModel.socialAccounts['website']);
                    }
                  },
                  icon: SvgPicture.asset(AppIcons.globe),
                ),
                SvgPicture.asset(AppIcons.gradientDot),
                IconButton(
                  onPressed: () {
                    if (kDebugMode) {
                      print(userModel.socialAccounts['instagramId']);
                    }
                  },
                  icon: SvgPicture.asset(AppIcons.instagram),
                ),
                SvgPicture.asset(AppIcons.gradientDot),
                IconButton(
                  onPressed: () {
                    if (kDebugMode) {
                      print(userModel.socialAccounts['facebookId']);
                    }
                  },
                  icon: SvgPicture.asset(AppIcons.facebook),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

import 'package:socialapp/utils/import.dart';

class InformationBox extends StatelessWidget {
  final UserModel? userModel;
  final List<String>? userFollowers;
  final List<String>? userFollowings;

  const InformationBox(
      {super.key,
      required this.userModel,
      required this.userFollowers,
      required this.userFollowings});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
              '${userModel?.name ?? "Name"} ${userModel?.lastName ?? "Last name"}',
              style: AppTheme.blackHeaderStyle),
          const SizedBox(
            height: 5,
          ),
          if ((userModel != null) && (userModel?.location.isNotEmpty ?? false))
            Text(
              userModel!.location,
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
                        text: userFollowers?.length.toString() ?? '0',
                        style: AppTheme.profileNumberStyle,
                      ),
                      TextSpan(
                        text: '  Followers',
                        style: AppTheme.profileCasualStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: userFollowings?.length.toString() ?? '0',
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
                SvgPicture.asset(AppIcons.gradientDot),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.message_outlined,
                    color: AppColors.iris,
                    size: 35,
                  ),
                ),
                SvgPicture.asset(AppIcons.gradientDot),
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

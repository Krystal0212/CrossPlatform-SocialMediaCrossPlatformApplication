import 'package:socialapp/utils/import.dart';

import '../../edit_profile/edit_profile_screen.dart';
import '../cubit/profile_box_cubit.dart';
import '../cubit/profile_box_state.dart';

class ProfileBox extends StatelessWidget {
  const ProfileBox({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => ProfileBoxCubit(), child: const ProfileBoxBase());
  }
}

class ProfileBoxBase extends StatefulWidget {
  const ProfileBoxBase({super.key});

  @override
  State<ProfileBoxBase> createState() => _ProfileBoxBaseState();
}

class _ProfileBoxBaseState extends State<ProfileBoxBase> {
  late double deviceWidth = 0, deviceHeight = 0;

  ValueNotifier<UserModel> userDataNotifier = ValueNotifier(UserModel.empty());

  @override
  void initState() {
    super.initState();
    final flutterView = PlatformDispatcher.instance.views.first;
    deviceWidth = flutterView.physicalSize.width / flutterView.devicePixelRatio;
    deviceHeight = flutterView.physicalSize.height;
  }

  @override
  void dispose() {
    userDataNotifier.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: BlocBuilder<ProfileBoxCubit, ProfileBoxState>(
          builder: (context, state) {
        if (state is ProfileBoxLoaded) {
          userDataNotifier.value = state.user;
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.white.withOpacity(0.1),
              ),
              padding: const EdgeInsets.all(20),
              width: deviceWidth * 0.9,
              child: ValueListenableBuilder<UserModel>(
                  valueListenable: userDataNotifier,
                  builder: (context, avatarData, _) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: CircleAvatar(
                            radius: 45,
                            backgroundImage: NetworkImage(avatarData.avatar),
                          ),
                        ),
                        SizedBox(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                avatarData.name,
                                style: AppTheme.profileCasualStyle.copyWith(fontSize: 30),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Tag: ${avatarData.tagName}',

                                style: AppTheme.profileCasualStyle.copyWith(fontSize: 20),
                              )
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: SvgPicture.asset(
                            AppIcons.editSquare,
                            width: 35,
                            height: 35,
                          ),
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditProfile(userDataNotifier: userDataNotifier,)));
                          },
                        )
                      ],
                    );
                  }),
            ),
          );
        }
        return const EmptyProfileBox();
      }),
    );
  }
}

class EmptyProfileBox extends StatelessWidget {
  const EmptyProfileBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.1,
      color: AppColors.white.withOpacity(0.1),
      child: ListTile(
        title: Text(
          'Profile Box',
          style: AppTheme.profileCasualStyle,
        ),
      ),
    );
  }
}

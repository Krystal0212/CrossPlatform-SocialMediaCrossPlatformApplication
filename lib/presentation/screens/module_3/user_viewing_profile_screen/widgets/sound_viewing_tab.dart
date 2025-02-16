import 'package:socialapp/domain/entities/sound.dart';
import 'package:socialapp/utils/import.dart';

import '../cubit/sound_viewing_cubit.dart';
import '../cubit/sound_viewing_state.dart';

class SoundViewingTab extends StatefulWidget {
  final String userId;

  const SoundViewingTab({super.key, required this.userId});

  @override
  State<SoundViewingTab> createState() => _SoundViewingTabState();
}

class _SoundViewingTabState extends State<SoundViewingTab>
    with AutomaticKeepAliveClientMixin, FlashMessage {
  late double deviceHeight = 0, deviceWidth = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocProvider(
      create: (context) => SoundViewingTabCubit(userId: widget.userId),
      child: Padding(
        padding: EdgeInsets.only(
          top: 30,
          left: deviceWidth * 0.07,
          right: deviceWidth * 0.07,
        ),
        child: SingleChildScrollView(
          child: BlocBuilder<SoundViewingTabCubit, SoundViewingTabState>(
            builder: (context, state) {
              if (state is SoundViewingTabLoading ||
                  state is SoundViewingTabInitial) {
                return SizedBox(
                  height: deviceHeight * 0.3,
                  child: const Center(
                      child: CircularProgressIndicator(
                    color: AppColors.iris,
                  )),
                );
              } else if (state is SoundViewingTabLoaded) {
                List<PreviewSoundPostModel> soundPreviews = state.soundPosts;

                return FutureBuilder<UserModel?>(
                    future:
                        serviceLocator<UserRepository>().getCurrentUserData(),
                    builder: (context, userSnapshot) {
                      UserModel? currentUser = userSnapshot.data;

                      return Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: soundPreviews.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onLongPress: () {
                                  if (currentUser != null) {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => PostDetailScreen(
                                          postId: soundPreviews[index].postId,
                                          currentUser: currentUser,
                                          searchController:
                                          TextEditingController(),
                                        )));
                                  } else {
                                    showAttentionMessage(
                                        context: context,
                                        title:
                                            'Please sign in to view its post.');
                                  }
                                },
                                child: PostSimpleRecordWebsite(
                                  recordUrl: soundPreviews[index].recordUrl,
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: deviceHeight * 0.02,
                          )
                        ],
                      );
                    });
              }
              return NoPublicDataAvailablePlaceholder(
                width: deviceWidth * 0.9,
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // Keep the widget alive
}

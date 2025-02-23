import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socialapp/domain/entities/sound.dart';
import 'package:socialapp/utils/import.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../widgets/play_video/video_player_detail.dart';
import '../cubit/sound_cubit.dart';
import '../cubit/sound_state.dart';

class SoundTab1 extends StatefulWidget {

  const SoundTab1({super.key});

  @override
  State<SoundTab1> createState() => _SoundTab1State();
}

class _SoundTab1State extends State<SoundTab1>
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
      create: (context) => SoundPostCubit(),
      child: Padding(
        padding: EdgeInsets.only(
          top: 30,
          left: deviceWidth * 0.07,
          right: deviceWidth * 0.07,
        ),
        child: SingleChildScrollView(
          child: BlocBuilder<SoundPostCubit, SoundPostState>(
            builder: (context, state) {
              if (state is SoundPostLoaded) {
                return StreamBuilder<List<PreviewSoundPostModel>?>(
                    stream: state.postStreams,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: deviceHeight * 0.3,
                          child: const Center(
                              child: CircularProgressIndicator(
                            color: AppColors.iris,
                          )),
                        );
                      }

                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return NoPublicDataAvailablePlaceholder(
                          width: deviceWidth * 0.9,
                        );
                      }

                      List<PreviewSoundPostModel> soundPreviews =
                          snapshot.data!;


                      return FutureBuilder<UserModel?>(
                          future: serviceLocator<UserRepository>()
                              .getCurrentUserData(),
                          builder: (context, userSnapshot) {
                            UserModel? currentUser = userSnapshot.data;

                          return Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: soundPreviews.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: GestureDetector(
                                      onLongPress: () {
                                        if (currentUser != null) {
                                          Navigator.of(context)
                                              .push(PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                                PostDetailScreen(
                                                  postId:
                                                  soundPreviews[index].postId,
                                                  currentUser: currentUser,
                                                  searchController:
                                                  TextEditingController(),
                                                ),
                                            transitionDuration: Duration.zero,
                                            // No animation on push
                                            reverseTransitionDuration: Duration
                                                .zero, // No animation on pop
                                          ));
                                        } else {
                                          showNotSignedInMessage(
                                              context: context,
                                              description: AppStrings
                                                  .notSignedInCollectionDescription);
                                        }
                                      },
                                      child: PostSimpleRecordWebsite(
                                        recordUrl: soundPreviews[index].recordUrl,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                height: deviceHeight * 0.02,
                              )
                            ],
                          );
                        }
                      );
                    });
              }
              return Center(child: SvgPicture.asset(AppImages.empty));
            },
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // Keep the widget alive
}
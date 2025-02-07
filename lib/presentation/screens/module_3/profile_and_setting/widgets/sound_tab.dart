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
  final String userId;

  const SoundTab1({super.key, required this.userId});

  @override
  State<SoundTab1> createState() => _SoundTab1State();
}

class _SoundTab1State extends State<SoundTab1>
    with AutomaticKeepAliveClientMixin {
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
      create: (context) => SoundPostCubit(userId: widget.userId),
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

                      return Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: soundPreviews.length,
                            itemBuilder: (context, index) {
                              return PostSimpleRecordWebsite(
                                recordUrl: soundPreviews[index].recordUrl,
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

class PostSimpleRecordWebsite extends StatefulWidget {
  final String recordUrl;

  const PostSimpleRecordWebsite({super.key, required this.recordUrl});

  @override
  State<PostSimpleRecordWebsite> createState() =>
      _PostSimpleRecordWebsiteState();
}

class _PostSimpleRecordWebsiteState extends State<PostSimpleRecordWebsite> {
  final AudioPlayer player = AudioPlayer();

  Stream<DurationState>? durationState;
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<Stream<DurationState>?> durationStateNotifier = ValueNotifier(null);


  @override
  void initState() {
    super.initState();
    initialize();
    player.positionStream.listen((position) {
      final totalDuration = player.duration;
      if (totalDuration != null && position >= totalDuration) {
        // Mark as finished
        player.pause();
        player.seek(Duration.zero);
        isPlayingNotifier.value = false;
      } else {
        // Reset when not finished
      }
    });
    player.playerStateStream.listen((state) {
      isPlayingNotifier.value = state.playing;
    });
  }

  void initialize() async {
    await player.setUrl(widget.recordUrl);
    await Future.delayed(const Duration(milliseconds: 300));

    durationStateNotifier.value = Rx.combineLatest3<Duration, Duration, Duration?, DurationState>(
      player.positionStream,
      player.bufferedPositionStream,
      player.durationStream,
          (position, bufferedPosition, duration) => DurationState(
        progress: position,
        buffered: bufferedPosition,
        total: duration ?? Duration.zero,
      ),
    );
  }


  @override
  void dispose() {
    player.dispose();
    isPlayingNotifier.dispose();
    durationStateNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.blackOak,
            width: 1,
          )
        ),
        width: deviceWidth * 0.9,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: isPlayingNotifier,
              builder: (context, isPlaying, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (!isPlaying)
                      IconButton(
                        icon: const Icon(Icons.play_arrow, color: AppColors.blackOak, size: 25,),
                        onPressed: () async {
                          // if (player.processingState == ProcessingState.idle) {
                          //   await player.setUrl(widget.recordUrl);
                          // }
                          await player.play();
                        },
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.pause, color: AppColors.blackOak,size: 25,),
                        onPressed: () {
                          player.pause();
                        },
                      ),
                  ],
                );
              },
            ),
            const SizedBox(width: 20),
            // Use Expanded to allow the progress bar to take the remaining space
            Expanded(
              child: ValueListenableBuilder<Stream<DurationState>?>(
                valueListenable: durationStateNotifier,
                builder: (context, stream, child) {
                  if (stream == null) {
                    return ProgressBar(
                      progress: Duration.zero,
                      buffered: Duration.zero,
                      total: const Duration(seconds: 1),
                      timeLabelLocation: TimeLabelLocation.sides,
                      progressBarColor: AppColors.lightIris,
                      baseBarColor: AppColors.lightIris.withOpacity(0.2),
                      onSeek: (duration) {
                        player.seek(duration);
                      },
                    );
                  }
                  return StreamBuilder<DurationState>(
                    stream: stream,
                    builder: (context, snapshot) {
                      final durationState = snapshot.data;
                      final progress = durationState?.progress ?? Duration.zero;
                      final buffered = durationState?.buffered ?? Duration.zero;
                      final total = durationState?.total ?? Duration.zero;
                      return VisibilityDetector(
                        key: const Key('sound-player'),
                        onVisibilityChanged: (visibilityInfo) {
                          double visibleFraction = visibilityInfo.visibleFraction;
                          double ratioThreshold = (kIsWeb) ? 0.7 : 1;
                          if (visibleFraction < ratioThreshold) {
                            if (mounted) {
                              player.pause();
                              if (isPlayingNotifier.value) {
                                isPlayingNotifier.value = false;
                              }
                            }
                          }
                        },
                        child: ProgressBar(
                          progress: progress,
                          buffered: buffered,
                          total: total,
                          timeLabelLocation: TimeLabelLocation.sides,
                          progressBarColor: AppColors.iris,
                          baseBarColor: AppColors.iris.withOpacity(0.6),
                          bufferedBarColor: AppColors.iris.withOpacity(0.2),
                          thumbColor: AppColors.iris,
                          onSeek: (duration) {
                            player.seek(duration);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

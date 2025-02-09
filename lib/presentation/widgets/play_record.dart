import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:socialapp/utils/import.dart';
import 'package:rxdart/rxdart.dart';
import 'package:visibility_detector/visibility_detector.dart';

class DurationState {
  const DurationState(
      {required this.progress, required this.buffered, required this.total});

  final Duration progress;
  final Duration buffered;
  final Duration total;
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
  final ValueNotifier<
      Stream<DurationState>?> durationStateNotifier = ValueNotifier(null);


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

    durationStateNotifier.value =
        Rx.combineLatest3<Duration, Duration, Duration?, DurationState>(
          player.positionStream,
          player.bufferedPositionStream,
          player.durationStream,
              (position, bufferedPosition, duration) =>
              DurationState(
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
    double deviceWidth = MediaQuery
        .of(context)
        .size
        .width;

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
                        icon: const Icon(
                          Icons.play_arrow, color: AppColors.blackOak,
                          size: 25,),
                        onPressed: () async {
                          // if (player.processingState == ProcessingState.idle) {
                          //   await player.setUrl(widget.recordUrl);
                          // }
                          await player.play();
                        },
                      )
                    else
                      IconButton(
                        icon: const Icon(
                          Icons.pause, color: AppColors.blackOak, size: 25,),
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
                          double visibleFraction = visibilityInfo
                              .visibleFraction;
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

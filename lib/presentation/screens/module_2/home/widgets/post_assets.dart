import 'dart:async';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:socialapp/presentation/widgets/play_video/video_player_detail.dart';
import 'package:socialapp/utils/import.dart';
import 'package:rxdart/rxdart.dart';
import 'package:visibility_detector/visibility_detector.dart';

class PostAsset extends StatefulWidget {
  final OnlinePostModel post;
  final double postWidth;

  const PostAsset({super.key, required this.post, required this.postWidth});

  @override
  State<PostAsset> createState() => _PostAssetState();
}

class _PostAssetState extends State<PostAsset> {
  late GlobalKey _gridKey;
  late ValueNotifier<double> gridHeightNotifier;
  late double gridHeight = 280.0;
  late int mediaLength;
  late bool isWeb, isCachedData = false;

  late Map<String, OnlineMediaItem> media;

  @override
  void initState() {
    super.initState();

    mediaLength = widget.post.media?.length ?? 0;
    media = widget.post.media ?? {};

    if (widget.post.media?.isNotEmpty ?? false) {
      mediaLength = widget.post.media?.length ?? 0;
      media = widget.post.media ?? {};
      // isCachedData = widget.post.mediaOffline == null;
    }
    // else if (widget.post.mediaOffline != null && widget.post.mediaOffline!.isNotEmpty && !isWeb) {
    //   mediaLength = widget.post.media?.length ?? 0;
    //   media = widget.post.mediaOffline;
    //   isCachedData = true;
    // }
    else {
      mediaLength = 0;
      media = {};
      isCachedData = false;
    }

    _gridKey = GlobalKey();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isWeb = PlatformConfig.of(context)?.isWeb ?? false;

    gridHeight = isWeb ? gridHeight : 250;
  }

  @override
  Widget build(BuildContext context) {
    switch (mediaLength) {
      case 0:
        if (widget.post.record != null) {
          return PostSimpleRecordWebsite(
            recordUrl: widget.post.record!,
          );
        } else {
          return const ImageErrorPlaceholder();
        }
      case 1:
        return PostSimpleAsset(
          image: media.values.first,
          postWidth: widget.postWidth,
          isCachedData: isCachedData,
        );
      case 2:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          constraints: BoxConstraints(maxHeight: gridHeight, maxWidth: 580.0),
          child: GridView.builder(
              itemCount: mediaLength,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                return PostMultipleAsset(
                  image: media[index.toString()]!,
                  isCachedData: isCachedData,
                );
              }),
        );
      case 3:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          constraints: BoxConstraints(maxHeight: gridHeight, maxWidth: 580.0),
          child: GridView.custom(
            gridDelegate: SliverQuiltedGridDelegate(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              repeatPattern: QuiltedGridRepeatPattern.inverted,
              pattern: [
                const QuiltedGridTile(2, 2),
                const QuiltedGridTile(1, 2),
                const QuiltedGridTile(1, 2),
              ],
            ),
            childrenDelegate: SliverChildBuilderDelegate(
              (context, index) {
                return PostMultipleAsset(
                  image: media[index.toString()]!,
                  otherAssets: 0,
                  isCachedData: isCachedData,
                );
              },
              childCount: media.length,
            ),
          ),
        );
      default:
        Map<String, OnlineMediaItem> collapsedAssets = Map.fromEntries(
          media.entries.take(4),
        );
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          constraints: BoxConstraints(maxHeight: gridHeight, maxWidth: 580.0),
          child: GridView.custom(
            key: _gridKey,
            semanticChildCount: 4,
            gridDelegate: SliverQuiltedGridDelegate(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              repeatPattern: QuiltedGridRepeatPattern.inverted,
              pattern: [
                const QuiltedGridTile(2, 2),
                const QuiltedGridTile(1, 1),
                const QuiltedGridTile(1, 1),
                const QuiltedGridTile(1, 2),
              ],
            ),
            childrenDelegate: SliverChildBuilderDelegate(
              (context, index) {
                int? otherAssets;
                if (index == collapsedAssets.length - 1 &&
                    index != mediaLength - 1) {
                  otherAssets = mediaLength - collapsedAssets.length;
                }
                return PostMultipleAsset(
                  image: collapsedAssets[index.toString()]!,
                  otherAssets: otherAssets ?? 0,
                  isCachedData: isCachedData,
                );
              },
              childCount: collapsedAssets.length,
            ),
          ),
        );
    }
  }
}

class PostMultipleAsset extends StatelessWidget {
  final MediaItemBase image;
  final int? otherAssets;
  final bool isCachedData;

  const PostMultipleAsset({
    super.key,
    this.otherAssets,
    required this.image,
    required this.isCachedData,
  });

  @override
  Widget build(BuildContext context) {
    final Color dominantColor = Color(int.parse('0x${image.dominantColor}'));
    //     child: isCachedData ? Image.file(File((image as OfflineMediaItem).imageData. )):

    return InkWell(
      onTap: () {},
      child: (image.type == 'video')
          ? VideoPlayerDetailWidget(
        thumbnailUrl: (image as OnlineMediaItem).thumbnailUrl,
              videoUrl: (image as OnlineMediaItem).imageUrl,
              height: image.height,
              width: image.width,
              dominantColor: dominantColor,
            )
          : Stack(
              children: [
                Center(
                  child: Container(
                      color: dominantColor,
                      width: double.infinity,
                      height: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: (image as OnlineMediaItem).imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            const ImageErrorPlaceholder(),
                      )),
                ),
                if (otherAssets != null && otherAssets! > 0)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    alignment: Alignment.center,
                    child: Text(
                      "+$otherAssets",
                      style: AppTheme.topicLabelStyle,
                    ),
                  ),
              ],
            ),
    );
  }
}

class PostSimpleAsset extends StatelessWidget {
  final MediaItemBase image;
  final double postWidth;
  final bool isCachedData;

  final ValueNotifier<double> containerHeight = ValueNotifier<double>(400);
  final double maxHeight = 370;
  final double horizontalPadding = 10;

  PostSimpleAsset(
      {super.key,
      required this.image,
      required this.postWidth,
      required this.isCachedData});

  void _updateHeight(ImageProvider imageProvider, double mediaWidth) async {
    final double imageWidth = image.width;
    final double imageHeight = image.height;
    final double aspectRatio = imageWidth / imageHeight;

    if (aspectRatio > 1) {
      containerHeight.value =
          imageHeight.toDouble() * (mediaWidth / imageWidth);
    } else {
      containerHeight.value = maxHeight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double mediaWidth = postWidth - horizontalPadding * 2;
    // final String imageUrl = isCachedData? (image['uri'] ?? '') : (image['url'] ?? '') ;
    final String imageUrl = (image as OnlineMediaItem).imageUrl;

    final Color dominantColor = Color(int.parse('0x${image.dominantColor}'));

    final ImageProvider imageProvider = isCachedData
        ? FileImage(File(imageUrl))
        : CachedNetworkImageProvider(imageUrl);

    _updateHeight(imageProvider, mediaWidth);

    return Padding(
      padding:
          AppTheme.horizontalPostContentPaddingEdgeInsets(horizontalPadding),
      child: ValueListenableBuilder<double>(
        valueListenable: containerHeight,
        builder: (context, height, child) {
          if (image.type == 'video') {
            return VideoPlayerDetailWidget(
              videoUrl: (image as OnlineMediaItem).imageUrl,
              thumbnailUrl: (image as OnlineMediaItem).thumbnailUrl,
              height: height,
              width: double.infinity,
              dominantColor: dominantColor,
            );
          } else {
            return InkWell(
              onTap: () {},
              child: Container(
                color: dominantColor,
                height: height,
                width: double.infinity,
                child: Image(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

enum PlayerState { reset, play, pause, complete }

class PostSimpleRecordWebsite extends StatefulWidget {
  final String recordUrl;

  const PostSimpleRecordWebsite({super.key, required this.recordUrl});

  @override
  State<PostSimpleRecordWebsite> createState() => _PostSimpleRecordWebsiteState();
}

class _PostSimpleRecordWebsiteState extends State<PostSimpleRecordWebsite> {
  final AudioPlayer player = AudioPlayer();
  Stream<DurationState>? durationState;
  final ValueNotifier<bool> isFinishedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isMutedNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    initialize();
    player.positionStream.listen((position) {
      final totalDuration = player.duration;
      if (totalDuration != null && position >= totalDuration) {
        isFinishedNotifier.value = true; // Mark as finished
      } else {
        isFinishedNotifier.value = false; // Reset when not finished
      }
    });
    player.playerStateStream.listen((state) {
      isPlayingNotifier.value = state.playing;
    });
  }

  void initialize() async {
    await player.setUrl(widget.recordUrl);
    durationState = Rx.combineLatest3<Duration, Duration, Duration?, DurationState>(
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
    isFinishedNotifier.dispose();
    isPlayingNotifier.dispose();
    isMutedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<DurationState>(
              stream: durationState,
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
                    if (visibleFraction >= ratioThreshold) {
                      if (mounted) {
                        player.play();
                        if (!isPlayingNotifier.value) {
                          isPlayingNotifier.value = true;
                        }
                      }
                    } else {
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
                    timeLabelLocation: TimeLabelLocation.sides,
                    progressBarColor: AppColors.lightIris,
                    baseBarColor: AppColors.white,
                    total: total,
                    onSeek: (duration) {
                      player.seek(duration);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20,),
            ValueListenableBuilder<bool>(
              valueListenable: isFinishedNotifier,
              builder: (context, isFinished, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isFinished)
                      IconButton(
                        icon: const Icon(Icons.replay, color: AppColors.blackOak),
                        onPressed: () async {
                          // Stop the player and reload the audio to ensure proper playback
                          await player.stop();
                          await player.seek(Duration.zero);
                          await player.play();
                        },
                      )
                    else
                      ValueListenableBuilder<bool>(
                        valueListenable: isPlayingNotifier,
                        builder: (context, isPlaying, child) {
                          return Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                if (!isPlaying)
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow, color: AppColors.blackOak),
                                    onPressed: () async {
                                      // Check if the player is already prepared
                                      if (player.processingState == ProcessingState.idle) {
                                        await player.setUrl(widget.recordUrl);
                                      }
                                      await player.play();
                                    },
                                  )
                                else
                                  IconButton(
                                    icon: const Icon(Icons.pause, color: AppColors.blackOak),
                                    onPressed: () {
                                      player.pause();
                                    },
                                  ),
                                ValueListenableBuilder<bool>(
                                  valueListenable: isMutedNotifier,
                                  builder: (context, isMuted, child) {
                                    return IconButton(
                                      icon: Icon(
                                        isMuted ? Icons.volume_off : Icons.volume_up,
                                        color: AppColors.blackOak,
                                      ),
                                      onPressed: () {
                                        isMutedNotifier.value = !isMuted;
                                        player.setVolume(isMuted ? 1.0 : 0.0);
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


class DurationState {
  const DurationState({required this.progress, required this.buffered, required this.total});
  final Duration progress;
  final Duration buffered;
  final Duration total;
}
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socialapp/utils/import.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl, thumbnailUrl;
  final bool isNSFWAllowed;
  final Color dominantColor;
  final double height, width;

  const VideoPlayerWidget({
    super.key,
    this.videoUrl,
    required this.height,
    required this.width,
    required this.dominantColor,
    this.thumbnailUrl,
    required this.isNSFWAllowed,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerPreviewWidgetState();
}

class _VideoPlayerPreviewWidgetState extends State<VideoPlayerWidget>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _fadeController;
  double ratioThreshold = (kIsWeb) ? 0.7 : 1;

  Stream<DurationState>? durationState;

  final ValueNotifier<bool> isInitialized = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isTimeout = ValueNotifier<bool>(false);
  final ValueNotifier<double> currentPosition = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> isHovering = ValueNotifier<bool>(true);
  final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isMuted = ValueNotifier<bool>(false);
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();

    _initializeVideo();
    _startTimeout();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    isInitialized.dispose();
    isTimeout.dispose();
    _timeoutTimer?.cancel();
    currentPosition.dispose();
    isHovering.dispose();
    isPlaying.dispose();
    isMuted.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    if (widget.videoUrl != null) {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
    } else {
      throw ArgumentError('videoUrl must be provided.');
    }

    await _controller.initialize();
    _cancelTimeout();

    Stream<Duration> positionStream = Stream.periodic(
      const Duration(milliseconds: 500),
      (_) => _controller.value.position,
    ).asBroadcastStream();

    Stream<Duration> bufferedPositionStream = Stream.periodic(
      const Duration(milliseconds: 500),
      (_) => _controller.value.buffered.isNotEmpty
          ? _controller.value.buffered.last.end
          : Duration.zero,
    ).asBroadcastStream();

    Stream<Duration?> durationStream = Stream.value(
      _controller.value.duration,
    ).asBroadcastStream();

    durationState =
        Rx.combineLatest3<Duration, Duration, Duration?, DurationState>(
      positionStream,
      bufferedPositionStream,
      durationStream,
      (position, bufferedPosition, duration) => DurationState(
        progress: position,
        buffered: bufferedPosition,
        total: duration ?? Duration.zero,
      ),
    );

    if (mounted) {
      isInitialized.value = true;
      _fadeController.forward();
    }

    // _controller.play();
    isPlaying.value = false;

    _controller.addListener(() {
      if (_controller.value.isInitialized) {
        if (mounted) {
          currentPosition.value =
              _controller.value.position.inSeconds.toDouble();

          if (_controller.value.position >= _controller.value.duration) {
            _controller.seekTo(Duration.zero);
            isPlaying.value = false;
            _controller.pause();
            isHovering.value = true;
          }
        }
      }
    });
  }

  void _startTimeout() {
    _timeoutTimer = Timer(const Duration(seconds: 20), () {
      if (mounted) {
        isTimeout.value = true;
      }
    });
  }

  void _cancelTimeout() {
    _timeoutTimer?.cancel();
    if (mounted) {
      isTimeout.value = false;
    }
  }

  void _startVisibilityTimeout() {
    _timeoutTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        isHovering.value = false;
      }
    });
  }

  void _togglePlayPause() {
    if (isPlaying.value) {
      _controller.pause();
    } else {
      _controller.play();
      _startVisibilityTimeout();
    }
    isPlaying.value = !isPlaying.value;
  }

  void _toggleMute() {
    isMuted.value = !isMuted.value;
    _controller.setVolume(isMuted.value ? 0.0 : 1.0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isNSFWAllowed) {}
    return AspectRatio(
      aspectRatio: widget.width / widget.height,
      child: ValueListenableBuilder<bool>(
        valueListenable: isTimeout,
        builder: (context, timeout, child) {
          if (timeout) {
            return const ImageErrorPlaceholder();
          }

          return ValueListenableBuilder<bool>(
            valueListenable: isInitialized,
            builder: (context, initialized, child) {
              if (!initialized) {
                return Stack(
                  children: [
                    Shimmer.fromColors(
                      baseColor: widget.dominantColor,
                      highlightColor: AppColors.white,
                      child: Container(
                        width: widget.width,
                        height: widget.height,
                        color: widget.dominantColor,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Container(
                width: widget.width,
                height: widget.height,
                color: widget.dominantColor,
                child: GestureDetector(
                  onTap: () {
                    // Toggle hover state on tap for mobile users
                    isHovering.value = !isHovering.value;
                  },
                  child: MouseRegion(
                    onEnter: (_) => isHovering.value = true,
                    onExit: (_) => isHovering.value = false,
                    child: SizedBox(
                      width: widget.width,
                      height: widget.height,
                      child: Stack(
                        children: [
                          SizedBox(
                            width: widget.width,
                            height: widget.height,
                            child: AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child:  VisibilityDetector(
                                      key: Key(widget.videoUrl ?? 'video-key'),
                                      onVisibilityChanged: (visibilityInfo) {
                                        double visibleFraction =
                                            visibilityInfo.visibleFraction;
                                        if (visibleFraction >= ratioThreshold) {
                                          if (mounted) {
                                            isHovering.value = true;
                                            _controller.play();
                                            _startVisibilityTimeout();

                                            if (!isPlaying.value) {
                                              isPlaying.value = true;
                                            }
                                          }
                                        } else {
                                          if (mounted) {
                                            isHovering.value = false;
                                            _controller.pause();
                                            if (isPlaying.value) {
                                              isPlaying.value = false;
                                            }
                                          }
                                        }
                                      },
                                      child: VideoPlayer(_controller)),
                            ),
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: isHovering,
                            builder: (context, hovering, child) {
                              return AnimatedOpacity(
                                opacity: hovering ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: ValueListenableBuilder<bool>(
                                        valueListenable: isPlaying,
                                        builder: (context, playing, child) {
                                          return IconButton(
                                            icon: Icon(playing
                                                ? Icons.pause
                                                : Icons.play_arrow),
                                            onPressed: _togglePlayPause,
                                            color: AppColors.tropicalBreeze,
                                            iconSize: 50.0,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          // Separate notifier listening for hovering status for other UI elements
                          ValueListenableBuilder<bool>(
                            valueListenable: isHovering,
                            builder: (context, hovering, child) {
                              return AnimatedOpacity(
                                opacity: hovering ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: ValueListenableBuilder<bool>(
                                        valueListenable: isMuted,
                                        builder: (context, muted, child) {
                                          return IconButton(
                                            icon: Icon(muted
                                                ? Icons.volume_off
                                                : Icons.volume_up),
                                            onPressed: _toggleMute,
                                            color: AppColors.bleachSilk,
                                          );
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      left: 10,
                                      right: 10,
                                      child: StreamBuilder<DurationState>(
                                        stream: durationState,
                                        builder: (context, snapshot) {
                                          final durationState = snapshot.data;
                                          final progress =
                                              durationState?.progress ??
                                                  Duration.zero;
                                          final buffered =
                                              durationState?.buffered ??
                                                  Duration.zero;
                                          final total = durationState?.total ??
                                              Duration.zero;
                                          return ProgressBar(
                                            thumbColor:
                                                AppColors.systemShockBlue,
                                            thumbGlowColor: AppColors.white,
                                            progressBarColor:
                                                AppColors.lightIris,
                                            baseBarColor: AppColors.white,
                                            timeLabelLocation:
                                                TimeLabelLocation.above,
                                            timeLabelTextStyle:
                                                AppTheme.signInWhiteText,
                                            progress: progress,
                                            buffered: buffered,
                                            total: total,
                                            onSeek: (duration) {
                                              _controller.seekTo(duration);
                                              _controller.play();
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

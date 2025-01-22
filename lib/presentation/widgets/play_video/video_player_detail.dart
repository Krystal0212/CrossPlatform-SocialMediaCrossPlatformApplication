import 'package:socialapp/utils/import.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPlayerDetailWidget extends StatefulWidget {
  final String? videoUrl;
  final Color dominantColor;
  final double height, width;

  const VideoPlayerDetailWidget({
    super.key,
    this.videoUrl,
    required this.height,
    required this.width,
    required this.dominantColor,
  });

  @override
  State<VideoPlayerDetailWidget> createState() =>
      _VideoPlayerPreviewWidgetState();
}

class _VideoPlayerPreviewWidgetState extends State<VideoPlayerDetailWidget> {
  late VideoPlayerController _controller;
  final ValueNotifier<bool> isInitialized = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isTimeout = ValueNotifier<bool>(false);
  final ValueNotifier<double> currentPosition = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> isHovering = ValueNotifier<bool>(false);
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
    if (widget.videoUrl != null) {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
    } else {
      throw ArgumentError('videoUrl must be provided.');
    }

    await _controller.initialize();
    _cancelTimeout();

    if (mounted) {
      isInitialized.value = true;
    }

    _controller.play();
    isPlaying.value = false;

    _controller.addListener(() {
      if (_controller.value.isInitialized) {
        if (mounted) {
          currentPosition.value =
              _controller.value.position.inSeconds.toDouble();
        }
      }
    });
  }

  void _startTimeout() {
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
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

  void _togglePlayPause() {
    if (isPlaying.value) {
      _controller.pause();
    } else {
      _controller.play();
    }
    isPlaying.value = !isPlaying.value;
  }

  void _seekTo(double value) {
    final position = Duration(seconds: value.toInt());
    _controller.seekTo(position);
  }

  void _toggleMute() {
    isMuted.value = !isMuted.value;
    _controller.setVolume(isMuted.value ? 0.0 : 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isTimeout,
      builder: (context, timeout, child) {
        if (timeout) {
          return const ImageErrorPlaceholder();
        }

        return ValueListenableBuilder<bool>(
          valueListenable: isInitialized,
          builder: (context, initialized, child) {
            if (!initialized) {
              return Shimmer.fromColors(
                baseColor: widget.dominantColor,
                highlightColor: AppColors.white,
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  color: widget.dominantColor,
                  // Use the dominant color as background
                  child: const Center(
                    child:
                        CircularProgressIndicator(), // Optional: Show a loading indicator
                  ),
                ),
              );
            }

            return GestureDetector(
              onTap: () {
                // Toggle hover state on tap for mobile users
                isHovering.value = !isHovering.value;
              },
              child: SizedBox(
                width: widget.width,
                height: widget.height,
                child: Stack(
                  children: [
                    VisibilityDetector(
                      key: const Key('video-player'),
                      onVisibilityChanged: (visibilityInfo) {
                        double visibleFraction = visibilityInfo.visibleFraction;
                        if (visibleFraction == 1) {
                          if (mounted) {
                            _controller.play();
                            if (!isPlaying.value) {
                              isPlaying.value = true;
                            }
                          }
                        } else {
                          if (mounted) {
                            _controller.pause();
                            if (isPlaying.value) {
                              isPlaying.value = false;
                            }
                          }
                        }
                      },
                      child: SizedBox(
                        width: widget.width,
                        height: widget.height,
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
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
                                      color: AppColors.bleachSilk,
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
                              // Seek Bar at the bottom
                              Positioned(
                                bottom: 10,
                                left: 10,
                                right: 10,
                                child: ValueListenableBuilder<double>(
                                  valueListenable: currentPosition,
                                  builder: (context, position, child) {
                                    return Slider(
                                        min: 0.0,
                                        max: _controller
                                            .value.duration.inSeconds
                                            .toDouble(),
                                        value: position,
                                        onChanged: _seekTo,
                                        activeColor: AppColors.lightIris);
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
            );
          },
        );
      },
    );
  }
}

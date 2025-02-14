import 'package:socialapp/utils/import.dart';
import 'package:video_player/video_player.dart';
import 'package:universal_html/html.dart' as html_web;

import 'package:socialapp/utils/import.dart';
import 'package:video_player/video_player.dart';
import 'package:universal_html/html.dart' as html_web;

class VideoPlayerPreviewWidget extends StatefulWidget {
  final Uint8List? videoData;
  final String? videoUrl;
  final double height, width;

  const VideoPlayerPreviewWidget({
    super.key,
    this.videoData,
    this.videoUrl,
    required this.height,
    required this.width,
  }) : assert(videoData != null || videoUrl != null,
            'Either videoData or videoUrl must be provided.');

  @override
  State<VideoPlayerPreviewWidget> createState() =>
      _VideoPlayerPreviewWidgetState();
}

class _VideoPlayerPreviewWidgetState extends State<VideoPlayerPreviewWidget> {
  late VideoPlayerController _controller;
  final ValueNotifier<bool> isInitialized = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isTimeout = ValueNotifier<bool>(false);
  final ValueNotifier<double> currentPosition = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> isSeeking = ValueNotifier<bool>(false);
  Timer? _timeoutTimer;
  bool isPlaying = false;
  bool isMuted = false;

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
    isSeeking.dispose();
    _timeoutTimer?.cancel();
    currentPosition.dispose();
    super.dispose();
  }

  VideoPlayerController createVideoPlayerControllerForWeb(Uint8List videoData) {
    final blob = html_web.Blob([videoData]);
    final url = html_web.Url.createObjectUrlFromBlob(blob);
    return VideoPlayerController.networkUrl(Uri.parse(url));
  }

  Future<VideoPlayerController> createVideoPlayerControllerForMobile(
      Uint8List videoData) async {
    final tempDir = await getTemporaryDirectory();

    final uniqueFileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final tempFile = File('${tempDir.path}/$uniqueFileName');
    await tempFile.writeAsBytes(videoData);
    return VideoPlayerController.file(tempFile);
  }

  Future<void> _initializeVideo() async {
    if (widget.videoData != null) {
      if (kIsWeb) {
        _controller = createVideoPlayerControllerForWeb(widget.videoData!);
      } else {
        _controller =
            await createVideoPlayerControllerForMobile(widget.videoData!);
      }
    } else if (widget.videoUrl != null) {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
    } else {
      throw ArgumentError('Either videoData or videoUrl must be provided.');
    }

    // Initialize the controller
    await _controller.initialize();
    _cancelTimeout();
    isInitialized.value = true;

    // Start playing the video
    _controller.play();
    setState(() {
      isPlaying = true;
    });

    _controller.addListener(() {
      if (_controller.value.isInitialized) {
        currentPosition.value = _controller.value.position.inSeconds.toDouble();
      }
    });
  }

  void _startTimeout() {
    _timeoutTimer = Timer(const Duration(seconds: 20), () {
      isTimeout.value = true;
    });
  }

  void _cancelTimeout() {
    _timeoutTimer?.cancel();
    isTimeout.value = false;
  }

  void _togglePlayPause() {
    setState(() {
      if (isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      isPlaying = !isPlaying;
    });
  }

  void _seekTo(double value) {
    isSeeking.value = true;
    final position = Duration(seconds: value.toInt());
    _controller.seekTo(position).then((_) {
      Future.delayed(const Duration(milliseconds: 600), () {
        isSeeking.value = false;
      });
    });
  }

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
      _controller.setVolume(isMuted ? 0.0 : 1.0); // Mute or unmute
    });
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
              return SizedBox(
                  height: widget.height,
                  width: widget.width,
                  child: const Center(child: CircularProgressIndicator()));
            }

            return SizedBox(
              height: widget.height,
              width: widget.width,
              child: Stack(
                children: [
                  SizedBox(
                    width: widget.width,
                    height: widget.height,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  // Seeking Indicator
                  ValueListenableBuilder<bool>(
                    valueListenable: isSeeking,
                    builder: (context, seeking, _) {
                      if (seeking) {
                        return const Center(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.iris,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  // Play/Pause Button
                  Positioned(
                    left: 10,
                    child: IconButton(
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: _togglePlayPause,
                    ),
                  ),
                  Positioned(
                    left: 60,
                    child: IconButton(
                      icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
                      onPressed: _toggleMute,
                    ),
                  ),
                  // Seek Bar
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: ValueListenableBuilder<double>(
                      valueListenable: currentPosition,
                      builder: (context, positionSelected, _) {
                        return Slider(
                          min: 0.0,
                          max: _controller.value.duration.inSeconds.toDouble(),
                          value: positionSelected,
                          onChanged: _seekTo,
                          activeColor: AppColors.iris,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

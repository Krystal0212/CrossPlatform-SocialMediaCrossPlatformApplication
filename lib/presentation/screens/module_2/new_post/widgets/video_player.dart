import 'package:socialapp/utils/import.dart';
import 'package:video_player/video_player.dart';
import 'video_player_helper.dart'; // Import helper for conditional imports

class VideoPlayerWidget extends StatefulWidget {
  final Uint8List videoData;

  const VideoPlayerWidget({super.key, required this.videoData});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  final ValueNotifier<bool> isInitialized = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isTimeout = ValueNotifier<bool>(false);
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
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    _controller = await createVideoPlayerController(widget.videoData);
    await _controller.initialize();
    _cancelTimeout();
    isInitialized.value = true;
  }

  void _startTimeout() {
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      isTimeout.value = true;
    });
  }

  void _cancelTimeout() {
    _timeoutTimer?.cancel();
    isTimeout.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isTimeout,
      builder: (context, timeout, child) {
        if (timeout) {
          return const Center(child: Text("Loading timed out"));
        }

        return ValueListenableBuilder<bool>(
          valueListenable: isInitialized,
          builder: (context, initialized, child) {
            if (!initialized) {
              return const Center(child: CircularProgressIndicator());
            }
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            );
          },
        );
      },
    );
  }
}

import 'package:socialapp/utils/import.dart';
import 'dart:html' as html; // For web usage

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
    if (kIsWeb) {
      // Convert Uint8List to a Blob URL for web
      final blob = html.Blob([widget.videoData]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      _controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          _cancelTimeout();
          isInitialized.value = true;
        });

      _controller.play();
    } else {
      // Save Uint8List as a temporary file for mobile
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/video.mp4');
      await tempFile.writeAsBytes(widget.videoData);

      _controller = VideoPlayerController.file(tempFile)
        ..initialize().then((_) {
          _cancelTimeout();
          isInitialized.value = true;
        });
    }
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
          // Display placeholder after timeout
          return const ImageErrorPlaceholder();
        }

        return ValueListenableBuilder<bool>(
          valueListenable: isInitialized,
          builder: (context, initialized, child) {
            if (!initialized) {
              return const Center(child: CircularProgressIndicator());
            }
            return Stack(children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              Positioned.fill(
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      if (_controller.value.isPlaying) {
                        _controller.pause();
                      } else {
                        _controller.play();
                      }
                      setState(() {}); // Refresh to toggle the icon
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 30,
                      child: Icon(
                        _controller.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ]);
          },
        );
      },
    );
  }
}

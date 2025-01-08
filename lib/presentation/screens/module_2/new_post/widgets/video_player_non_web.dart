import 'dart:typed_data';

import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Actual implementation for non-web (mobile, desktop)
Future<VideoPlayerController> createVideoPlayerController(Uint8List videoData) async {
  final tempDir = await getTemporaryDirectory();
  final tempFile = File('${tempDir.path}/video.mp4');
  await tempFile.writeAsBytes(videoData);
  return VideoPlayerController.file(tempFile);
}

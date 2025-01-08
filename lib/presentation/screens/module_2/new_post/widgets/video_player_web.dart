import 'dart:typed_data';

import 'package:universal_html/html.dart' as html;
import 'package:video_player/video_player.dart';

// Actual implementation for web
VideoPlayerController createVideoPlayerController(Uint8List videoData) {
  final blob = html.Blob([videoData]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  return VideoPlayerController.networkUrl(Uri.parse(url));
}

import 'dart:async';
import 'package:video_player/video_player.dart';

Future<Map<String, double>> getVideoDimensions(String videoUrl) async {
  final controller = VideoPlayerController.network(videoUrl);
  await controller.initialize();

  final double width = controller.value.size.width;
  final double height = controller.value.size.height;

  controller.dispose(); // Cleanup

  return {'width': width, 'height': height};
}

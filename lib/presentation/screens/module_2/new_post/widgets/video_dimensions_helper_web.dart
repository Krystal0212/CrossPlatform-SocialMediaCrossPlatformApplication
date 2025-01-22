import 'dart:async';
import 'package:universal_html/html.dart' as html;

// Future<Map<String, double>> getVideoDimensions(String videoUrl) async {
//   final completer = Completer<Map<String, double>>();
//   final videoElement = html.VideoElement()
//     ..src = videoUrl
//     ..preload = 'metadata';
//
//   videoElement.onLoadedMetadata.listen((_) {
//     try {
//       final double width = videoElement.videoWidth.toDouble();
//       final double height = videoElement.videoHeight.toDouble();
//       completer.complete({'width': width, 'height': height});
//     } catch (e) {
//       completer.completeError('Error fetching video metadata for web: $e');
//     }
//   });
//
//   videoElement.onError.listen((_) {
//     completer.completeError('Failed to load video metadata');
//   });
//
//   return completer.future;
// }

import 'package:image/image.dart' as img;
import 'package:universal_html/html.dart' as html;

import 'package:socialapp/utils/import.dart';
import 'package:video_player/video_player.dart';

mixin ImageAndVideoProcessingHelper {
  Future<String> getDominantColorFromImage(Uint8List imageData) async {
    final palette = await PaletteGenerator.fromImageProvider(
      MemoryImage(imageData),
      size: const Size(75, 75),
    );
    return palette.dominantColor?.color.value.toRadixString(16) ??
        AppColors.tangledWeb.value.toRadixString(16);
  }

  double calculateAspectRatio(img.Image? image) {
    int width = image?.width ?? 0;
    int height = image?.height ?? 0;
    return width / height;
  }

  List<int> calculateWidthAndHeight(img.Image? image) {
    int width = image?.width ?? 0;
    int height = image?.height ?? 0;
    return [width, height];
  }


  // Future<Map<String, double>> getVideoDimensionsForWebsite(String videoUrl) async {
  //   final completer = Completer<Map<String, double>>();
  //   final videoElement = html.VideoElement()
  //     ..src = videoUrl
  //     ..preload = 'metadata';
  //
  //   videoElement.onLoadedMetadata.listen((_) {
  //     final double width = videoElement.videoWidth.toDouble();  // Video width from metadata
  //     final double height = videoElement.videoHeight.toDouble();  // Video height from metadata
  //
  //     print('width $width height $height');
  //
  //     completer.complete({'width': width, 'height': height});
  //   });
  //
  //   // Error handling if metadata fails to load
  //   videoElement.onError.listen((_) {
  //     completer.completeError('Failed to load video metadata');
  //   });
  //
  //   return completer.future;
  // }
  //
  // Future<Map<String, double>> getVideoDimensionsForMobile(String videoUrl) async {
  //   final completer = Completer<Map<String, double>>();
  //
  //   final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl!));
  //
  //   await controller.initialize();
  //
  //   final double width = controller.value.size.width;
  //   final double height = controller.value.size.height;
  //
  //   // Complete the completer with the dimensions
  //   completer.complete({'width': width, 'height': height});
  //
  //   // Dispose the controller after use
  //   controller.dispose();
  //
  //   return completer.future;
  // }


}

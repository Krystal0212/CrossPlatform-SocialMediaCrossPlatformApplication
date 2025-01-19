import 'package:image/image.dart' as img;
import 'package:universal_html/html.dart' as html;

import 'package:socialapp/utils/import.dart';

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

  Future<Map<String, double>> getVideoDimensions(String videoUrl) async {
    final completer = Completer<Map<String, double>>();
    final videoElement = html.VideoElement()
      ..src = videoUrl
      ..preload = 'metadata';
    videoElement.onLoadedMetadata.listen((_) {
      final double width =
          videoElement.getBoundingClientRect().width.toDouble();
      final double height =
          videoElement.getBoundingClientRect().height.toDouble();

      completer.complete({'width': width, 'height': height});
    });
    videoElement.onError.listen((_) {
      completer.completeError('Failed to load video metadata');
    });
    return completer.future;
  }
}

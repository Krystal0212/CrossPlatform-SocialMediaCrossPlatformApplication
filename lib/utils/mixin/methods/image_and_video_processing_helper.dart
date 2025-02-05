import 'package:image/image.dart' as img;
import 'package:universal_html/html.dart' as html;

import 'package:socialapp/utils/import.dart';
import 'package:video_compress/video_compress.dart';
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


  Future<String> getLocalVideoUrlForWebsite(html.File file) async {
    final completer = Completer<String>();
    String url = html.Url.createObjectUrl(file);
    completer.complete(url);
    return completer.future;
  }

  Future<Uint8List> resizeAndConvertToWebPForWebsite(html.File file) async {
    final completer = Completer<Uint8List>();

    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    await reader.onLoad.first;

    final imageElement = html.ImageElement();
    imageElement.src = reader.result as String;
    await imageElement.onLoad.first;

    final originalWidth = imageElement.width!;
    final originalHeight = imageElement.height!;

    const maxDimension = 1200;

    late int targetWidth, targetHeight;
    if (originalWidth > originalHeight) {
      targetWidth = maxDimension;
      targetHeight = (originalHeight * maxDimension / originalWidth).round();
    } else {
      targetHeight = maxDimension;
      targetWidth = (originalWidth * maxDimension / originalHeight).round();
    }

    final canvas = html.CanvasElement(width: targetWidth, height: targetHeight);
    final ctx = canvas.context2D;

    // Enable high-quality rendering
    ctx.imageSmoothingEnabled = true;
    ctx.imageSmoothingQuality = 'high';

    ctx.drawImageScaled(imageElement, 0, 0, targetWidth, targetHeight);

    final blob = await canvas.toBlob('image/webp', 8.0); // Maximum quality
    final readerForBlob = html.FileReader();
    readerForBlob.readAsArrayBuffer(blob);
    await readerForBlob.onLoad.first;

    completer.complete(readerForBlob.result as Uint8List);
    return completer.future;
  }

  Future<Uint8List> resizeAndConvertToWebPForMobile(File file) async {
    const maxDimension = 1200;

    // Get the original dimensions of the image
    final decodedImage = await decodeImageFromList(await file.readAsBytes());
    final originalWidth = decodedImage.width;
    final originalHeight = decodedImage.height;

    // Calculate the target dimensions
    late int targetWidth, targetHeight;
    if (originalWidth > originalHeight) {
      targetWidth = maxDimension;
      targetHeight = (originalHeight * maxDimension / originalWidth).round();
    } else {
      targetHeight = maxDimension;
      targetWidth = (originalWidth * maxDimension / originalHeight).round();
    }

    final compressedImage = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: targetWidth,
      minHeight: targetHeight,
      quality: 90,
      format: CompressFormat.webp,
    );

    if (compressedImage == null) {
      throw Exception("Failed to compress image");
    }

    return Uint8List.fromList(compressedImage);
  }

  Future<String> saveUint8ListToFile(Uint8List data, String filename) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String filePath = '${tempDir.path}/$filename';

    final File file = File(filePath);
    await file.writeAsBytes(data);

    return filePath;
  }

  Future<Uint8List?> compressVideo(Uint8List videoData, String filename) async {
    try {
      final String filePath = await saveUint8ListToFile(videoData, '$filename.mp4');
      final File file = File(filePath);

      final MediaInfo? info = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false,
        includeAudio: true,
        frameRate: 60,
      ).catchError((error) {
        if (kDebugMode) {
          print("Video compression error: $error");
        }
        return null;
      });

      if (info == null || info.path == null) {
        if (kDebugMode) {
          print("Compression failed, returning original video.");
        }
        return videoData;
      }

      // Calculate sizes for compression ratio
      int previousSize = file.lengthSync() ~/ (1024 * 1024);
      int newSize = (info.filesize ?? 0) ~/ (1024 * 1024);
      double compressedSizeRatio = previousSize != 0 ? newSize / previousSize : 0;

      if (kDebugMode) {
        print("Before converting video: ${previousSize.toStringAsFixed(2)} MB");
        print("After converting video: ${newSize.toStringAsFixed(2)} MB");
        print("Compressed size ratio: $compressedSizeRatio");
      }

      // If compression ratio is too low, return original video
      if (compressedSizeRatio < 0.1) {
        if (kDebugMode) {
          print("Compression ratio too low, returning original video.");
        }
        return videoData;
      }

      // Read the compressed video as bytes and return it
      return File(info.path!).readAsBytesSync();
    } catch (error) {
      if (kDebugMode) {
        print("Unexpected error during video compression: $error");
      }
      return videoData; // Return original video if an error occurs
    }
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

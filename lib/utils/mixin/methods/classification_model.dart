import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

import 'package:socialapp/utils/import.dart';

mixin ClassificationMixin {
  Future<bool> classifyNSFWInIsolate(Uint8List image) async {
    return await classifyNSFWForWeb(
        image); // Call your existing classifyNSFW function
  }

  Future<bool> classifyNSFWForWeb(Uint8List? image) async {
    if (image == null) return false;

    try {
      // Create an ImageElement to load the image
      final reader = html.FileReader();
      reader.readAsDataUrl(html.Blob([image]));
      await reader.onLoad.first;

      final imageElement = html.ImageElement();
      imageElement.src = reader.result as String;
      await imageElement.onLoad.first;

      final originalWidth = imageElement.width!;
      final originalHeight = imageElement.height!;

      const targetSize = 1000;
      late int newWidth, newHeight;
      if (originalWidth > originalHeight) {
        newWidth = targetSize;
        newHeight = (originalHeight * targetSize / originalWidth).round();
      } else {
        newHeight = targetSize;
        newWidth = (originalWidth * targetSize / originalHeight).round();
      }

      // Resize the image using CanvasElement
      final canvas = html.CanvasElement(width: newWidth, height: newHeight);
      final ctx = canvas.context2D;
      ctx.drawImageScaled(imageElement, 0, 0, newWidth, newHeight);

      // Convert the resized image to Uint8List
      final html.Blob resizedImage =
          await canvas.toBlob('image/jpeg', 0.8); // 0.8 is the quality
      final html.FileReader readerForBlob = html.FileReader();
      readerForBlob.readAsArrayBuffer(resizedImage);
      await readerForBlob.onLoad.first;
      final Uint8List resizedImageBytes = readerForBlob.result as Uint8List;

      // Prepare the request to classify the image
      List<String> nsfwLabels = ["hentai", "porn", "sexy"];
      final uri = Uri.parse(
          'https://fastapi-cloud-function-351093878135.us-central1.run.app/classify/');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        resizedImageBytes,
        filename: 'image.jpg',
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['result'] as Map<String, dynamic>;

        final highestLabel =
            result.entries.reduce((a, b) => a.value > b.value ? a : b);

        return nsfwLabels.contains(highestLabel.key);
      } else {
        throw (response.statusCode);
      }
    } catch (e) {
      debugPrint("Error during classification: $e");
      return false;
    }
  }

  Future<bool> classifyNSFW(Uint8List? image) async {
    if (image == null) return false;
    try {
      final img.Image? decodedImage = img.decodeImage(image);
      if (decodedImage == null) return false;

      const int targetHeight = 300;
      final double aspectRatio = decodedImage.width / decodedImage.height;
      final int targetWidth = (targetHeight * aspectRatio).round();

      final img.Image resized = img.copyResize(
        decodedImage,
        width: targetWidth,
        height: targetHeight,
      );

      final Uint8List resizedImage = Uint8List.fromList(img.encodeJpg(resized));

      List<String> nsfwLabels = ["hentai", "porn", "sexy"];

      final uri = Uri.parse(
        'https://fastapi-cloud-function-351093878135.us-central1.run.app/classify/',
      );
      final request = http.MultipartRequest('POST', uri);

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        resizedImage,
        filename: 'image.jpg',
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['result'] as Map<String, dynamic>;

        final highestLabel = result.entries.reduce((a, b) => a.value > b.value ? a : b);

        return nsfwLabels.contains(highestLabel.key);
      } else {
        throw (response.statusCode);
      }
    } catch (e) {
      debugPrint("Error during classification: $e");
      return false;
    }
  }


// void pickAssets(ValueNotifier<List<Map<String, dynamic>>> imagePathNotifier, BuildContext context) async {
//   final uploadInput = html.FileUploadInputElement()
//     ..accept = 'image/*,video/*'
//     ..multiple = true;
//
//   uploadInput.click();
//
//   uploadInput.onChange.listen((event) async {
//     final files = uploadInput.files;
//
//     if (files == null || files.isEmpty) return;
//
//     final List uploadedFiles = imagePathNotifier.value;
//
//     List<Future<void>> classifyTasks = [];
//
//     for (int index = 0; index < files.length; index++) {
//       Stopwatch stopwatch = Stopwatch();
//       stopwatch.start();
//       final file = files[index];
//       final reader = html.FileReader();
//       reader.readAsArrayBuffer(file);
//       await reader.onLoad.first;
//
//       bool isDuplicate = uploadedFiles.any((uploadedAsset) {
//         return uploadedAsset['name'] == file.name;
//       });
//
//       if (isDuplicate) {
//         continue;
//       }
//
//       final uploadedAsset = <String, dynamic>{};
//       uploadedAsset['index'] =
//           (uploadedFiles.isNotEmpty) ? uploadedFiles.length : index;
//       uploadedAsset['name'] = file.name;
//
//       if (file.type.startsWith('image')) {
//         final resizedWebP = await _resizeAndConvertToWebP(file);
//
//         uploadedAsset['data'] = resizedWebP;
//         uploadedAsset['isNSFW'] = false;
//
//         classifyTasks.add(compute(classifyNSFW, resizedWebP).then((isNSFW) {
//           final index =
//               uploadedFiles.indexWhere((asset) => asset['name'] == file.name);
//           if (index != -1) {
//             uploadedFiles[index]['isNSFW'] = isNSFW;
//           }
//         }));
//
//         if (kDebugMode) {
//           print("Time for skipping : ${stopwatch.elapsedMilliseconds}");
//         }
//
//         final imageElement = html.ImageElement();
//         imageElement.src = html.Url.createObjectUrl(file);
//         await imageElement.onLoad.first;
//
//         uploadedAsset['width'] = imageElement.width ?? 0;
//         uploadedAsset['height'] = imageElement.height ?? 1;
//         uploadedAsset['type'] = 'image';
//         if (kDebugMode) {
//           print("Time for get height : ${stopwatch.elapsedMilliseconds}");
//         }
//       }
//
//       uploadedAsset['ratio'] = (uploadedAsset['width'] as double? ?? 0) /
//           (uploadedAsset['height'] as double? ?? 1);
//       if (kDebugMode) {
//         print("Time for ratio : ${stopwatch.elapsedMilliseconds}");
//       }
//
//       uploadedFiles.add(uploadedAsset);
//       imagePathNotifier.value = List.from(uploadedFiles);
//
//       if (kDebugMode) {
//         print("Time for processing : ${stopwatch.elapsedMilliseconds}");
//       }
//       stopwatch.stop();
//     }
//     await Future.wait(classifyTasks);
//   });
// }
}

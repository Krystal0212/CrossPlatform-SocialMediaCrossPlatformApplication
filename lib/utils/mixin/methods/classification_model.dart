
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

import 'package:socialapp/utils/import.dart';


mixin ClassificationMixin {
  Future<bool> classifyNSFW(Uint8List? image) async {
    if (image == null) return false;
    try {
      final img.Image? decodedImage = img.decodeImage(image);
      final img.Image resized =
      img.copyResize(decodedImage!, width: 224, height: 224);
      List<String> nsfwLabels = ["hentai", "porn", "sexy"];

      final Uint8List resizedImage = Uint8List.fromList(img.encodeJpg(resized));

      final uri = Uri.parse(
          'https://fastapi-cloud-function-351093878135.us-central1.run.app/classify/');
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

        final highestLabel =
        result.entries.reduce((a, b) => a.value > b.value ? a : b);

        if (nsfwLabels.contains(highestLabel.key)) {
          return true;
        } else {
          return false;
        }
      } else {
        throw (response.statusCode);
      }
    } catch (e) {
      debugPrint("Error during classification: $e");
      return false;
    }
  }
}

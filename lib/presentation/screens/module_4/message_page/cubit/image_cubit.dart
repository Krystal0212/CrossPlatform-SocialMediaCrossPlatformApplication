import 'package:pytorch_lite/pytorch_lite.dart';
import 'package:socialapp/utils/import.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

import '../../../../../data/sources/firestore/chat_service_impl.dart';
import 'image_state.dart';

class ChatSendCubit extends Cubit<ChatSendState> with ClassificationMixin {
  final ChatService _chatService = ChatServiceImpl();

  bool _isImagePickerActive = false;

  ChatSendCubit() : super(ChatSendInInitial());

  Future<void> initialize() async {
    emit(ChatSendInInitial());
  }

// Future<bool> classifyNSFW(Uint8List? image) async {
//   if (image == null) return false;
//   try {
//     final img.Image? decodedImage = img.decodeImage(image);
//     final img.Image resized =
//         img.copyResize(decodedImage!, width: 224, height: 224);
//     List<String> nsfwLabels = ["hentai", "porn", "sexy"];
//
//     final Uint8List resizedImage = Uint8List.fromList(img.encodeJpg(resized));
//
//     final uri = Uri.parse(
//         'https://fastapi-cloud-function-351093878135.us-central1.run.app/classify/');
//     final request = http.MultipartRequest('POST', uri);
//
//     request.files.add(http.MultipartFile.fromBytes(
//       'file',
//       resizedImage,
//       filename: 'image.jpg',
//     ));
//
//     final streamedResponse = await request.send();
//     final response = await http.Response.fromStream(streamedResponse);
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final result = data['result'] as Map<String, dynamic>;
//
//       final highestLabel =
//           result.entries.reduce((a, b) => a.value > b.value ? a : b);
//
//       if (nsfwLabels.contains(highestLabel.key)) {
//         return true;
//       } else {
//         return false;
//       }
//     } else {
//       throw (response.statusCode);
//     }
//   } catch (e) {
//     debugPrint("Error during classification: $e");
//     return false;
//   }
// }

void sendImageWithText(bool isUser1,
    ValueNotifier<List<Map<String, dynamic>>> selectedAssetsNotifier,
    TextEditingController messageController,
    String receiverUserID,) async {
  if (selectedAssetsNotifier.value.isNotEmpty) {
    try {
      List<Map<String, dynamic>> imagePaths = [];
      for (Map<String, dynamic> image in selectedAssetsNotifier.value) {
        imagePaths.add({
          'index': image['index'],
          'path': image['path'],
          'isNSFW': image['isNSFW']
        });
      }
      selectedAssetsNotifier.value = [];
      messageController.clear();

      emit(ChatSendInProgress());
      await _chatService.sendImageMessage(
        isUser1,
        receiverUserID,
        imagePaths,
        messageController.text.trim(),
      );
      emit(ChatSendSuccess());
      await Future.delayed(const Duration(seconds: 1));
      emit(ChatSendInInitial());
    } catch (e) {
      emit(ChatSendFailure());
      if (kDebugMode) {
        print('Error sending image: $e');
      }
      await Future.delayed(const Duration(seconds: 1));
      emit(ChatSendInInitial());
    }
  }
}

void pickImage(
    ValueNotifier<List<Map<String, dynamic>>> selectedAssetsNotifier,) async {
  if (_isImagePickerActive) {
    return;
  }
  _isImagePickerActive = true;

  try {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      limit: 5,
      maxWidth: 1000,
      maxHeight: 1000,
    );

    if (images.isEmpty) {
      throw ("No images selected");
    }

    List<Map<String, dynamic>> selectedAssetsList =
    List.from(selectedAssetsNotifier.value);

    for (XFile image in images) {
      bool isNSFW = await classifyNSFW(File(image.path).readAsBytesSync());
      // bool isNSFW = false;

      bool exists = selectedAssetsList.any(
              (map) =>
          map['path']
              .split('/')
              .last == image.path
              .split('/')
              .last);

      if (!exists && selectedAssetsList.length <= 5) {
        selectedAssetsList.add({
          'data': File(image.path).readAsBytesSync(),
          'path': image.path,
          'type': 'image',
          'index': selectedAssetsList.length,
          'isNSFW': isNSFW
        });

        selectedAssetsNotifier.value = List.from(selectedAssetsList);
        ;
      }
    }

    _isImagePickerActive = false;
  } catch (error) {
    if (kDebugMode) {
      print("Error during pick image: $error");
    }
    _isImagePickerActive = false;
  }
}

void sendMessage(bool isUser1,
    TextEditingController messageController,
    String receiverUserID,) async {
  // Ensure not to send an empty message
  if (messageController.text.isNotEmpty) {
    String message = messageController.text.trim();
    messageController.clear();
    await _chatService.sendMessage(isUser1, receiverUserID, message);
    // Clear the message controller after sending the message
  }
}}

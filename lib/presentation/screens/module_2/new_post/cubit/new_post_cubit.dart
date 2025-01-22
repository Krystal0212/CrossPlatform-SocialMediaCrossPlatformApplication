import 'dart:ui' as ui;

import 'package:socialapp/utils/import.dart';
import 'package:universal_html/html.dart' as html;
import 'package:path/path.dart' as path;
import 'package:flutter_quick_video_encoder/flutter_quick_video_encoder.dart';

import 'package:video_player/video_player.dart';
import '../widgets/video_dimensions_helper.dart';
import 'new_post_state.dart';

class NewPostCubit extends Cubit<NewPostState>
    with ClassificationMixin, ImageAndVideoProcessingHelper, FlashMessage {
  NewPostCubit() : super(PostInitial());
  bool _isImagePickerActive = false;

  Future<List<TopicModel>> getRandomTopics() {
    return serviceLocator<TopicRepository>().getRandomTopics();
  }

  bool checkCurrentUserSignedIn() {
    return serviceLocator<AuthRepository>().isSignedIn();
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      return await serviceLocator<UserRepository>().getCurrentUserData();
    } catch (e) {
      if (kDebugMode) {
        print("Check user data: $e");
      }
      return UserModel.empty();
    }
  }

  Future<String> _getLocalVideoUrl(html.File file) async {
    final completer = Completer<String>();
    String url = html.Url.createObjectUrl(file);
    completer.complete(url);
    return completer.future;
  }

  Future<Uint8List> _resizeAndConvertToWebPWebsite(html.File file) async {
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

  void pickAssets(ValueNotifier<List<Map<String, dynamic>>> imagePathNotifier,
      BuildContext context) async {
    final uploadInput = html.FileUploadInputElement()
      ..accept = 'image/*,video/*'
      ..multiple = true;

    uploadInput.click();

    uploadInput.onChange.listen((event) async {
      try {
        final files = uploadInput.files;

        if (files == null || files.isEmpty) return;

        final List uploadedFiles = imagePathNotifier.value;

        if ((files.length > 8 && uploadedFiles.isEmpty) ||
            (uploadedFiles.length + files.length > 8 &&
                uploadedFiles.isNotEmpty)) {
          showUploadLimitExceededMassage(context: context);
          return;
        }

        for (int index = 0; index < files.length; index++) {
          final html.File file = files[index];
          final html.FileReader reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          await reader.onLoad.first;

          bool isDuplicate = uploadedFiles.any((uploadedAsset) {
            return uploadedAsset['name'] == file.name;
          });

          if (isDuplicate) {
            continue;
          }

          final uploadedAsset = <String, dynamic>{};
          uploadedAsset['index'] =
          (uploadedFiles.isNotEmpty) ? uploadedFiles.length : index;
          uploadedAsset['name'] = file.name;

          if (file.type.startsWith('image')) {
            final resizedWebP = await _resizeAndConvertToWebPWebsite(file);

            uploadedAsset['data'] = resizedWebP;
            uploadedAsset['isNSFW'] = false;

            final imageElement = html.ImageElement();
            imageElement.src = html.Url.createObjectUrl(file);
            await imageElement.onLoad.first;

            uploadedAsset['width'] = imageElement.width ?? 0;
            uploadedAsset['height'] = imageElement.height ?? 1;
            uploadedAsset['type'] = 'image';
          } else if (file.type.startsWith('video')) {
            if (file.type != 'video/webm') {
              if (!context.mounted) return;
              showAttentionMessage(
                  context: context, description: AppStrings.videoNotSupported);
              return;
            }
            if (file.size > 60 * 1024 * 1024) {
              if (!context.mounted) return;
              showAttentionMessage(
                  context: context, description: AppStrings.videoTooLarge);
              return;
            }

            final assetPath = await _getLocalVideoUrl(file);
            if (!context.mounted) return;
            Map<String, double> videoDimensions = {};

            try {
              videoDimensions = await getVideoDimensions(assetPath);
            } catch (e) {
              if (kDebugMode) {
                print('Error fetching video dimensions: $e');
              }
            }

            uploadedAsset['isNSFW'] = false;

            uploadedAsset['data'] = reader.result as Uint8List;
            uploadedAsset['width'] = videoDimensions['width'] ?? 0;
            uploadedAsset['height'] = videoDimensions['height'] ?? 1;
            uploadedAsset['type'] = 'video';
          }

          // uploadedAsset['ratio'] = (uploadedAsset['width'] as double? ?? 0) /
          //     (uploadedAsset['height'] as double? ?? 1);

          int currentIndex = 0;
          for (var i = 0; i < uploadedFiles.length; i++) {
            final uploadedAsset = uploadedFiles[i];
            if (uploadedAsset['index'] != currentIndex) {
              uploadedAsset['index'] = currentIndex;
            }
            currentIndex++;
          }

          uploadedFiles.add(uploadedAsset);
          imagePathNotifier.value = List.from(uploadedFiles);
        }

        List<Future<void>> classifyTasks = [];
        for (int index = 0; index < files.length; index++) {
          final uploadedAsset = uploadedFiles[index];

          if (uploadedAsset['type'] == 'image') {
            final resizedWebP = uploadedAsset['data'];

            classifyTasks.add(
              compute<Uint8List, bool>(classifyNSFWInIsolate, resizedWebP)
                  .then((isNSFW) {
                final assetIndex = uploadedFiles.indexWhere(
                        (asset) => asset['name'] == uploadedAsset['name']);
                if (assetIndex != -1) {
                  uploadedFiles[assetIndex]['isNSFW'] = isNSFW;
                }
                imagePathNotifier.value = List.from(uploadedFiles);
              }),
            );
          }
        }

        await Future.wait(classifyTasks);
      } catch (error) {
        if (kDebugMode) {
          print("Error during pick assets : $error");
        }
      }
    });
  }

  Future<Uint8List> _resizeAndConvertToWebPForMobile(File file) async {
    // Maximum dimension
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

    // Compress and convert the image to WebP format
    final compressedImage = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: targetWidth,
      minHeight: targetHeight,
      quality: 90, // Adjust quality as needed
      format: CompressFormat.webp,
    );

    if (compressedImage == null) {
      throw Exception("Failed to compress image");
    }

    return Uint8List.fromList(compressedImage);
  }

  void pickImagesMobile(
      ValueNotifier<List<Map<String, dynamic>>> selectedAssetsNotifier,
      BuildContext context,) async {
    if (_isImagePickerActive) {
      return;
    }
    _isImagePickerActive = true;

    try {
      final ImagePicker picker = ImagePicker();
      List<XFile> images = [];

      final String? choice = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Choose an option"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text("Camera"),
                  onTap: () {
                    Navigator.of(context).pop("camera");
                  },
                ),
                ListTile(
                  title: Text("Gallery"),
                  onTap: () {
                    Navigator.of(context).pop("gallery");
                  },
                ),
              ],
            ),
          );
        },
      );

      if (choice == null) return;

      if (choice == "camera") {
        final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);
        if (pickedFile != null) {
          images.add(pickedFile);
        }
      } else if (choice == "gallery") {
        final List<XFile>? pickedFiles = await picker.pickMultiImage();
        if (pickedFiles != null) {
          images.addAll(pickedFiles);
        }
      }

      if (images.isEmpty) return;

      List<Map<String, dynamic>> uploadedFiles =
      List.from(selectedAssetsNotifier.value);

      if (uploadedFiles.length + images.length > 8 &&
          uploadedFiles.isNotEmpty) {
        showUploadLimitExceededMassage(context: context);
        return;
      }

      for (int index = 0; index < images.length; index++) {
        final XFile image = images[index];

        bool isDuplicate = uploadedFiles.any((uploadedAsset) {
          return uploadedAsset['name'] == image.name;
        });

        if (isDuplicate) {
          continue;
        }

        Uint8List resizedWebP =
        await _resizeAndConvertToWebPForMobile(File(image.path));
        ui.Image decodedImage = await decodeImageFromList(resizedWebP);
        int imageWidth = decodedImage.width;
        int imageHeight = decodedImage.height;

        bool isNSFW = await classifyNSFW(resizedWebP);
        // bool isNSFW = false;

        uploadedFiles.add({
          'name': image.name,
          'data': File(image.path).readAsBytesSync(),
          // 'path': image.path,
          'type': 'image',
          'index': (uploadedFiles.isNotEmpty) ? uploadedFiles.length : index,
          'isNSFW': isNSFW,
          'width': imageWidth,
          'height': imageHeight,
        });

        int currentIndex = 0;
        for (int i = 0; i < uploadedFiles.length; i++) {
          final uploadedElement = uploadedFiles[i];
          if (uploadedElement['index'] != currentIndex) {
            uploadedElement['index'] = currentIndex;
          }
          currentIndex++;
        }

        selectedAssetsNotifier.value = List.from(uploadedFiles);
      }

      _isImagePickerActive = false;
    } catch (error) {
      if (kDebugMode) {
        print("Error during pick image: $error");
      }
      _isImagePickerActive = false;
    }
  }

  void pickVideoMobile(ValueNotifier<List<Map<String, dynamic>>> assetPathNotifier,
      BuildContext context,) async {
    final ImagePicker picker = ImagePicker();

    final pickedVideo = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedVideo == null) return;

    final List<Map<String, dynamic>> uploadedFiles = assetPathNotifier.value;

    final file = File(pickedVideo.path);
    final fileName = path.basename(file.path).split('.').first;

    bool isDuplicate = uploadedFiles.any((uploadedAsset) {
      return uploadedAsset['name'] == fileName;
    });

    if (isDuplicate) {
      return;
    }

    if (file.lengthSync() > 60 * 1024 * 1024) {
      if (!context.mounted) return;
      showAttentionMessage(
        context: context,
        description: 'The video file is too large. Maximum size is 60MB.',
      );
      return;
    }

    if (assetPathNotifier.value.length + 1 > 8) {
      if (!context.mounted) return;
      showUploadLimitExceededMassage(context: context);
      return;
    }

    final uploadedAsset = <String, dynamic>{};

    final videoPlayerController = VideoPlayerController.file(file);

    await videoPlayerController.initialize();

    // Get the width and height after the controller is initialized
    final videoWidth = videoPlayerController.value.size.width;
    final videoHeight = videoPlayerController.value.size.height;
    videoPlayerController.dispose();


    if (file.existsSync()) {
      uploadedAsset['name'] = pickedVideo.name;
      uploadedAsset['data'] = await file.readAsBytes();
      uploadedAsset['type'] = 'video';
      uploadedAsset['index'] = uploadedFiles.length;
      uploadedAsset['isNSFW'] = false;
      uploadedAsset['width'] = videoWidth;
      uploadedAsset['height'] = videoHeight;
    }

    int currentIndex = 0;
    for (int i = 0; i < uploadedFiles.length; i++) {
      final uploadedElement = uploadedFiles[i];
      if (uploadedElement['index'] != currentIndex) {
        uploadedElement['index'] = currentIndex;
      }
      currentIndex++;
    }

    uploadedFiles.add(uploadedAsset);
    assetPathNotifier.value = List.from(uploadedFiles);
  }

  void sendPost(BuildContext homeContext,
      BuildContext context,
      TextEditingController textEditingController,
      ValueNotifier<List<Map<String, dynamic>>> assetDataNotifier,
      ValueNotifier<List<TopicModel>> topicSelectedNotifier,) async {
    final String content = textEditingController.text;
    final List<Map<String, dynamic>> imagesAndVideos = assetDataNotifier.value;
    final List<TopicModel> topics = topicSelectedNotifier.value;

    try {
      if (topics.isEmpty) {
        throw 'need-topics';
      }
      if (imagesAndVideos.isEmpty) {
        throw "empty-list";
      }

      Navigator.of(context).pop();

      if (!homeContext.mounted) return;

      Future.microtask(() {
        if (homeContext.mounted) {
          showAttentionMessage(
              context: homeContext, description: AppStrings.uploading);
        }
      });
      // Future.microtask(() {
      //   if (homeContext.mounted) {
      //     showSuccessMessage(
      //       context: homeContext,
      //       description: AppStrings.sendSuccess,
      //     );
      //   }
      // });

      await serviceLocator<PostRepository>()
          .createAssetPost(content, imagesAndVideos, topics);

      assetDataNotifier.value = [];

      Future.microtask(() {
        if (homeContext.mounted) {
          showSuccessMessage(
            context: homeContext,
            description: AppStrings.sendSuccess,
          );
        }
      });
    } catch (error) {
      if (error.toString() == 'empty-list') {
        if (!homeContext.mounted) return;
        showUnknownMessage(context: context, label: AppStrings.noAssets);
      } else if (error.toString() == 'need-topics') {
        if (!homeContext.mounted) return;
        showUnknownMessage(context: context, label: AppStrings.noTopics);
      }
      if (kDebugMode) {
        print("Error while creating new asset post : $error");
      }
    }
  }
}

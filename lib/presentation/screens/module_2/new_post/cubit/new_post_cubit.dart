import 'package:socialapp/utils/import.dart';
import 'package:universal_html/html.dart' as html;

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

  Future<Uint8List> _resizeAndConvertToWebP(html.File file) async {
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

        Stopwatch stopwatch = Stopwatch();
        stopwatch.start();

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
            final resizedWebP = await _resizeAndConvertToWebP(file);

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
              final dimensions = await getVideoDimensions(assetPath);
              print('Video Dimensions: $dimensions');
            } catch (e) {
              print('Error fetching video dimensions: $e');
            }
            // if(PlatformConfig.of(context)!.isWeb) {
            //   videoDimensions = await getVideoDimensionsForWebsite(assetPath);
            // } else {
            //   videoDimensions = await getVideoDimensionsForMobile(assetPath);
            // }
            uploadedAsset['isNSFW'] = false;

            uploadedAsset['data'] = reader.result as Uint8List;
            ;
            uploadedAsset['width'] = videoDimensions['width'] ?? 0;
            uploadedAsset['height'] = videoDimensions['height'] ?? 1;
            uploadedAsset['type'] = 'video';
          }

          uploadedAsset['ratio'] = (uploadedAsset['width'] as double? ?? 0) /
              (uploadedAsset['height'] as double? ?? 1);
          uploadedAsset['nextAsset'] = false;
          if (index < files.length - 1) {
            uploadedAsset['nextAsset'] = true;
          }

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

        if (kDebugMode) {
          print("Time for processing : ${stopwatch.elapsedMilliseconds}");
        }
        stopwatch.stop();
      } catch (error) {
        if (kDebugMode) {
          print("Error during pick assets : $error");
        }
      }
    });
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

  Future<void> pickVideoMobile(
      ValueNotifier<List<Map<String, dynamic>>> imagePathNotifier,
      BuildContext context,) async {
    final ImagePicker picker = ImagePicker();

    // Pick a video from gallery
    final pickedVideo = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedVideo == null) return; // If no video is selected, return early

    final file = File(pickedVideo.path);

    // Check if the video file exceeds 60 MB (60 * 1024 * 1024 bytes)
    if (file.lengthSync() > 60 * 1024 * 1024) {
      showAttentionMessage(
        context: context,
        description: 'The video file is too large. Maximum size is 60MB.',
      );
      return; // Return if file exceeds the size limit
    }

    // Check if the uploaded files exceed the limit (e.g., 8 files)
    if ((imagePathNotifier.value.length) > 8 ||
        (imagePathNotifier.value.length + 1) > 8) {
      showUploadLimitExceededMassage(context: context);
      return;
    }

    // Process the selected video
    final uploadedAsset = <String, dynamic>{};
    uploadedAsset['name'] = pickedVideo.name;

    if (file.existsSync()) {
      uploadedAsset['data'] = await file.readAsBytes();
      uploadedAsset['type'] = 'video';

      // Get the dimensions if needed
      // For example, you can use video player or any other method to extract dimensions
      // final videoPlayerController = VideoPlayerController.file(file);
      // await videoPlayerController.initialize();
      // uploadedAsset['width'] = videoPlayerController.value.size.width;
      // uploadedAsset['height'] = videoPlayerController.value.size.height;
    }

    // Add the uploaded video to the list
    final uploadedFiles = List<Map<String, dynamic>>.from(
        imagePathNotifier.value);
    uploadedFiles.add(uploadedAsset);
    imagePathNotifier.value = uploadedFiles;

    // You can add further functionality like processing, categorizing, etc.
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

      await serviceLocator<PostRepository>()
          .createAssetPost(content, imagesAndVideos, topics);

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

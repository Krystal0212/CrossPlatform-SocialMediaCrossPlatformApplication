import 'package:socialapp/utils/import.dart';
import 'package:universal_html/html.dart' as html;

import 'new_post_state.dart';

class NewPostCubit extends Cubit<NewPostState>
    with ClassificationMixin, ImageAndVideoProcessingHelper {
  NewPostCubit() : super(PostInitial());

  Future<String> _getLocalVideoUrl(html.File file) async {
    final completer = Completer<String>();
    String url = html.Url.createObjectUrl(file);
    completer.complete(url);
    return completer.future;
  }

  void pickAssets(
      ValueNotifier<List<Map<String, dynamic>>> imagePathNotifier) async {
    try {
      final uploadInput = html.FileUploadInputElement()
        ..accept = 'image/*,video/*'
        ..multiple = true;

      uploadInput.click();

      uploadInput.onChange.listen((event) async {
        final files = uploadInput.files;

        if (files != null && files.isNotEmpty) {
          final uploadedFiles = <Map<String, dynamic>>[];

          for (int index = 0; index < files.length; index++) {
            final reader = html.FileReader();
            reader.readAsArrayBuffer(files[index]);
            await reader.onLoad.first;

            final uploadedAsset = {
              'index': index,
              'height': 1,
              'width': 0,
              'data': reader.result as Uint8List,
              'isNSFW': await classifyNSFW(reader.result as Uint8List),
            };
            late String assetPath = '';

            if (files[index].type.startsWith('image')) {
              assetPath = html.Url.createObjectUrl(files[index]);

              final imageElement = html.ImageElement()..src = assetPath;
              await imageElement.onLoad.first;

              uploadedAsset['width'] = imageElement.width ?? 0;
              uploadedAsset['height'] = imageElement.height ?? 1;
              uploadedAsset['type'] = 'image';
            } else if (files[index].type.startsWith('video')) {
              assetPath = await _getLocalVideoUrl(files[index]);
              final videoDimensions = await getVideoDimensions(assetPath);

              uploadedAsset['width'] = videoDimensions['width'] ?? 0;
              uploadedAsset['height'] = videoDimensions['height'] ?? 1;
              uploadedAsset['type'] = 'video';
            }

            uploadedAsset['path'] = assetPath;
            uploadedAsset['ratio'] =
                (uploadedAsset['width'] as double? ?? 0) /
                (uploadedAsset['height'] as double? ?? 1);
            uploadedFiles.add(uploadedAsset);
          }

          imagePathNotifier.value = uploadedFiles;
        }
      });
    } catch (error) {
      if (kDebugMode) {
        print("Error while picking assets : $error");
      }
    }
  }

  void sendPost(TextEditingController textEditingController,
      ValueNotifier<List<Map<String, dynamic>>> imagePathNotifier) async {
    final String content = textEditingController.text;
    final List<Map<String, dynamic>> imagesAndVideos = imagePathNotifier.value;

    try{
      if (imagesAndVideos.isNotEmpty) {
        serviceLocator<PostRepository>().createAssetPost(content, imagesAndVideos);
      }
    } catch (error){
      if (kDebugMode) {
        print("Error while creating new asset post : $error");
      }
    }

  }
}

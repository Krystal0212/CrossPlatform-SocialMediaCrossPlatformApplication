import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:socialapp/presentation/screens/module_2/new_post/widgets/dialog_body.dart';
import 'package:socialapp/presentation/screens/module_2/new_post/widgets/video_player.dart';
import 'package:socialapp/utils/import.dart';

class ImagePreview extends StatelessWidget {
  final ValueNotifier<List<Map<String, dynamic>>> selectedAssetsNotifier;

  const ImagePreview({
    super.key,
    required this.selectedAssetsNotifier,
  });

  Future<File> convertToWebP(File inputFile, {int targetWidth = 250}) async {
    final Uint8List? compressedImage =
        await FlutterImageCompress.compressWithFile(
      inputFile.absolute.path,
      format: CompressFormat.webp,
      quality: 1,
      minWidth: targetWidth,
    );

    if (compressedImage == null) {
      throw Exception("Failed to convert image to WebP.");
    }

    final String outputPath = inputFile.path
        .replaceAll(RegExp(r'\.(heic|HEIC|jpg|jpeg|png)$'), '.webp');
    final File outputFile = File(outputPath);
    await outputFile.writeAsBytes(compressedImage);

    return outputFile; // Return the new WebP file
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: selectedAssetsNotifier,
      builder: (context, imagePathList, child) {
        if (imagePathList.isNotEmpty) {
          return Positioned(
            bottom: MediaQuery.of(context).size.height * 0.08,
            left: 16.0,
            right: 16.0,
               child: SizedBox(
            width: deviceWidth * 0.8,
            height: 250,

              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: imagePathList.length,
                itemBuilder: (context, index) {
                  final Uint8List assetData = imagePathList[index]['data'];

                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: imagePathList[index]['type'] == 'video'
                            ? VideoPlayerWidget(videoData: assetData)
                            : Container(
                                height: 250,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                    assetData,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                      ),
                      Positioned(
                        top: 10,
                        right: 30,
                        child: CloseIconButton(
                          onTap: () {
                            final List<Map<String, dynamic>> updatedList =
                                List<Map<String, dynamic>>.from(imagePathList);
                            updatedList.removeAt(index);
                            selectedAssetsNotifier.value = updatedList;
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );

          // ImageDisplay(
          //    imageBytes: File(selectedXFile.path),
          //    selectedImageNotifier: selectedAssetsNotifier);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class ImageDisplay extends StatelessWidget {
  final File imageBytes;
  final int index;

  // final bool isHeic;
  final ValueNotifier<List<Map<String, dynamic>>> selectedImageNotifier;

  const ImageDisplay(
      {super.key,
      required this.imageBytes,
      required this.selectedImageNotifier,
      required this.index});

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.height;
    // final maxWidth = deviceWidth * 0.5;
    // final maxHeight = deviceHeight * 0.3;
    //
    // final sizeResult = ImageSizeGetter.getSizeResult(FileInput(imageBytes));
    // final imageWidth = sizeResult.size.width;
    // final imageHeight = sizeResult.size.height;
    //
    // final aspectRatio = imageWidth / imageHeight;
    // double previewWidth = maxWidth;
    // double previewHeight = previewWidth / aspectRatio;
    //
    // if (previewHeight > maxHeight) {
    //   previewHeight = maxHeight;
    //   previewWidth = previewHeight * aspectRatio;
    // }

    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.07,
      left: 16.0,
      right: 16.0,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 15.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            height: 250,
            width: deviceWidth * 0.32,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.trolleyGrey),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.memory(
                      imageBytes.readAsBytesSync(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: -10,
                  right: -10,
                  child: CloseIconButton(
                    onTap: () {
                      final List<Map<String, dynamic>> updatedList =
                          List<Map<String, dynamic>>.from(selectedImageNotifier.value);
                      updatedList.removeAt(index);
                      selectedImageNotifier.value = updatedList;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

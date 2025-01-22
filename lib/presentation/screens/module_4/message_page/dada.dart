import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';

import '../../../../utils/import.dart';
import '../../../widgets/general/nsfw_and_close_icons.dart';
import '../../module_2/new_post/widgets/mobile_dialog_body.dart';

class ImagePreview extends StatelessWidget {
  final ValueNotifier<XFile?> selectedImageNotifier;

  const ImagePreview({
    super.key,
    required this.selectedImageNotifier,
  });

  // Compress image to WebP format with minimal quality to speed up the process.
  Future<Uint8List?> convertToWebP(File inputFile) async {
    // Using lower quality for faster compression
    final compressedImage = await FlutterImageCompress.compressWithFile(
      inputFile.absolute.path,
      format: CompressFormat.webp,
      quality: 30, // Lower quality (to improve speed)
      minWidth: 800, // Optional: resize to reduce file size further
      minHeight: 800,
    );

    return compressedImage;
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return ValueListenableBuilder<XFile?>(
      valueListenable: selectedImageNotifier,
      builder: (context, selectedImage, child) {
        if (selectedImage != null) {
          return FutureBuilder<Uint8List?>(
              future: convertToWebP(File(selectedImage.path)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || snapshot.data == null) {
                  return const Center(child: Text("Failed to load image"));
                }

                final imageData = snapshot.data!;

                // Get the image size (WebP should be supported now)
                final sizeResult = ImageSizeGetter.getSizeResult(FileInput(File(selectedImage.path)));
                final imageWidth = sizeResult.size.width;
                final imageHeight = sizeResult.size.height;

                final aspectRatio = imageWidth / imageHeight;
                double previewWidth = deviceWidth * 0.32;
                double previewHeight = previewWidth / aspectRatio;

                final maxHeight = MediaQuery.of(context).size.height * 0.3;

                if (previewHeight > maxHeight) {
                  previewHeight = maxHeight;
                  previewWidth = previewHeight * aspectRatio;
                }

                return Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.07,
                  left: 16.0,
                  right: 16.0,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Align(
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
                                    child: SizedBox(
                                      width: previewWidth,
                                      height: previewHeight,
                                      child: Image.memory(
                                        imageData,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -10,
                                  right: -10,
                                  child: CloseIconButton(
                                    onTap: () {
                                      selectedImageNotifier.value = null;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              });
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

import 'package:image_size_getter/file_input.dart';
import 'package:image_size_getter/image_size_getter.dart';
import 'package:socialapp/utils/import.dart';

class ImagePreview extends StatelessWidget {
  final ValueNotifier<XFile?> selectedImageNotifier;

  const ImagePreview({
    super.key,
    required this.selectedImageNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<XFile?>(
      valueListenable: selectedImageNotifier,
      builder: (context, selectedImage, child) {
        if (selectedImage != null) {
          return Positioned(
            bottom: MediaQuery.of(context).size.height * 0.07,
            left: 16.0,
            right: 16.0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth * 0.5;
                final maxHeight = MediaQuery.of(context).size.height * 0.3;

                final sizeResult = ImageSizeGetter.getSizeResult(
                    FileInput(File(selectedImage.path)));
                final imageWidth = sizeResult.size.width;
                final imageHeight = sizeResult.size.height;

                final aspectRatio = imageWidth / imageHeight;
                double previewWidth = maxWidth;
                double previewHeight = previewWidth / aspectRatio;

                if (previewHeight > maxHeight) {
                  previewHeight = maxHeight;
                  previewWidth = previewHeight * aspectRatio;
                }

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
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: SizedBox(
                            width: previewWidth,
                            height: previewHeight,
                            child: Image.file(
                              File(selectedImage.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: -10,
                          right: -10,
                          child: GestureDetector(
                            onTap: () {
                              selectedImageNotifier.value = null;
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

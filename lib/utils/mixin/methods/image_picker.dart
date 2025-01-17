import 'package:image/image.dart' as img;

import 'package:socialapp/utils/import.dart';


class ImageProcessingHelper {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> pickImageFromGallery(BuildContext context, dynamic cubit) async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      cubit.createImagePost(File(pickedFile.path));
    }
  }

  Future<void> pickImageFromCamera(BuildContext context, dynamic cubit) async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      // add image to cubit
      cubit.createImagePost(File(pickedFile.path));
    }
  }

  static Future<String> getDominantColorFromImage(Uint8List imageData) async {
    final palette = await PaletteGenerator.fromImageProvider(
      MemoryImage(imageData),
      size: const Size(75, 75),
    );
    return palette.dominantColor?.color.value.toRadixString(16) ??
        AppColors.tangledWeb.value.toRadixString(16);
  }

  static double calculateAspectRatio(img.Image? image) {
    int width = image?.width ?? 0;
    int height = image?.height ?? 0;
    return width / height;
  }

  static List<int> calculateWidthAndHeight(img.Image? image) {
    int width = image?.width ?? 0;
    int height = image?.height ?? 0;
    return [width,height];
  }
}

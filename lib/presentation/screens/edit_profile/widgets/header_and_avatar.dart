import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../../../utils/constants/icon_path.dart';
import '../../../../utils/constants/image_path.dart';
import '../../../../utils/styles/themes.dart';
import '../../../widgets/edit_profile/bottom_rounded_appbar.dart';
import '../../../widgets/svg_icon_button.dart';

class ImagePickerHelper {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> pickImageFromGallery(BuildContext context, Function(File) onImagePicked) async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
    }
  }

  Future<void> pickImageFromCamera(BuildContext context, Function(File) onImagePicked) async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
    }
  }
}

class HeaderAndAvatar extends StatefulWidget {
  final ValueNotifier<String> avatarNotifier;
  final ValueNotifier<bool> isFileImageNotifier;

  HeaderAndAvatar({super.key, required this.avatarNotifier})
      :isFileImageNotifier = ValueNotifier<bool>(false);

  String get avatarValue => avatarNotifier.value;

  @override
  State<HeaderAndAvatar> createState() => _HeaderAndAvatarState();
}

class _HeaderAndAvatarState extends State<HeaderAndAvatar> {
  double avatarRadius = 60;
  late double appBarBackgroundHeight = avatarRadius * 2 / 0.6;
  late double appBarContainerHeight = avatarRadius * (1 + 2 / 0.6);
  final _imagePickerHelper = ImagePickerHelper();

  Future<void> _showImageSourceOptions(BuildContext context) async {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          actions: [
            TextButton(
              onPressed: () async {
                await _imagePickerHelper.pickImageFromGallery(context, (file) {
                  onAvatarChanged(file, true); // Set as file image
                  Navigator.of(dialogContext).pop();
                });
              },
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () async {
                await _imagePickerHelper.pickImageFromCamera(context, (file) {
                  onAvatarChanged(file, true); // Set as file image
                  Navigator.of(dialogContext).pop();
                });
              },
              child: const Text('Camera'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<File> compressImage(File imageFile) async {
    final imageBytes = await imageFile.readAsBytes();

    final originalImage = img.decodeImage(imageBytes);

    final resizedImage = img.copyResize(originalImage!, width: 600);

    final compressedBytes = img.encodeJpg(resizedImage, quality: 85); // Adjust quality (0-100)

    final directory = Directory.systemTemp;
    final compressedImageFile = File('${directory.path}/compressed_${imageFile.uri.pathSegments.last}');

    await compressedImageFile.writeAsBytes(compressedBytes);

    return compressedImageFile;
  }

  Future<void> onAvatarChanged(File newAvatar, bool isFileImage) async {
    final compressedImage = await compressImage(newAvatar);
    widget.avatarNotifier.value = compressedImage.path;
    widget.isFileImageNotifier.value = isFileImage;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: appBarBackgroundHeight,
              child: const BottomRoundedAppBar(
                bannerPath: AppImages.editProfileAppbarBackground,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 40),
            child: IntrinsicHeight(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => {},
                      icon: const Icon(Icons.arrow_back_sharp),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Edit profile',
                      textAlign: TextAlign.center,
                      style: AppTheme.headerStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: 160,
              height: 120,
              child: Stack(
                children: [
                  Align(
                    child: ValueListenableBuilder<String>(
                      valueListenable: widget.avatarNotifier,
                      builder: (context, avatarURL, _) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: widget.isFileImageNotifier,
                          builder: (context, isFileImage, _) {
                            if(isFileImage){
                              return CircleAvatar(
                                radius: avatarRadius,
                                backgroundImage: // Use FileImage for local files
                                FileImage(File(avatarURL)),// Use CachedNetworkImageProvider for network images
                              );
                            }
                              else {
                              return CircleAvatar(
                              radius: avatarRadius,
                              backgroundImage: // Use FileImage for local files
                                   CachedNetworkImageProvider(avatarURL), // Use CachedNetworkImageProvider for network images
                            );
                            }
                          },
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                        gradient: AppTheme.mainGradient,
                      ),
                      child: SvgIconButton(
                        iconSize: 18,
                        onPressed: () async {
                          await _showImageSourceOptions(context);
                        },
                        assetPath: AppIcons.camera,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

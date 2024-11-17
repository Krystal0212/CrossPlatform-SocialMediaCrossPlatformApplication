import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
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
}
